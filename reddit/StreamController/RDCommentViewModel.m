//
//  RDCommentViewModel.m
//  reddit
//
//  Created by Oliver Rickard on 10/23/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RDCommentViewModel.h"

@implementation RDCommentViewModel

- (instancetype)initWithModel:(RKThing *)model
             indentationLevel:(NSUInteger)indentationLevel
{
  if (self = [super init]) {
    _model = model;
    _indentationLevel = indentationLevel;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  // Immutable
  return self;
}

@end
