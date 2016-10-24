//
//  RDUserSession.h
//  OnOne
//
//  Created by Oliver Rickard on 8/7/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A user session is meant to represent the current usage session of the application.  It contains user- or navigation-
 specific controllers.
 
 Session objects remain alive until explicit invalidation, at which point all contained objects are deallocated and all
 future calls to objectForKey:withInitializer: will return nil.
 */
@interface RDUserSession : NSObject

- (id)objectForKey:(id<NSCopying>)key
   withInitializer:(id (^)(RDUserSession *session))initializer;

- (void)invalidate;

@end
