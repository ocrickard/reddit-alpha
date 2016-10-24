//
//  RDArticleBylineComponent.m
//  reddit
//
//  Created by Oliver Rickard on 10/9/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDArticleBylineComponent.h"

#import <ComponentKit/CKTextComponent.h>
#import <ComponentKit/CKTextComponentView.h>
#import <DateTools/NSDate+DateTools.h>
#import <ComponentKit/CKTextKitRenderer+TextChecking.h>
#import <ComponentKit/CKTextKitEntityAttribute.h>

#import "RKLink.h"
#import "RDUserSession.h"
#import "RDIntentHandler.h"
#import "RDIntent.h"
#import "RDArticleToolbox.h"

@implementation RDArticleBylineComponent
{
  CKTextComponent *_textComponent;
  RDArticleToolbox *_toolbox;
}

+ (instancetype)newWithArticle:(RKLink *)article
                       toolbox:(RDArticleToolbox *)toolbox
{
  NSString *dateString = [NSString stringWithFormat:@"Submitted %@ by ", [article.created timeAgoSinceNow]];

  NSMutableAttributedString *byline =
  [[NSMutableAttributedString alloc]
   initWithString:dateString
   attributes:@{
                NSFontAttributeName :
                  [UIFont systemFontOfSize:[UIFont systemFontSize] - 5],
                NSForegroundColorAttributeName :
                  [UIColor lightGrayColor]
                }];

  [byline appendAttributedString:
   [[NSAttributedString alloc]
    initWithString:article.author
    attributes:@{
                 NSFontAttributeName :
                   [UIFont systemFontOfSize:[UIFont systemFontSize] - 5],
                 NSForegroundColorAttributeName :
                   [UIColor colorWithRed:0.227 green:0.545 blue:0.733 alpha:1.00],
                 CKTextKitEntityAttributeName :
                   [[CKTextKitEntityAttribute alloc] initWithEntity:article.author]
                 }]];

  CKTextComponent *const textComponent =
  [CKTextComponent
   newWithTextAttributes:{
     .attributedString = byline
   }
   viewAttributes:{
     CKComponentActionAttribute(@selector(handleUsername:event:),
                                CKUIControlEventTextViewDidEndHighlightingText)
   }
   options:{}
   size:{}];

  RDArticleBylineComponent *c = [super
          newWithComponent:
          textComponent];

  if (c) {
    c->_textComponent = textComponent;
    c->_toolbox = toolbox;
  }

  return c;
}

- (void)handleUsername:(CKTextComponent *)textComponent
                 event:(UIEvent *)event
{
  CKTextComponentView *textView = (CKTextComponentView *)textComponent.viewContext.view;
  CGPoint point = [event.allTouches.anyObject locationInView:textView];

  NSTextCheckingResult *result = [textView.renderer textCheckingResultAtPoint:point];
  if (result.resultType == CKTextKitTextCheckingTypeEntity) {
    CKTextKitTextCheckingResult *entityResult = (CKTextKitTextCheckingResult *)result;
    RDIntent *intent = [[RDIntent alloc] init];
    intent.target = entityResult.entityAttribute.entity;
    [_toolbox.session.intentHandler handleIntent:intent];
  }
}

@end
