//
//  RDConsistentModelCache.h
//  OnOne
//
//  Created by Oliver Rickard on 8/29/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDUserSession.h"

@protocol RDConsistenModelCacheObserver <NSObject>

- (void)modelDidUpdate:(NSObject<NSCopying> *)newModel
              userInfo:(NSDictionary *)userInfo;

@end

@interface RDConsistentModelCache : NSObject

- (void)addObserver:(id<RDConsistenModelCacheObserver>)observer forModel:(NSObject<NSCopying> *)modelObject;
- (void)removeObserver:(id<RDConsistenModelCacheObserver>)observer forModel:(NSObject<NSCopying> *)modelObject;

- (void)updateModel:(NSObject<NSCopying> *)modelObject
           userInfo:(NSDictionary *)userInfo;

@end

@interface RDUserSession (RDConsistentModelCache)

- (RDConsistentModelCache *)consistentModelCache;

@end
