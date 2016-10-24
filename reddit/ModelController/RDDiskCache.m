//
//  RDDiskCache.m
//  OnOne
//
//  Created by Oliver Rickard on 10/25/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDDiskCache.h"

@interface RDDiskCacheFile : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) NSDate *lastModificationDate;

@end

@implementation RDDiskCacheFile

- (NSString *)description
{
  return [NSString stringWithFormat:@"<RDDiskCacheFile path=%@ size=%lu lastModificationDate=%@", _path, (unsigned long)_size, _lastModificationDate];
}

@end

static NSString *rootPathForCache(NSString *cacheIdentifier, RDDiskCacheStoreLocation storeLocation)
{
  NSString *rootPath;
  switch (storeLocation) {
    case RDDiskCacheStoreLocationDocuments:
    {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      NSCAssert(paths.count > 0, @"Received empty paths for documents directory");
      rootPath = [paths objectAtIndex:0];
      break;
    }
    case RDDiskCacheStoreLocationCaches:
    {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
      NSCAssert(paths.count > 0, @"Received empty paths for caches directory");
      rootPath = [paths objectAtIndex:0];
      break;
    }
    case RDDiskCacheStoreLocationTemp:
    {
      rootPath = NSTemporaryDirectory();
      break;
    }
  }
  return [rootPath stringByAppendingPathComponent:cacheIdentifier];
}

static NSString *filePathFromKey(NSString *key, NSString *cacheIdentifier, RDDiskCacheStoreLocation storeLocation)
{
  NSString *rootPath = rootPathForCache(cacheIdentifier, storeLocation);
  return [[rootPath stringByAppendingPathComponent:key] stringByAppendingPathExtension:@"data"];
}

@implementation RDDiskCache
{
  NSCache *_memoryCache;
  dispatch_queue_t _ioQueue;
  NSUInteger _maximumBytes;
}

- (instancetype)initWithCacheIdentifier:(NSString *)cacheIdentifier
                          storeLocation:(RDDiskCacheStoreLocation)storeLocation
                           maximumBytes:(NSUInteger)maximumBytes
{
  if (self = [super init]) {
    NSAssert(cacheIdentifier.length > 0, @"Empty cache identifier not allowed");
    _ioQueue = dispatch_queue_create("com.ocrickard.onOne.diskCache.io.concurrent", DISPATCH_QUEUE_CONCURRENT);
    _memoryCache = [[NSCache alloc] init];
    _memoryCache.totalCostLimit = 1024 * 1024 * 4; // 4MB default in-memory cache size
    _cacheIdentifier = [cacheIdentifier copy];
    _storeLocation = storeLocation;
    _maximumBytes = maximumBytes;

    NSString *rootPath = rootPathForCache(_cacheIdentifier, _storeLocation);
    BOOL isDirectory = NO;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:rootPath
                                                           isDirectory:&isDirectory];
    if (!pathExists) {
      NSError *error = nil;
      [[NSFileManager defaultManager] createDirectoryAtPath:rootPath
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];
      if (error) {
        DDLogError(@"Error creating base directory for cache:%@", error);
      }
    } else if (!isDirectory) {
      NSAssert(NO, @"cache root path is not a directory:%@", rootPath);
    }

    [self _scheduleMaintenance];
  }
  return self;
}

- (void)storeData:(NSData *)data
           forKey:(NSString *)key
             mode:(RDDiskCacheMode)mode
       completion:(RDDiskCacheStoreCompletionBlock)completionBlock
{
  NSAssert(key.length > 0, @"Empty key is not allowed");
  NSString *path = filePathFromKey(key, _cacheIdentifier, _storeLocation);
  if (data) {
    [_memoryCache setObject:data forKey:path cost:[data length]];
  } else {
    [_memoryCache removeObjectForKey:path];
  }
  if (mode == RDDiskCacheModeSynchronous) {
    NSError *error = nil;
    BOOL success = NO;
    if (data) {
      success = [data writeToFile:path options:NSDataWritingAtomic error:&error];
    } else {
      success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    completionBlock(success, error);
  } else {
    dispatch_async(_ioQueue, ^{
      NSError *error = nil;
      BOOL success = NO;
      if (data) {
        success = [data writeToFile:path options:NSDataWritingAtomic error:&error];
      } else {
        success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(success, error);
      });
    });
  }
}

