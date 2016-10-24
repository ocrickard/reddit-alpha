//
//  RDConsistentModelCache.m
//  OnOne
//
//  Created by Oliver Rickard on 8/29/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDConsistentModelCache.h"

#import <mutex>

@interface RDConsistentModelCacheEntry : NSObject

@property (nonatomic, strong) NSObject<NSCopying> *model;
@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation RDConsistentModelCacheEntry

@end

@implementation RDConsistentModelCache
{
  dispatch_queue_t _queue;
  NSMutableDictionary<NSObject<NSCopying> *, RDConsistentModelCacheEntry *> *_idToEntryMap;
  NSMutableDictionary<NSObject<NSCopying> *, NSHashTable<id<RDConsistenModelCacheObserver>> *> *_idToObserverHashMap;
}

- (instancetype)init
{
  if (self = [super init]) {
    _queue = dispatch_queue_create("com.ocrickard.consistentModelCache", DISPATCH_QUEUE_SERIAL);
    _idToEntryMap = [[NSMutableDictionary alloc] init];
    _idToObserverHashMap = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addObserver:(id<RDConsistenModelCacheObserver>)observer
           forModel:(NSObject<NSCopying> *)modelObject
{
  NSObject<NSCopying> *key = modelObject;
  dispatch_async(_queue, ^{
    NSHashTable *observerHashTable = _idToObserverHashMap[key];
    if (!observerHashTable) {
      observerHashTable = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory|NSHashTableObjectPointerPersonality
                                                      capacity:0];
      [_idToObserverHashMap setObject:observerHashTable forKey:key];
    }
    [observerHashTable addObject:observer];
    RDConsistentModelCacheEntry *newEntry = _idToEntryMap[key];
    if (newEntry) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [observer modelDidUpdate:newEntry.model
                        userInfo:newEntry.userInfo];
      });
    }
  });
}

- (void)removeObserver:(id<RDConsistenModelCacheObserver>)observer
              forModel:(NSObject<NSCopying> *)modelObject
{
  NSObject<NSCopying> *key = modelObject;
  dispatch_async(_queue, ^{
    NSHashTable *observerHashTable = [_idToObserverHashMap objectForKey:key];
    [observerHashTable removeObject:observer];
  });
}

- (void)updateModel:(NSObject<NSCopying> *)modelObject
           userInfo:(NSDictionary *)userInfo
{
  NSObject<NSCopying> *copiedModelObject = [modelObject copy];
  NSAssert(modelObject, @"Must provide model object");
  dispatch_async(_queue, ^{
    RDConsistentModelCacheEntry *entry = [[RDConsistentModelCacheEntry alloc] init];
    entry.model = copiedModelObject;
    entry.userInfo = userInfo;
    _idToEntryMap[copiedModelObject] = entry;
    NSArray *observerHashTable = [_idToObserverHashMap[copiedModelObject] allObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
      for (id<RDConsistenModelCacheObserver> observer in observerHashTable) {
        [observer modelDidUpdate:copiedModelObject
                        userInfo:userInfo];
      }
    });
  });
}

@end

@implementation RDUserSession (RDConsistentModelCache)

- (RDConsistentModelCache *)consistentModelCache
{
  return [self objectForKey:@"RDConsistentModelCache" withInitializer:^id(RDUserSession *session) {
    return [[RDConsistentModelCache alloc] init];
  }];
}

@end
