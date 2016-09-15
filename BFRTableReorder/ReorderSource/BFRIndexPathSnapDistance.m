//
//  BFRIndexPathSnapDistance.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "BFRIndexPathSnapDistance.h"

@implementation BFRIndexPathSnapDistance

#pragma mark - Initializer
- (instancetype)initWithPath:(NSIndexPath *)path distance:(CGFloat)distance {
    self = [super init];
    
    if (self) {
        self.indexPath = path;
        self.distance = distance;
    }
    
    return self;
}

@end
