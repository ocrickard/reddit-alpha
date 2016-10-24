//
//  RDArticleSummaryComponent.m
//  OnOne
//
//  Created by Oliver Rickard on 9/19/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import "RDArticleSummaryComponent.h"

#import <ComponentKit/CKInsetComponent.h>
#import <ComponentKit/CKStackLayoutComponent.h>
#import <ComponentKit/CKLabelComponent.h>
#import <ComponentKit/CKImageComponent.h>
#import <ComponentKit/CKInternalHelpers.h>
#import <ComponentKit/CKComponentGestureActions.h>
#import <ComponentKit/CKNetworkImageComponent.h>

#import <DateTools/NSDate+DateTools.h>

#import "RKLink.h"
#import "RDSimpleImageDownloader.h"
#import "RDUserSession.h"
#import "RDIntent.h"
#import "RDIntentHandler.h"
#import "RDArticleBylineComponent.h"
#import "RDArticleToolbox.h"
#import "RDExpandingContentComponent.h"

@implementation RDArticleSummaryComponent
{
  RKLink *_article;
  RDArticleToolbox *_toolbox;
}

+ (instancetype)newWithArticle:(RKLink *)article
                       toolbox:(RDArticleToolbox *)toolbox
{
  RDArticleSummaryComponent *c =
  [super
   newWithComponent:
   [CKStackLayoutComponent
    newWithView:{
      [UIView class],
      {
        {@selector(setUserInteractionEnabled:), @YES},
        {@selector(setBackgroundColor:), [UIColor whiteColor]},
        CKComponentTapGestureAttribute(@selector(didTap:))
      }
    }
    size:{}
    style:{
      .direction = CKStackLayoutDirectionVertical,
      .alignItems = CKStackLayoutAlignItemsStretch,
    }
    children:{
      {[CKInsetComponent
        newWithInsets:{
          .top = 14,
          .bottom = 14,
          .left = 12,
          .right = 12,
        }
        component:
        [CKStackLayoutComponent
         newWithView:{}
         size:{}
         style:{
           .direction = CKStackLayoutDirectionVertical,
           .alignItems = CKStackLayoutAlignItemsStretch,
           .spacing = 6,
         }
         children:{
           {[CKLabelComponent
             newWithLabelAttributes:{
               .string = [article.subreddit uppercaseString],
               .font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize] - 5],
               .color = [UIColor lightGrayColor],
             }
             viewAttributes:{
               {@selector(setUserInteractionEnabled:), @NO},
             }
             size:{}]},
           {[CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
               .direction = CKStackLayoutDirectionHorizontal,
               .alignItems = CKStackLayoutAlignItemsStretch,
               .spacing = 6,
             }
             children:{
               {[CKStackLayoutComponent
                 newWithView:{}
                 size:{}
                 style:{
                   .direction = CKStackLayoutDirectionVertical,
                   .alignItems = CKStackLayoutAlignItemsStretch,
                   .spacing = 6,
                 }
                 children:{
                   {[RDExpandingContentComponent
                     newWithContent:article.title
                     maxLines:4
                     contentAction:@selector(didTap:)
                     viewAttributes:{}]},
                   {[RDArticleBylineComponent
                     newWithArticle:article
                     toolbox:toolbox],
                     .flexShrink = YES
                   }
                 }],
                 .flexGrow = YES,
                 .flexShrink = YES},
               {article.thumbnailURL ?
                 [CKNetworkImageComponent
                  newWithURL:article.thumbnailURL
                  imageDownloader:toolbox.session.imageDownloader
                  scenePath:nil
                  size:{.width = CKRelativeDimension::Percent(0.2)}
                  options:{}
                  attributes:{
                    {@selector(setContentMode:), @(UIViewContentModeScaleAspectFit)},
                    {@selector(setClipsToBounds:), @YES},
                  }] : nil},
             }]}
         }]]},
         {[CKComponent
           newWithView:{
             [UIView class],
             {
               {@selector(setBackgroundColor:), [UIColor colorWithWhite:0.98 alpha:1]}
             }
           }
           size:{
             .height = 10,
           }]}
         }]];
        if (c) {
    c->_article = article;
    c->_toolbox = toolbox;
  }
  return c;
}

- (void)didTap:(id)sender
{
  RDIntent *intent = [[RDIntent alloc] init];
  intent.target = _article;
  [_toolbox.session.intentHandler handleIntent:intent];
}

@end
