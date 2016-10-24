//
//  RKLink+Hash.m
//  reddit
//
//  Created by Oliver Rickard on 10/9/16.
//  Copyright © 2016 Oliver Rickard. All rights reserved.
//

#import "RKLink+Hash.h"

@implementation RKLink (Hash)

- (NSUInteger)hash
{
  return [[self fullName] hash];
}

@end
