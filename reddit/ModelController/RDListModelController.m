//
//  RDListModelController.m
//  OnOne
//
//  Created by Oliver Rickard on 8/16/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDListModelController.h"

#import <QuartzCore/QuartzCore.h>

#import "RDConsistentModelCache.h"
#import "RDListModelControllerPersistenceCoordinator.h"

@interface RDListModelController () <RDConsistenModelCacheObserver>

@end

@implementation RDListModelController
{
  RDUserSession *_userSession;
  dispatch_queue_t _transactionQueue;
  dispatch_queue_t _itemsQueue;
  NSOrderedSet *_items;
  RDListModelControllerPersistenceCoordinator *_persistenceCoordinator;
  BOOL _scheduledPersistence;
}

- (instancetype)init
{
  assert(0);
  return [self initWithUserSession:nil
            persistenceCoordinator:nil];
}

- (instancetype)initWithUserSession:(RDUserSession *)userSession
             persistenceCoordinator:(RDListModelControllerPersistenceCoordinator *)persistenceCoordinator
{
  if (self = [super init]) {
    _userSession = userSession;
    _itemsQueue = dispatch_queue_create("com.ocrickard.listModelController.items.serial", DISPATCH_QUEUE_SERIAL);
    _persistenceCoordinator = persistenceCoordinator;
    if (_persistenceCoordinator) {
      [_persistenceCoordinator restoreItems:^(NSOrderedSet *items, NSError *error) {
        [self setItems:items ?: [NSOrderedSet orderedSet]];
      }];
    } else {
      _items = [NSOrderedSet orderedSet];
    }
  }
  return self;
}

- (NSOrderedSet *)items
{
  __block NSOrderedSet *items;
  dispatch_sync(_itemsQueue, ^{
    items = _items;
  });
  return items;
}

- (void)setItems:(NSOrderedSet *)items
{
  [self setItems:items
        userInfo:nil];
}

- (void)setItems:(NSOrderedSet *)items
        userInfo:(NSDictionary *)userInfo
{
  __block NSOrderedSet *originalItems;
  dispatch_sync(_itemsQueue, ^{
    originalItems = _items ?: [NSOrderedSet orderedSet];
  });
  NSSet *itemsSet = [items set];
  NSSet *originalItemsSet = [originalItems set];

  NSMutableSet *removedItems = [originalItemsSet mutableCopy];
  [removedItems minusSet:itemsSet];

  NSMutableSet *alreadyPresentItems = [originalItemsSet mutableCopy];
  [alreadyPresentItems intersectSet:itemsSet];

  NSMutableSet *newItems = [itemsSet mutableCopy];
  [newItems minusSet:originalItemsSet];

  NSMutableIndexSet *newItemIndices = [[NSMutableIndexSet alloc] init];
  NSMutableIndexSet *reloadedItemIndices = [[NSMutableIndexSet alloc] init];
  NSMutableIndexSet *removedItemIndices = [[NSMutableIndexSet alloc] init];

  for (NSObject<NSCopying> *obj in alreadyPresentItems) {
    // Get the new item, and compare the pointer value. If they're different,
    // then reload the indices.
    NSObject<NSCopying> *newObj = [itemsSet member:obj];
    if (newObj != obj) {
      [reloadedItemIndices addIndex:[originalItems indexOfObject:obj]];
    }
  }

  for (NSObject<NSCopying> *obj in newItems) {
    [newItemIndices addIndex:[items indexOfObject:obj]];
  }

  for (NSObject<NSCopying> *obj in removedItems) {
    [removedItemIndices addIndex:[originalItems indexOfObject:obj]];
  }

  dispatch_sync(_itemsQueue, ^{
    _items = items;
  });

  [_delegate listModelController:self
          insertedItemsAtIndices:newItemIndices
           removedItemsAtIndices:removedItemIndices
          reloadedItemsAtIndices:reloadedItemIndices
                   originalItems:originalItems
                        userInfo:userInfo];
  RDConsistentModelCache *modelCache = [_userSession consistentModelCache];
  for (NSObject<NSCopying> *obj in newItems) {
    [modelCache addObserver:self forModel:obj];
  }

  [self _schedulePersistence];
}

- (void)modelDidUpdate:(NSObject<NSCopying> *)newModel
              userInfo:(NSDictionary *)userInfo
{
  __block NSOrderedSet *originalItems;
  dispatch_sync(_itemsQueue, ^{
    originalItems = _items ?: [NSOrderedSet orderedSet];
  });

  if (![originalItems containsObject:newModel]) {
    // A race condition has occurred, we have received an update for a model that we are no longer tracking.
    return;
  }

  NSMutableOrderedSet *newSet = [originalItems mutableCopy];

  NSUInteger originalIndex = [originalItems indexOfObject:newModel];

  // The model is still being tracked by the list model controller, we must replace since adding is a no-op when
  // the original object is already present.
  [newSet replaceObjectAtIndex:originalIndex withObject:newModel];

  NSIndexSet *reloaded = [NSIndexSet indexSetWithIndex:originalIndex];

  dispatch_sync(_itemsQueue, ^{
    _items = newSet;
  });

  [_delegate listModelController:self
          insertedItemsAtIndices:nil
           removedItemsAtIndices:nil
          reloadedItemsAtIndices:reloaded
                   originalItems:originalItems
                        userInfo:userInfo];

  [self _schedulePersistence];
}

/** Should be called on _transactionQueue only. */
- (void)_schedulePersistence
{
  if (_scheduledPersistence) {
    return;
  }

  _scheduledPersistence = YES;

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), _transactionQueue, ^{
    [_persistenceCoordinator persistItems:self.items];
    _scheduledPersistence = NO;
  });
}

@end
