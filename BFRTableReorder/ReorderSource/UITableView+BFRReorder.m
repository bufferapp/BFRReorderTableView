//
//  UITableView+BFRReorder.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Dreaming In Binary, LLC. All rights reserved.
//

#import "UITableView+BFRReorder.h"
#import "ReorderController.h"
#import <objc/runtime.h>

static UInt8 keys;

@implementation UITableView (BFRReorder)

@dynamic reorder;

- (ReorderController *)reorder {
    ReorderController *reorder = [ReorderController new];
    objc_setAssociatedObject(self, &keys, reorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return objc_getAssociatedObject(self, &keys);
}

@end

