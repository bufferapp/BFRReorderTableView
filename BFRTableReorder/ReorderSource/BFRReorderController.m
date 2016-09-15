//
//  BFRReorderController.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "BFRReorderController.h"
#import "BFRReorderState.h"
#import <UIKit/UIKit.h>

@interface BFRReorderController() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BFRReorderState *reorderState;
@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) CADisplayLink *autoScrollDisplayLink;
@property (nonatomic) CFTimeInterval lastAutoScrollTimeStamp;
@property (strong, nonatomic) UILongPressGestureRecognizer *reorderGestureRecognizer;

@end

@implementation BFRReorderController

#pragma mark - Getters
- (UILongPressGestureRecognizer *)reorderGestureRecognizer {
    if(_reorderGestureRecognizer == nil) {
        _reorderGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleReorderGesture:)];
        _reorderGestureRecognizer.delegate = self;
        _reorderGestureRecognizer.minimumPressDuration = self.longPressDuration;
    }
    
    return _reorderGestureRecognizer;
}

#pragma mark - Initializers
- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    
    if (self) {
        self.reorderState = [BFRReorderState new];
        self.tableView = tableView;
        [self.tableView addGestureRecognizer:self.reorderGestureRecognizer];
    }
    
    return self;
}

#pragma mark - Reordering
- (void)beginReorderAtTouchPoint:(CGPoint)touchPoint {
    if (self.reorderState.state != Ready || self.tableView == nil) return;
    
    NSIndexPath *sourceRow = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    if (sourceRow == nil) return;
    
    //TODO: Uncomment once implemented
    //[self createSnapshotViewForCellAtRow:sourceRow];
    //[self animateSnapshotViewIn];
    //[self activateAutoScrollDisplayLink];
    
    [self.tableView reloadData];
    
    CGFloat snapshotOffset = self.snapshotView ? (self.snapshotView.center.y - touchPoint.y) : 0;
    self.reorderState.state = Reordering;
    self.reorderState.sourceRow = sourceRow;
    self.reorderState.destinationRow = sourceRow;
    self.reorderState.snapshotOffset = snapshotOffset;
}

- (void)updateReorderAtTouchPoint:(CGPoint)touchPoint {
    if (self.snapshotView == nil) return;
    
    CGPoint newCenter = self.snapshotView.center;
    newCenter.y = touchPoint.y + self.reorderState.snapshotOffset;
    self.snapshotView.center = newCenter;
    //TODO: Uncomment once implemented
    //[self updateDestinationRow];
}

- (void)endReorder {
    if (self.tableView == nil) return;
    
    NSIndexPath *snapshotRow = self.reorderState.destinationRow;
    if (snapshotRow == nil) return;
    
    self.reorderState.state = Ready;
    self.reorderState.snapshotRow = snapshotRow;
    
    CGRect rect = [self.tableView rectForRowAtIndexPath:self.reorderState.destinationRow];
    CGPoint rectCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    // If no values actually change inside a UIView animation block, the completion handler is called immediately.
    // This is a workaround for that case.
    if (self.snapshotView && CGPointEqualToPoint(self.snapshotView.center, rectCenter)) {
        self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y + 0.1);
    }
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.snapshotView.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    }completion:^(BOOL finished) {
        if (self.reorderState.snapshotRow) {
            self.reorderState.state = Ready;
            [UIView performWithoutAnimation:^ {
                [self.tableView reloadRowsAtIndexPaths:@[self.reorderState.snapshotRow] withRowAnimation:UITableViewRowAnimationNone];
            }];
            //TODO: Uncomment once implemented
            //[self removeSnapshotView];
        }
    }];
}

#pragma mark - Spacer Cell
- (UITableViewCell *)spacerCellForIndexPath:(NSIndexPath *)indexPath {
    if (self.reorderState.destinationRow == indexPath && self.reorderState.state == Reordering) {
        return [self spacerCell];
    } else if (self.reorderState.snapshotRow == indexPath && self.reorderState.state == Ready) {
        return [self spacerCell];
    }
    
    return nil;
}

- (UITableViewCell *)spacerCell {
    if (self.snapshotView == nil) return nil;
    
    UITableViewCell *cell = [UITableViewCell new];
    CGFloat height = self.snapshotView.bounds.size.height;
    [NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height].active = YES;
    
    BOOL hideCell;
    switch (self.spacerCellStyle) {
        case Automatic:
            hideCell = self.tableView.style == UITableViewStyleGrouped;
            break;
        case Hidden:
            hideCell = YES;
            break;
        case Transparent:
            hideCell = NO;
            break;
        default:
            break;
    }
    
    if (hideCell) {
        cell.hidden = YES;
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.tableView == nil) return NO;
    
    CGPoint gestureLocation = [gestureRecognizer locationInView:self.tableView];
    
    if (![self.tableView indexPathForRowAtPoint:gestureLocation]) return NO;
    
    return YES;
}

- (void)handleReorderGesture:(UIGestureRecognizer *)recognizer {
    
}
@end
