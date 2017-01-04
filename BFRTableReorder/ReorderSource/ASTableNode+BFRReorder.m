//
//  ASTableNode+BFRReorder.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "ASTableNode+BFRReorder.h"
#import "BFRReorderController.h"
#import <objc/runtime.h>

static void *AssociatedKey;

@implementation ASTableNode (BFRReorder)

@dynamic reorder;

- (BFRReorderController *)reorder {
    BFRReorderController *reorder = objc_getAssociatedObject(self, &AssociatedKey);
    
    if (reorder) {
        return reorder;
    }
    
    reorder = [[BFRReorderController alloc] initWithTableView:self];
    objc_setAssociatedObject(self, &AssociatedKey, reorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return reorder;
}

@end
