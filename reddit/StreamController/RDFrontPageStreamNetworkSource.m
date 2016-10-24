//
//  RDFrontPageStreamNetworkSource.m
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDFrontPageStreamNetworkSource.h"

#import <RedditKit/RedditKit.h>

@implementation RDFrontPageStreamNetworkSource

- (void)loadHeadWithPaginationInfo:(RKPagination *)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion
{
  [[RKClient sharedClient] frontPageLinksWithPagination:nil
                                             completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                                               completion(collection, pagination, error);
                                             }];
}

- (void)loadTailWithPaginationInfo:(id)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion
{
  [[RKClient sharedClient] frontPageLinksWithPagination:paginationInfo
                                             completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                                               completion(collection, pagination, error);
                                             }];
}

@end
