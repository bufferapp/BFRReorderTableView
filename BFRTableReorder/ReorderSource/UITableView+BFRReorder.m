//
//  UITableView+BFRReorder.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "UITableView+BFRReorder.h"
#import "BFRReorderController.h"
#import <objc/runtime.h>

static void *AssociatedKey;

@implementation UITableView (BFRReorder)

@dynamic reorder;

- (BFRReorderController *)reorder {
    BFRReorderController *reorder = [BFRReorderController new];
    objc_setAssociatedObject(self, &AssociatedKey, reorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return objc_getAssociatedObject(self, &AssociatedKey);
}

@end

