//
//  RDMoreCommentComponent.m
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDMoreCommentComponent.h"

#import <ComponentKit/CKTextComponent.h>

#import "RKMoreComments.h"

@implementation RDMoreCommentComponent
{
  RDCommentsToolbox *_toolbox;
}

+ (instancetype)newWithMoreComments:(RKMoreComments *)moreComments
                            toolbox:(RDCommentsToolbox *)toolbox
{
  RDMoreCommentComponent *c =
  [super newWithComponent:
   [CKTextComponent
    newWithTextAttributes:{
      .attributedString = [[NSAttributedString alloc]
                           initWithString:
                           [NSString stringWithFormat:
                            @"%d more comments", moreComments.children.count]
                           attributes:@{
                                        NSForegroundColorAttributeName : [UIColor grayColor]
                                        }]
    }
    viewAttributes:{
      {@selector(setBackgroundColor:), [UIColor clearColor]}
    }
    options:{}
    size:{}]];
  if (c) {
    c->_toolbox = toolbox;
  }
  return c;
}

@end
