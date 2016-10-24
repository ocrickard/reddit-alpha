//
//  RDCommentsToolbox.h
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDUserSession;

@interface RDCommentsToolbox : NSObject

+ (instancetype)toolboxWithSession:(RDUserSession *)session;

@property (nonatomic, strong, readonly) RDUserSession *session;

@end
