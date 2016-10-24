//
//  RDIntentHandler.h
//  OnOne
//
//  Created by Oliver Rickard on 9/19/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDUserSession.h"

@class RDIntent;

typedef BOOL(^RDIntentHandlerCanHandleTargetBlock)(RDIntent *intent);
typedef void(^RDIntentHandlerHandleIntentBlock)(RDIntent *intent);

@interface RDIntentHandler : NSObject

- (void)handleIntent:(RDIntent *)intent;

- (id)registerIntentTarget:(RDIntentHandlerCanHandleTargetBlock)canHandleBlock
         handleIntentBlock:(RDIntentHandlerHandleIntentBlock)handleIntentBlock;

- (void)removeIntentTarget:(id)intentTargetHandle;

@end

@interface RDUserSession (RDIntentHandler)

- (RDIntentHandler *)intentHandler;

@end
