//
//  RDArticleSummaryComponent.h
//  OnOne
//
//  Created by Oliver Rickard on 9/19/15.
//  Copyright © 2015 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/CKCompositeComponent.h>

@class RKLink;
@class RDArticleToolbox;

@interface RDArticleSummaryComponent : CKCompositeComponent

+ (instancetype)newWithArticle:(RKLink *)link
                       toolbox:(RDArticleToolbox *)toolbox;

@end
