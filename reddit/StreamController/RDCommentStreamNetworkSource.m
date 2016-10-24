//
//  RDCommentStreamNetworkSource.m
//  reddit
//
//  Created by Oliver Rickard on 10/13/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDCommentStreamNetworkSource.h"

#import "RDCommentViewModel.h"
#import "RKComment.h"
#import "RKMoreComments.h"

@implementation RDCommentStreamNetworkSource
{
  RKLink *_link;
}

- (instancetype)initWithArticle:(RKLink *)link
{
  if (self = [super init]) {
    _link = link;
  }
  return self;
}

static void processCommentArray(NSArray *models, NSMutableArray *array, NSUInteger indentationLevel) {
  for (RKThing *model in models) {
    [array addObject:[[RDCommentViewModel alloc] initWithModel:model
                                              indentationLevel:indentationLevel]];
    if ([model isKindOfClass:[RKComment class]]) {
      RKComment *comment = (RKComment *)model;
      processCommentArray(comment.replies, array, indentationLevel + 1);
    }
  }
}

- (void)loadHeadWithPaginationInfo:(RKPagination *)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion
{
  [[RKClient sharedClient] commentsForLink:_link
                                completion:^(NSArray *collection, NSError *error) {
                                  NSMutableArray *processed = [NSMutableArray array];
                                  processCommentArray(collection, processed, 0);
                                  completion(processed, nil, error);
                                }];
}

- (void)loadTailWithPaginationInfo:(id)paginationInfo
                        completion:(RDStreamControllerNetworkSourceCompletionBlock)completion
{
  completion(nil, nil, nil);
}

@end
