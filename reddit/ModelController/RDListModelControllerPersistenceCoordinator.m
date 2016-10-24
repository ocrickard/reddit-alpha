//
//  RDListModelControllerPersistenceCoordinator.m
//  OnOne
//
//  Created by Oliver Rickard on 10/25/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDListModelControllerPersistenceCoordinator.h"

#import "RDDiskCache.h"

@implementation RDListModelControllerPersistenceCoordinator
{
  RDDiskCache *_diskCache;
  NSString *_identifier;
  dispatch_queue_t _dataQueue;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                         diskCache:(RDDiskCache *)diskCache
{
  if (self = [super init]) {
    NSAssert(identifier != nil, @"requires identifier");
    _identifier = [identifier copy];
    _diskCache = diskCache;
    _dataQueue = dispatch_queue_create("com.ocrickard.onOne.listModel.persistenceCoord.serial", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)persistItems:(NSOrderedSet *)items
{
  dispatch_async(_dataQueue, ^{
    NSError *error = nil;
    NSData *data = nil;
    @try {
      data = [NSKeyedArchiver archivedDataWithRootObject:items];
    }
    @catch (NSException *exception) {
      error = [NSError errorWithDomain:NSStringFromClass([self class])
                                  code:1
                              userInfo:@{@"exception" : exception}];
      // We don't write to disk if there was an exception so we don't wipe out the data store for unexpected error.
      return;
    }

    [_diskCache storeData:data
                   forKey:_identifier
                     mode:RDDiskCacheModeAsynchronous
               completion:^(BOOL success, NSError *error) {
                 NSLog(@"wrote data to disk:%@", error);
               }];
  });
}

- (void)restoreItems:(RDListModelControllerPersistenceCoordinatorRestoreBlock)block
{
  [_diskCache fetchDataForKey:_identifier mode:RDDiskCacheModeAsynchronous completion:^(NSData *data, NSError *error) {
    dispatch_async(_dataQueue, ^{
      if (data) {
        NSError *error = nil;
        NSOrderedSet *set = nil;
        @try {
          set = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
          error = [NSError errorWithDomain:NSStringFromClass([self class])
                                      code:1
                                  userInfo:@{@"exception" : exception}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          block(set, error);
        });
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          block(nil, error);
        });
      }
    });
  }];
}

@end
