//
//  RDCommentViewModel.h
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKThing;

@interface RDCommentViewModel : NSObject <NSCopying>

- (instancetype)initWithModel:(RKThing *)model
             indentationLevel:(NSUInteger)indentationLevel;

@property (nonatomic, strong, readonly) RKThing *model;
@property (nonatomic, assign, readonly) NSUInteger indentationLevel;

@end
