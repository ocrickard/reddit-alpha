//
//  RDLinkCommentsComponentProvider.m
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDLinkCommentsComponentProvider.h"

#import "RDCommentViewModel.h"
#import "RDCommentsToolbox.h"
#import "RDCommentComponent.h"

@implementation RDLinkCommentsComponentProvider

+ (CKComponent *)componentForModel:(RDCommentViewModel *)model
                           context:(RDCommentsToolbox *)toolbox
{
  return [RDCommentComponent
          newWithComment:model
          toolbox:toolbox];
}

@end
