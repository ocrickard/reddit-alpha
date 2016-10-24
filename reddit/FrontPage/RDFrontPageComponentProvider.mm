//
//  RDFrontPageComponentProvider.m
//  reddit
//
//  Created by Oliver Rickard on 10/13/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDFrontPageComponentProvider.h"

#import "RKLink.h"
#import "RDArticleToolbox.h"
#import "RDArticleSummaryComponent.h"

@implementation RDFrontPageComponentProvider

+ (CKComponent *)componentForModel:(RKLink *)model
                           context:(RDArticleToolbox *)toolbox
{
  return [RDArticleSummaryComponent
          newWithArticle:model
          toolbox:toolbox];
}

@end
