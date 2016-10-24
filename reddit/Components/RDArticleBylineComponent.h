//
//  RDArticleBylineComponent.h
//  reddit
//
//  Created by Oliver Rickard on 10/9/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/CKCompositeComponent.h>

@class RKLink;
@class RDArticleToolbox;

@interface RDArticleBylineComponent : CKCompositeComponent

+ (instancetype)newWithArticle:(RKLink *)article
                       toolbox:(RDArticleToolbox *)toolbox;

@end
