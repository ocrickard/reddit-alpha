//
//  RDSubredditStreamNetworkSource.h
//  reddit
//
//  Created by Oliver Rickard on 10/13/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RedditKit/RedditKit.h>

#import "RDStreamController.h"

@interface RDSubredditStreamNetworkSource : NSObject <RDStreamControllerNetworkSource>

- (instancetype)initWithSubreddit:(NSString *)subreddit
                         category:(RKSubredditCategory)category;

@end
