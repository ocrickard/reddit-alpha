//
//  RDUserSession.m
//  OnOne
//
//  Created by Oliver Rickard on 8/7/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDUserSession.h"

static dispatch_queue_t globalQueue(void) {
  static dispatch_queue_t queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("com.ocrickard.sessionGlobal.serial", DISPATCH_QUEUE_SERIAL);
  });
  return queue;
}

static NSMutableSet *globalSet(void) {
  static NSMutableSet *set;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    set = [[NSMutableSet alloc] init];
  });
  return set;
}

static void keepReferenceToSession(RDUserSession *userSession) {
  dispatch_sync(globalQueue(), ^{
    [globalSet() addObject:userSession];
  });
}

static void clearReferenceToSession(RDUserSession *userSession) {
  dispatch_sync(globalQueue(), ^{
    [globalSet() removeObject:userSession];
  });
}

@implementation RDUserSession
{
  NSMutableDictionary *_map;
  dispatch_queue_t _queue;
}

- (instancetype)init
{
  if (self = [super init]) {
    _queue = dispatch_queue_create("com.ocrickard.userSession.serial", DISPATCH_QUEUE_SERIAL);
    _map = [[NSMutableDictionary alloc] init];
    
    keepReferenceToSession(self);
  }
  return self;
}

- (id)objectForKey:(id<NSCopying>)key
   withInitializer:(id (^)(RDUserSession *))initializer
{
  __block id object;
  dispatch_sync(_queue, ^{
    object = _map[key];
  });
  
  if (object) {
    return object;
  }
  
  object = initializer(self);
  
  dispatch_sync(_queue, ^{
    _map[key] = object;
  });
  
  return object;
}

- (void)invalidate
{
  dispatch_sync(_queue, ^{
    _map = nil;
  });
  clearReferenceToSession(self);
}

@end
