//
//  RDArticleSummaryContentComponent.h
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@interface RDExpandingContentComponent : CKCompositeComponent

+ (instancetype)newWithContent:(NSString *)content
                      maxLines:(NSUInteger)maxLines
                 contentAction:(CKComponentAction)action
                viewAttributes:(const CKViewComponentAttributeValueMap &)viewAttributes;

@end
