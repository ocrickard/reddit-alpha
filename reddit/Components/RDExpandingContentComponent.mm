//
//  RDArticleSummaryContentComponent.m
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDExpandingContentComponent.h"

#import <ComponentKit/CKComponentSubclass.h>
#import <ComponentKit/CKTextComponent.h>
#import <ComponentKit/CKTextComponentView.h>
#import <ComponentKit/CKTextKitRenderer+TextChecking.h>

@implementation RDExpandingContentComponent
{
  CKComponentAction _action;
}

+ (id)initialState
{
  return @YES;
}

+ (instancetype)newWithContent:(NSString *)content
                      maxLines:(NSUInteger)maxLines
                 contentAction:(CKComponentAction)action
                viewAttributes:(const CKViewComponentAttributeValueMap &)viewAttributes
{
  CKComponentScope scope(self);

  const BOOL truncate = [scope.state() boolValue];

  CKViewComponentAttributeValueMap copiedMap = viewAttributes;
  copiedMap.insert(CKComponentActionAttribute(@selector(handleTruncation:event:),
                                                   CKUIControlEventTextViewDidEndHighlightingText));
  copiedMap.insert(CKComponentActionAttribute(@selector(handleTouchUp:event:),
                                              UIControlEventTouchUpInside));

  RDExpandingContentComponent *c = [RDExpandingContentComponent
          newWithComponent:
          [CKTextComponent
           newWithTextAttributes:{
             .attributedString =
             [[NSAttributedString alloc]
              initWithString:content
              attributes:@{}],
             .truncationAttributedString =
             (truncate
              ? truncationString()
              : nil),
             .maximumNumberOfLines =
             (NSUInteger)(truncate ? maxLines : 0),
             .lineBreakMode = NSLineBreakByWordWrapping,
           }
           viewAttributes:std::move(copiedMap)
           options:{}
           size:{}]];
  if (c) {
    c->_action = action;
  }
  return c;
}

- (void)handleTruncation:(CKTextComponent *)textComponent
                   event:(UIEvent *)event
{
  CKTextComponentView *textView = (CKTextComponentView *)textComponent.viewContext.view;
  CGPoint point = [event.allTouches.anyObject locationInView:textView];

  NSTextCheckingResult *result = [textView.renderer textCheckingResultAtPoint:point];
  if (result.resultType == CKTextKitTextCheckingTypeTruncation) {
    [self updateState:^id(id) {
      return @(NO);
    } mode:CKUpdateModeSynchronous];
  }
}

- (void)handleTouchUp:(CKTextComponent *)textComponent
                event:(UIEvent *)event
{
  CKTextComponentView *textView = (CKTextComponentView *)textComponent.viewContext.view;
  CGPoint point = [event.allTouches.anyObject locationInView:textView];

  NSTextCheckingResult *result = [textView.renderer textCheckingResultAtPoint:point];
  if (result == nil && _action != NULL) {
    CKComponentActionSend(_action, self);
  }
}

static NSAttributedString *truncationString(void) {
  static dispatch_once_t onceToken;
  static NSAttributedString *str;
  dispatch_once(&onceToken, ^{
    NSMutableAttributedString *mut = [NSMutableAttributedString new];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"... "]];
    [mut appendAttributedString:[[NSAttributedString alloc]
                                 initWithString:@"Continue Reading"
                                 attributes:@{
                                              NSForegroundColorAttributeName : [UIColor grayColor],
                                              CKTextKitTruncationAttributeName : @YES
                                              }]];
    str = [mut copy];
  });
  return str;
}

@end
