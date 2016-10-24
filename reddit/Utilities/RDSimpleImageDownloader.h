//
//  RDSimpleImageDownloader.h
//  OnOne
//
//  Created by Oliver Rickard on 8/7/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ComponentKit/CKNetworkImageDownloading.h>

#import "RDUserSession.h"

@interface RDSimpleImageDownloader : NSObject <CKNetworkImageDownloading>

@end

@interface RDUserSession (RDSimpleImageDownloader)

- (RDSimpleImageDownloader *)imageDownloader;

@end
