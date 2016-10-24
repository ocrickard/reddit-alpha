//
//  RDCommentContentComponent.m
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDCommentContentComponent.h"

#import <ComponentKit/CKTextComponent.h>
#import <ComponentKit/CKStackLayoutComponent.h>

#import "RKComment.h"
#import "RDExpandingContentComponent.h"

@implementation RDCommentContentComponent

+ (instancetype)newWithComment:(RKComment *)comment
                       toolbox:(RDCommentsToolbox *)toolbox
{
  return
  [super
   newWithComponent:
   [CKStackLayoutComponent
    newWithView:{}
    size:{}
    style:{
      .direction = CKStackLayoutDirectionVertical,
      .spacing = 2
    }
    children:{
      {[CKLabelComponent
        newWithLabelAttributes:{
          .string = comment.author,
          .color = [UIColor lightGrayColor],
          .font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize] - 5]
        }
        viewAttributes:{
          {@selector(setBackgroundColor:), [UIColor clearColor]}
        }
        size:{}]},
      {[RDExpandingContentComponent
        newWithContent:comment.body
        maxLines:10
        contentAction:NULL
        viewAttributes:{
          {@selector(setBackgroundColor:), [UIColor clearColor]}
        }]}
    }]
   ];
}

@end
