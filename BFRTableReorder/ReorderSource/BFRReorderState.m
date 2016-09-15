//
//  BFRReorderState.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "BFRReorderState.h"

@implementation BFRReorderState

#pragma mark - Initializer
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.state = Ready;
    }
    
    return self;
}
@end
