//
//  RDMoreCommentComponent.h
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@class RKMoreComments;
@class RDCommentsToolbox;

@interface RDMoreCommentComponent : CKCompositeComponent

+ (instancetype)newWithMoreComments:(RKMoreComments *)moreComments
                            toolbox:(RDCommentsToolbox *)toolbox;

@end
