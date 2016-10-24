//
//  RDIntentHandler.m
//  OnOne
//
//  Created by Oliver Rickard on 9/19/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDIntentHandler.h"

#import "RDIntent.h"

@interface RDIntentHandlerTarget : NSObject

@property (nonatomic, copy) RDIntentHandlerCanHandleTargetBlock canHandleBlock;
@property (nonatomic, copy) RDIntentHandlerHandleIntentBlock handleIntentBlock;

@end

@implementation RDIntentHandlerTarget

@end

@implementation RDIntentHandler
{
  NSMutableDictionary<NSString *, RDIntentHandlerTarget *> *_targets;
}

- (instancetype)init
{
  if (self = [super init]) {
    _targets = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)handleIntent:(RDIntent *)intent
{
  __block BOOL foundTarget = NO;
  [_targets enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RDIntentHandlerTarget * _Nonnull target, BOOL * _Nonnull stop) {
    if (target.canHandleBlock(intent)) {
      target.handleIntentBlock(intent);
      foundTarget = YES;
      *stop = YES;
    }
  }];
  if (!foundTarget) {
    NSLog(@"Unable to handle intent target:%@", intent.target);
  }
}

- (id)registerIntentTarget:(RDIntentHandlerCanHandleTargetBlock)canHandleBlock
         handleIntentBlock:(RDIntentHandlerHandleIntentBlock)handleIntentBlock
{
  RDIntentHandlerTarget *target = [[RDIntentHandlerTarget alloc] init];
  target.canHandleBlock = canHandleBlock;
  target.handleIntentBlock = handleIntentBlock;
  NSString *uuid = [[NSUUID UUID] UUIDString];
  _targets[uuid] = target;
  return uuid;
}

- (void)removeIntentTarget:(id)intentTargetHandle
{
  [_targets removeObjectForKey:intentTargetHandle];
}

@end

@implementation RDUserSession (RDIntentHandler)

- (RDIntentHandler *)intentHandler
{
  return [self objectForKey:@"RDIntentHandler" withInitializer:^id(RDUserSession *session) {
    return [[RDIntentHandler alloc] init];
  }];
}

@end
