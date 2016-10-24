//
//  RDArticleToolbox.m
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDArticleToolbox.h"

@implementation RDArticleToolbox

+ (instancetype)toolboxWithSession:(RDUserSession *)session
{
  RDArticleToolbox *toolbox = [RDArticleToolbox new];
  if (toolbox) {
    toolbox->_session = session;
  }
  return toolbox;
}

@end
