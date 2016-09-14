//
//  UITableView+BFRReorder.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Dreaming In Binary, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReorderController.h"

@interface UITableView (BFRReorder)
//TODO: Make this a reorder controller
@property (strong, nonatomic) ReorderController *reorder;
@end
