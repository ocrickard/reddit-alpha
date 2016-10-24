//
//  RDStreamController.h
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDUserSession;

typedef void (^RDStreamControllerNetworkSourceCompletionBlock)(NSArray *collection, id paginationInfo, NSError *error);

@protocol RDStreamControllerNetworkSource <NSObject>

- (void)loadHeadWithPaginationInfo:(id)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion;
- (void)loadTailWithPaginationInfo:(id)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion;

@end

@class RDStreamController;

@protocol RDStreamControllerDelegate <NSObject>

- (void)streamControllerDidCompleteLoad:(RDStreamController *)controller
                              withError:(NSError *)error;

@end

@interface RDStreamController : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithNetworkSource:(id<RDStreamControllerNetworkSource>)networkSource
                       paginationInfo:(id)paginationInfo
                                items:(NSArray *)items
                              session:(RDUserSession *)session NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) id paginationInfo;
@property (nonatomic, copy, readonly) NSArray *items;

@property (nonatomic, assign, readonly) BOOL isLoading;

@property (nonatomic, weak) id<RDStreamControllerDelegate> delegate;

- (void)loadHead;
- (void)loadTail;

@end
