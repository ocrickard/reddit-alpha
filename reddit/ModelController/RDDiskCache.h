//
//  RDDiskCache.h
//  OnOne
//
//  Created by Oliver Rickard on 10/25/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RDUserSession.h"

typedef NS_ENUM(NSInteger, RDDiskCacheMode) {
  RDDiskCacheModeSynchronous,
  RDDiskCacheModeAsynchronous,
};

typedef NS_ENUM(NSInteger, RDDiskCacheStoreLocation) {
  RDDiskCacheStoreLocationDocuments,
  RDDiskCacheStoreLocationCaches,
  RDDiskCacheStoreLocationTemp,
};

typedef void (^RDDiskCacheStoreCompletionBlock)(BOOL success, NSError *error);
typedef void (^RDDiskCacheFetchCompletionBlock)(NSData *data, NSError *error);

@interface RDDiskCache : NSObject

- (instancetype)initWithCacheIdentifier:(NSString *)cacheIdentifier
                          storeLocation:(RDDiskCacheStoreLocation)storeLocation
                            maximumBytes:(NSUInteger)maximumBytes;

@property (nonatomic, copy, readonly) NSString *cacheIdentifier;
@property (nonatomic, assign, readonly) RDDiskCacheStoreLocation storeLocation;

- (void)storeData:(NSData *)data
           forKey:(NSString *)key
             mode:(RDDiskCacheMode)mode
       completion:(RDDiskCacheStoreCompletionBlock)completionBlock;

- (void)fetchDataForKey:(NSString *)key
                   mode:(RDDiskCacheMode)mode
             completion:(RDDiskCacheFetchCompletionBlock)completionBlock;

- (void)removeDataForKey:(NSString *)key;

- (void)eraseAllData;

@end

@interface RDUserSession (RDDiskCache)

- (RDDiskCache *)documentsDiskCache;
- (RDDiskCache *)cachesDiskCache;

@end