- (void)fetchDataForKey:(NSString *)key
                   mode:(RDDiskCacheMode)mode
             completion:(RDDiskCacheFetchCompletionBlock)completionBlock
{
  NSString *path = filePathFromKey(key, _cacheIdentifier, _storeLocation);
  if (mode == RDDiskCacheModeSynchronous) {
    NSData *cached = [_memoryCache objectForKey:path];
    if (cached) {
      completionBlock(cached, nil);
      return;
    }
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path
                                          options:NSDataReadingMappedIfSafe
                                            error:&error];
    completionBlock(data, error);
  } else {
    dispatch_async(_ioQueue, ^{
      NSData *cached = [_memoryCache objectForKey:path];
      if (cached) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completionBlock(cached, nil);
        });
        return;
      }
      NSError *error = nil;
      NSData *data = [NSData dataWithContentsOfFile:path
                                            options:NSDataReadingMappedIfSafe
                                              error:&error];
      dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(data, error);
      });
    });
  }
}

- (void)removeDataForKey:(NSString *)key
{
  dispatch_async(_ioQueue, ^{
    NSString *path = filePathFromKey(key, _cacheIdentifier, _storeLocation);
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
  });
}

static NSArray *allFilesForCache(NSString *cacheIdentifier, RDDiskCacheStoreLocation storeLocation)
{
  NSString *rootPath = rootPathForCache(cacheIdentifier, storeLocation);
  return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:NULL];
}

- (void)eraseAllData
{
  dispatch_async(_ioQueue, ^{
    NSArray *allFiles = allFilesForCache(_cacheIdentifier, _storeLocation);
    for (NSString *filePath in allFiles) {
      [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
  });
}

static NSUInteger residentBytesForCache(NSString *cacheIdentifier, RDDiskCacheStoreLocation storeLocation)
{
  NSString *rootPath = rootPathForCache(cacheIdentifier, storeLocation);
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
  NSString *path = nil;
  NSUInteger residentBytes = 0;
  while ((path = [enumerator nextObject])) {
    residentBytes += [[enumerator fileAttributes][NSFileSize] integerValue];
  }
  return residentBytes;
}

static void deleteOldestFilesUntilUnderMaximumBytes(NSString *cacheIdentifier, RDDiskCacheStoreLocation storeLocation, NSUInteger maximumBytes)
{
  NSString *rootPath = rootPathForCache(cacheIdentifier, storeLocation);
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
  NSString *path = nil;
  NSMutableArray *files = [NSMutableArray array];
  NSUInteger residentBytes = 0;
  while ((path = [enumerator nextObject])) {
    NSUInteger size = [[enumerator fileAttributes][NSFileSize] integerValue];
    RDDiskCacheFile *file = [[RDDiskCacheFile alloc] init];
    file.path = [rootPath stringByAppendingPathComponent:path];
    file.size = size;
    file.lastModificationDate = [enumerator fileAttributes][NSFileModificationDate];
    [files addObject:file];
    residentBytes += size;
  }
  [files sortUsingComparator:^NSComparisonResult(RDDiskCacheFile *obj1, RDDiskCacheFile *obj2) {
    // Sorted in ascending order by date to leave oldest files at the front.
    return [obj1.lastModificationDate compare:obj2.lastModificationDate];
  }];
  DDLogVerbose(@"Culling old items for cache:%@. Initial size:%d", cacheIdentifier, residentBytes);
  while (residentBytes > maximumBytes && files.count > 0) {
    RDDiskCacheFile *firstItem = [files firstObject];
    [[NSFileManager defaultManager] removeItemAtPath:firstItem.path error:NULL];
    residentBytes -= firstItem.size;
    [files removeObjectAtIndex:0];
  }
  DDLogVerbose(@"Finished culling old items for cache:%@. Final size:%d", cacheIdentifier, residentBytes);
}

- (void)_scheduleMaintenance
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), _ioQueue, ^{
    NSUInteger residentBytes = residentBytesForCache(_cacheIdentifier, _storeLocation);
    DDLogVerbose(@"Disk cache resident size:%d", residentBytes);

    if (residentBytes > _maximumBytes) {
      // Find the oldest files in the cache, and delete until we are under the limit.
      deleteOldestFilesUntilUnderMaximumBytes(_cacheIdentifier, _storeLocation, _maximumBytes);
    }
  });
}

@end

@implementation RDUserSession (RDDiskCache)

- (RDDiskCache *)documentsDiskCache
{
  return [self objectForKey:@"documentsDiskCache" withInitializer:^id(RDUserSession *session) {
    return [[RDDiskCache alloc] initWithCacheIdentifier:@"cache"
                                          storeLocation:RDDiskCacheStoreLocationDocuments
                                           maximumBytes:NSUIntegerMax];
  }];
}

- (RDDiskCache *)cachesDiskCache
{
  return [self objectForKey:@"cachesDiskCache" withInitializer:^id(RDUserSession *session) {
    return [[RDDiskCache alloc] initWithCacheIdentifier:@"cache"
                                          storeLocation:RDDiskCacheStoreLocationCaches
                                           maximumBytes:NSUIntegerMax];
  }];
}

@end
