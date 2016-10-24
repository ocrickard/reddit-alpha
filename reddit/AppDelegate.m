//
//  AppDelegate.m
//  reddit
//
//  Created by Oliver Rickard on 10/8/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "AppDelegate.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "RDUserSession.h"
#import "RDStreamViewController.h"
#import "RDFrontPageStreamNetworkSource.h"
#import "RDFrontPageComponentProvider.h"
#import "RDLinkCommentsComponentProvider.h"
#import "RDArticleToolbox.h"
#import "RDIntent.h"
#import "RDIntentHandler.h"
#import "RDCommentsToolbox.h"
#import "RDCommentStreamNetworkSource.h"
#import "RKComment.h"
#import "RKLink.h"

@interface AppDelegate ()

@property (nonatomic, strong) RDStreamViewController *frontPageViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) RDUserSession *session;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
  [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs

  DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
  fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
  [DDLog addLogger:fileLogger];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.session = [[RDUserSession alloc] init];
  self.frontPageViewController = [[RDStreamViewController alloc] initWithTitle:@"Front Page"
                                                                 networkSource:[RDFrontPageStreamNetworkSource new]
                                                             componentProvider:[RDFrontPageComponentProvider class]
                                                              componentContext:[RDArticleToolbox toolboxWithSession:self.session]
                                                                       session:self.session];
  self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.frontPageViewController];
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];

  __weak __typeof(self) weakSelf = self;
  [self.session.intentHandler registerIntentTarget:^BOOL(RDIntent *intent) {
    return [intent.target isKindOfClass:[RKLink class]];
  } handleIntentBlock:^(RDIntent *intent) {
    RKLink *link = (RKLink *)intent.target;
    RDStreamViewController *linkViewController =
    [[RDStreamViewController alloc]
     initWithTitle:link.title
     networkSource:[[RDCommentStreamNetworkSource alloc] initWithArticle:link]
     componentProvider:[RDLinkCommentsComponentProvider class]
     componentContext:[RDCommentsToolbox toolboxWithSession:weakSelf.session]
     session:weakSelf.session];
    [weakSelf.navigationController pushViewController:linkViewController
                                             animated:YES];
  }];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
