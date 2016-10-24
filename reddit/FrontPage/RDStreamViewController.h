//
//  RDFrontPageViewController.h
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDUserSession;
@protocol RDStreamControllerNetworkSource;
@protocol CKComponentProvider;

@interface RDStreamViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title
                networkSource:(id<RDStreamControllerNetworkSource>)networkSource
            componentProvider:(Class<CKComponentProvider>)componentProvider
             componentContext:(id)componentContext
                      session:(RDUserSession *)session;

@end
