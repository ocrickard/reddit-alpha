//
//  RDListModelControllerPersistenceCoordinator.h
//  OnOne
//
//  Created by Oliver Rickard on 10/25/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDDiskCache;

typedef void (^RDListModelControllerPersistenceCoordinatorRestoreBlock)(NSOrderedSet *items, NSError *error);

@interface RDListModelControllerPersistenceCoordinator : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier
                         diskCache:(RDDiskCache *)diskCache;

- (void)persistItems:(NSOrderedSet *)items;

- (void)restoreItems:(RDListModelControllerPersistenceCoordinatorRestoreBlock)block;

@end
