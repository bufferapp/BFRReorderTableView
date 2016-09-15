//
//  BFRReorderTableView.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Dreaming In Binary, LLC. All rights reserved.
//

#import "BFRReorderTableView.h"
#import "BFRReorderController.h"


@implementation BFRReorderTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        self.controller = [[BFRReorderController alloc] initWithTableView:self];
    }
    
    return self;
}

@end
