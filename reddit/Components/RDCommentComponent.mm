//
//  RDCommentComponent.m
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDCommentComponent.h"

#import <ComponentKit/CKInternalHelpers.h>

#import "RKMoreComments.h"
#import "RDCommentViewModel.h"
#import "RKComment.h"
#import "RDMoreCommentComponent.h"
#import "RDCommentContentComponent.h"

@implementation RDCommentComponent

+ (instancetype)newWithComment:(RDCommentViewModel *)comment
                       toolbox:(RDCommentsToolbox *)toolbox
{
  RDCommentComponent *c =
  [super
   newWithComponent:
   [CKStackLayoutComponent
    newWithView:{
      [UIView class],
      {
        {@selector(setUserInteractionEnabled:), @YES},
        {@selector(setBackgroundColor:), [UIColor colorWithWhite:MIN(1.0 - comment.indentationLevel * 0.01, 1.0)
                                                           alpha:1]}
      }
    }
    size:{}
    style:{
      .direction = CKStackLayoutDirectionVertical,
      .alignItems = CKStackLayoutAlignItemsStretch,
    }
    children:{
      {[CKComponent
           newWithView:{
             [UIView class],
             {
               {@selector(setBackgroundColor:), (comment.indentationLevel == 0
                                                 ? [UIColor grayColor]
                                                 : [UIColor whiteColor])}
             }
           }
           size:{
             .height = CKFloorPixelValue(0.51),
           }]},
      {[CKInsetComponent
        newWithInsets:{
          .top = (CGFloat)(comment.indentationLevel == 0 ? 14 : 6),
          .bottom = (CGFloat)(comment.indentationLevel == 0 ? 14 : 6),
          .left = (CGFloat)(12.0 + comment.indentationLevel * 10.0),
          .right = 12,
        }
        component:
        [comment.model isKindOfClass:[RKComment class]]
        ? [RDCommentContentComponent
           newWithComment:(RKComment *)comment.model
           toolbox:toolbox]
        : [RDMoreCommentComponent
           newWithMoreComments:(RKMoreComments *)comment.model
           toolbox:toolbox]
        ]}
    }]];
  if (c) {

  }
  return c;
}

@end
