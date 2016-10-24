//
//  RDSubredditStreamNetworkSource.m
//  reddit
//
//  Created by Oliver Rickard on 10/13/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDSubredditStreamNetworkSource.h"

@implementation RDSubredditStreamNetworkSource
{
  NSString *_subreddit;
  RKSubredditCategory _category;
}

- (instancetype)initWithSubreddit:(NSString *)subreddit
                         category:(RKSubredditCategory)category
{
  if (self = [super init]) {
    _subreddit = [subreddit copy];
    _category = category;
  }
  return self;
}

- (void)loadHeadWithPaginationInfo:(RKPagination *)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion
{
  [[RKClient sharedClient] linksInSubredditWithName:_subreddit
                                           category:_category
                                         pagination:nil
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
