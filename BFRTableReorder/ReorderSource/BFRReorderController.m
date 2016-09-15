//
//  BFRReorderController.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "BFRReorderController.h"
#import "BFRReorderState.h"
#import "BFRIndexPathSnapDistance.h"
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
    
    [self createSnapshotViewForCellAtIndexPath:sourceRow];
    [self animateSnapshotViewIn];
    //TODO: Uncomment once implemented
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
            [self removeSnapshotView];
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

#pragma mark - Snapshow View
- (void)createSnapshotViewForCellAtIndexPath:(NSIndexPath *)indexPath {
    [self removeSnapshotView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) return;
    
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshotView = [[UIImageView alloc] initWithImage:image];
    snapshotView.frame = cell.frame;
    
    snapshotView.layer.masksToBounds = NO;
    snapshotView.layer.opacity = self.cellOpacity;
    snapshotView.layer.transform = CATransform3DMakeScale(self.cellScale, self.cellScale, 1);
    
    snapshotView.layer.shadowColor = self.shadowColor.CGColor;
    snapshotView.layer.shadowOpacity = self.shadowOpacity;
    snapshotView.layer.shadowRadius = self.shadowRadius;
    snapshotView.layer.shadowOffset = self.shadowOffset;
    
    [self.tableView addSubview:snapshotView];
    self.snapshotView = snapshotView;
}

- (void)removeSnapshotView {
    [self.snapshotView removeFromSuperview];
    self.snapshotView = nil;
}

- (void)animateSnapshotViewIn {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:self.cellOpacity];
    opacityAnimation.duration = self.animationDuration;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    shadowAnimation.toValue = [NSNumber numberWithFloat:self.shadowOpacity];
    shadowAnimation.duration = self.animationDuration;
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    transformAnimation.toValue = [NSNumber numberWithFloat:self.cellScale];
    transformAnimation.duration = self.animationDuration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.snapshotView.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:transformAnimation forKey:nil];
}

- (void)animateSnapshotViewOut {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:self.cellOpacity];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.duration = self.animationDuration;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnimation.fromValue = [NSNumber numberWithFloat:self.shadowOpacity];
    shadowAnimation.toValue = [NSNumber numberWithFloat:0.0];
    shadowAnimation.duration = self.animationDuration;
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnimation.fromValue = [NSNumber numberWithFloat:self.cellScale];
    transformAnimation.toValue = [NSNumber numberWithFloat:1];
    transformAnimation.duration = self.animationDuration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.snapshotView.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:transformAnimation forKey:nil];
    
    self.snapshotView.layer.opacity = 1;
    self.snapshotView.layer.shadowOpacity = 0;
    self.snapshotView.layer.transform = CATransform3DIdentity;
}

#pragma mark - Destination Row

- (CGRect)rectWithCenter:(CGPoint)center andSize:(CGSize)size {
    return CGRectMake(center.x - (size.width/2), center.y - (size.height/2), size.width, size.height);
}

- (void)updateDestinationRow {
    if (self.reorderState.state != Reordering && self.reorderState.sourceRow == nil && self.reorderState.destinationRow == nil) return;
    if (self.tableView == nil) return;
    
    //TODO: Uncomment once implemented
    //= [self newDestinationRow] && newDestinationRow != self.reorderState.destinationRow
    NSIndexPath *newDestinationRow;
    
    self.reorderState.state = Reordering;
    self.reorderState.destinationRow = newDestinationRow;
    [self.delegate tableView:self.tableView redorderRowAtIndexPath:self.reorderState.destinationRow toIndexPath: newDestinationRow];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.reorderState.destinationRow] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:@[newDestinationRow] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSIndexPath *)newDestinationRow {
    if (self.reorderState.state != Reordering && self.reorderState.destinationRow == nil) return nil;
    if (self.tableView == nil || self.snapshotView == nil) return nil;
    
    CGRect snapshotFrame = [self rectWithCenter:self.snapshotView.center andSize:self.snapshotView.bounds.size];
    
    NSMutableArray <BFRIndexPathSnapDistance *> *rowSnapDistances = [NSMutableArray new];
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        CGFloat distance;

        if ([self.reorderState.destinationRow compare:indexPath] == NSOrderedAscending) {
            distance = abs((int)CGRectGetMaxY(snapshotFrame) - (int)CGRectGetMaxY(rect));
            [rowSnapDistances addObject:[[BFRIndexPathSnapDistance alloc] initWithPath:indexPath distance:distance]];
        } else {
            distance = abs((int)CGRectGetMinY(snapshotFrame) - (int)CGRectGetMinY(rect));
            [rowSnapDistances addObject:[[BFRIndexPathSnapDistance alloc] initWithPath:indexPath distance:distance]];
        }
    }
    
    NSMutableArray <BFRIndexPathSnapDistance *> *sectionSnapDistances = [NSMutableArray new];
    for (NSInteger section = 0; section < self.tableView.numberOfSections; section++) {
        NSInteger rowsInSection = [self.tableView numberOfRowsInSection:section];
        
        if (section > self.reorderState.destinationRow.section) {
            CGRect rect;
            
            if (rowsInSection == 0) {
                rect = [self rectForEmptySection:section];
            } else {
                rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            }
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
            CGFloat distance = abs((int)(CGRectGetMaxY(snapshotFrame) - (int)CGRectGetMinY(rect)));
            BFRIndexPathSnapDistance *snapDistance = [[BFRIndexPathSnapDistance alloc] initWithPath:path distance:distance];
            [sectionSnapDistances addObject:snapDistance];
        } else if (section < self.reorderState.destinationRow.section) {
            CGRect rect;
            
            if (rowsInSection == 0) {
                rect = [self rectForEmptySection:section];
            } else {
                rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:rowsInSection - 1 inSection:section]];
            }
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:rowsInSection inSection:section];
            CGFloat distance = abs((int)(CGRectGetMinY(snapshotFrame) - (int)CGRectGetMaxY(rect)));
            BFRIndexPathSnapDistance *snapDistance = [[BFRIndexPathSnapDistance alloc] initWithPath:path distance:distance];
            [sectionSnapDistances addObject:snapDistance];
        }
    }
    
    //Combine them
    [rowSnapDistances addObjectsFromArray:sectionSnapDistances];
    
    //Find the minimum distance from all of them
    if (rowSnapDistances.count > 0) {
        //TODO: This might not work
        return [[rowSnapDistances valueForKeyPath:@"min.distance"] indexPath];
    } else {
        return nil;
    }
}

- (CGRect)rectForEmptySection:(NSInteger)section {
    if (self.tableView == nil) return CGRectZero;
    
    CGRect sectionRect = [self.tableView rectForHeaderInSection:section];
    return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsetsMake(sectionRect.size.height, 0, 0, 0 ));
}

#pragma mark - Autoscroll

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
