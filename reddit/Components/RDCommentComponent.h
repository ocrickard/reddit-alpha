//
//  RDCommentComponent.h
//  reddit
//
//  Created by Oliver Rickard on 10/16/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@class RDCommentViewModel;
@class RDCommentsToolbox;

@interface RDCommentComponent : CKCompositeComponent

+ (instancetype)newWithComment:(RDCommentViewModel *)comment
                       toolbox:(RDCommentsToolbox *)toolbox;

@end
