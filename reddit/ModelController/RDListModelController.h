//
//  RDListModelController.h
//  OnOne
//
//  Created by Oliver Rickard on 8/16/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDListModelController;
@class RDUserSession;
@class RDListModelControllerPersistenceCoordinator;

@protocol RDListModelControllerDelegate <NSObject>

- (void)listModelController:(RDListModelController *)modelController
     insertedItemsAtIndices:(NSIndexSet *)inserted
      removedItemsAtIndices:(NSIndexSet *)removed
     reloadedItemsAtIndices:(NSIndexSet *)reloaded
              originalItems:(NSOrderedSet *)items
                   userInfo:(NSDictionary *)userInfo;

@end

@interface RDListModelController : NSObject

- (instancetype)initWithUserSession:(RDUserSession *)userSession
             persistenceCoordinator:(RDListModelControllerPersistenceCoordinator *)persistenceCoordinator;

@property (nonatomic, copy) NSOrderedSet *items;

@property (nonatomic, weak) id<RDListModelControllerDelegate> delegate;

- (void)setItems:(NSOrderedSet *)items
        userInfo:(NSDictionary *)userInfo;

@end
