//
//  RDCommentContentComponent.h
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@class RDCommentsToolbox;
@class RKComment;

@interface RDCommentContentComponent : CKCompositeComponent

+ (instancetype)newWithComment:(RKComment *)comment
                       toolbox:(RDCommentsToolbox *)toolbox;

@end
