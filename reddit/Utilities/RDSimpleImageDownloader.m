//
//  RDSimpleImageDownloader.m
//  OnOne
//
//  Created by Oliver Rickard on 8/7/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDSimpleImageDownloader.h"

#import <UIKit/UIKit.h>

@interface RDSimpleImageDownloaderRequest : NSObject
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
@property (nonatomic, copy) void (^downloadProgressBlock)(CGFloat);
@property (nonatomic, copy) void (^downloadCompletionBlock)(CGImageRef, NSError *);
@end

@implementation RDSimpleImageDownloaderRequest
@end

@interface RDSimpleImageDownloader () <NSURLSessionDataDelegate>
@end

@implementation RDSimpleImageDownloader
{
  NSMutableDictionary *_urlToConnectionMap;
  NSURLSession *_session;
  dispatch_queue_t _queue;
}

- (instancetype)init
{
  if (self = [super init]) {
    _urlToConnectionMap = [[NSMutableDictionary alloc] init];
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                             delegate:self
                                        delegateQueue:nil];
    _queue = dispatch_queue_create("com.ocrickard.imageDownloader.serial", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)cancelImageDownload:(id)download
{
  if ([download isKindOfClass:[RDSimpleImageDownloaderRequest class]]) {
    dispatch_sync(_queue, ^{
      RDSimpleImageDownloaderRequest *request = download;
      [request.task cancel];
      [_urlToConnectionMap removeObjectForKey:request.url];
      dispatch_async(request.callbackQueue, ^{
        request.downloadCompletionBlock(nil, nil);
      });
    });
  }
}

- (id)downloadImageWithURL:(NSURL *)URL
                 scenePath:(id)scenePath
                    caller:(id)caller
             callbackQueue:(dispatch_queue_t)callbackQueue
     downloadProgressBlock:(void (^)(CGFloat))downloadProgressBlock
                completion:(void (^)(CGImageRef, NSError *))completion
{
  __block id handle = nil;
  dispatch_sync(_queue, ^{
    RDSimpleImageDownloaderRequest *request = _urlToConnectionMap[URL];
    if (request) {
      // kill the old request
      [request.task cancel];
    }
    
    request = [[RDSimpleImageDownloaderRequest alloc] init];
    request.url = URL;
    __weak __typeof(self) weakSelf = self;
    request.task = [_session dataTaskWithURL:URL
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                             [weakSelf _handleCompletionWithURL:URL
                                                           data:data
                                                       response:response
                                                          error:error];
                           }];
    [request.task resume];
    request.callbackQueue = callbackQueue;
    request.downloadProgressBlock = downloadProgressBlock;
    request.downloadCompletionBlock = completion;
    
    _urlToConnectionMap[URL] = request;
    
    handle = request;
  });
  return handle;
}

- (void)_handleCompletionWithURL:(NSURL *)URL
                            data:(NSData *)data
                         response:(NSURLResponse *)response
                            error:(NSError *)error
{
  if (!data) {
    return;
  }
  DDLogVerbose(@"Downloaded image:%@", URL);
  dispatch_async(_queue, ^{
    RDSimpleImageDownloaderRequest *request = _urlToConnectionMap[URL];
    if (!request) {
      DDLogError(@"Error, request not found on completion:%@", URL);
      return;
    }
    [_urlToConnectionMap removeObjectForKey:URL];
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(request.callbackQueue, ^{
      request.downloadCompletionBlock(image.CGImage, nil);
    });
  });
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(nonnull NSURLSession *)session
          dataTask:(nonnull NSURLSessionDataTask *)dataTask
    didReceiveData:(nonnull NSData *)data
{
  if (!data) {
    return;
  }
  DDLogVerbose(@"Downloaded image:%@", dataTask.originalRequest.URL);
  dispatch_async(_queue, ^{
    RDSimpleImageDownloaderRequest *request = _urlToConnectionMap[dataTask.originalRequest.URL];
    if (!request.downloadProgressBlock) {
      return;
    }
    dispatch_async(request.callbackQueue, ^{
      request.downloadProgressBlock(dataTask.countOfBytesReceived / dataTask.countOfBytesExpectedToReceive);
    });
  });
}

- (void)URLSession:(nonnull NSURLSession *)session
              task:(nonnull NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  if (!error) {
    return;
  }
  DDLogError(@"Error downloading image:%@", error);
  dispatch_async(_queue, ^{
    RDSimpleImageDownloaderRequest *request = _urlToConnectionMap[task.originalRequest.URL];
    if (request) {
      [_urlToConnectionMap removeObjectForKey:task.originalRequest.URL];
      dispatch_async(request.callbackQueue, ^{
        request.downloadCompletionBlock(nil, error);
      });
    }
  });
}

@end

@implementation RDUserSession (RDSimpleImageDownloader)

- (RDSimpleImageDownloader *)imageDownloader
{
  return [self objectForKey:@"RDSimpleImageDownloader" withInitializer:^id(RDUserSession *session) {
    return [[RDSimpleImageDownloader alloc] init];
  }];
}

@end
