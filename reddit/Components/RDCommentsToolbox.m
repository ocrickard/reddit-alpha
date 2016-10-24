//
//  RDCommentsToolbox.m
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDCommentsToolbox.h"

@implementation RDCommentsToolbox

+ (instancetype)toolboxWithSession:(RDUserSession *)session
{
  RDCommentsToolbox *toolbox = [RDCommentsToolbox new];
  if (toolbox) {
    toolbox->_session = session;
  }
  return toolbox;
}

@end
