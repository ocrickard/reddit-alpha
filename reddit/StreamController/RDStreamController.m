//
//  RDStreamController.m
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDStreamController.h"

@implementation RDStreamController
{
  id<RDStreamControllerNetworkSource> _networkSource;
  RDUserSession *_session;

  BOOL _isLoadingHead;
  BOOL _isLoadingTail;

  BOOL _loadTailReturnedNoItems;
}

- (instancetype)initWithNetworkSource:(id<RDStreamControllerNetworkSource>)networkSource
                       paginationInfo:(id)paginationInfo
                                items:(NSArray *)items
                              session:(RDUserSession *)session
{
  if (self = [super init]) {
    _networkSource = networkSource;
    _paginationInfo = paginationInfo;
    _items = items ?: @[];
    _session = session;
  }
  return self;
}

- (void)loadHead
{
  NSAssert([NSThread isMainThread], @"must be on main");
  if (_isLoadingHead) {
    DDLogVerbose(@"Load is already ongoing, avoiding load head");
    return;
  }

  _isLoadingHead = YES;

  __weak __typeof(self) weakSelf = self;
  [_networkSource loadHeadWithPaginationInfo:_paginationInfo
                                  completion:^(NSArray *collection, id paginationInfo, NSError *error) {
                                    [weakSelf _handleHeadLoadResponse:collection
                                                       paginationInfo:paginationInfo
                                                                error:error];
                                  }];
}

- (void)_handleHeadLoadResponse:(NSArray *)collection
                 paginationInfo:(id)paginationInfo
                          error:(NSError *)error
{
  NSAssert([NSThread isMainThread], @"must be on main");

  _isLoadingHead = NO;

  if (error) {
    [self.delegate streamControllerDidCompleteLoad:self
                                         withError:error];
  } else {
    _loadTailReturnedNoItems = NO;
    _items = collection;
    _paginationInfo = paginationInfo;
    [self.delegate streamControllerDidCompleteLoad:self
                                         withError:error];
  }
}

- (void)loadTail
{
  NSAssert([NSThread isMainThread], @"must be on main");
  if (_isLoadingTail) {
    DDLogVerbose(@"Load is already ongoing, avoiding load tail");
    return;
  }

  if (_loadTailReturnedNoItems) {
    DDLogVerbose(@"Refusing to load tail because we have already failed to load content.");
    return;
  }

  _isLoadingTail = YES;

  __weak __typeof(self) weakSelf = self;
  [_networkSource loadTailWithPaginationInfo:_paginationInfo
                                  completion:^(NSArray *collection, id paginationInfo, NSError *error) {
                                    [weakSelf _handleTailLoadResponse:collection
                                                       paginationInfo:paginationInfo
                                                                error:error];
                                  }];
}

- (void)_handleTailLoadResponse:(NSArray *)collection
                 paginationInfo:(id)paginationInfo
                          error:(NSError *)error
{
  NSAssert([NSThread isMainThread], @"must be on main");

  _isLoadingTail = NO;

  if (error) {
    [self.delegate streamControllerDidCompleteLoad:self
                                         withError:error];
  } else {
    if (collection.count == 0) {
      _loadTailReturnedNoItems = YES;
    }
    _items = [self.items arrayByAddingObjectsFromArray:collection];
    _paginationInfo = paginationInfo;
    [self.delegate streamControllerDidCompleteLoad:self
                                         withError:error];
  }
}

- (BOOL)isLoading
{
  return _isLoadingHead || _isLoadingTail;
}

@end
