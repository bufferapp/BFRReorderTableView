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

@property (weak, nonatomic) ASTableNode *tableNode;
@property (strong, nonatomic) BFRReorderState *reorderState;
@property (strong, nonatomic) ASDisplayNode *snapshotNode;
@property (strong, nonatomic) CADisplayLink *autoScrollDisplayLink;
@property (nonatomic) CFTimeInterval lastAutoScrollTimeStamp;
@property (strong, nonatomic) UILongPressGestureRecognizer *reorderGestureRecognizer;

@end

@implementation BFRReorderController

#pragma mark - Lazy Loads
- (UILongPressGestureRecognizer *)reorderGestureRecognizer {
    if(_reorderGestureRecognizer == nil) {
        _reorderGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleReorderGesture:)];
        _reorderGestureRecognizer.delegate = self;
        _reorderGestureRecognizer.minimumPressDuration = self.longPressDuration;
    }
    
    return _reorderGestureRecognizer;
}

#pragma mark - Initializers
- (instancetype)initWithTableView:(ASTableNode *)tableNode {
    self = [super init];
    
    if (self) {
        self.longPressDuration = 0.3f;
        self.animationDuration = 0.2f;
        self.cellOpacity = 1;
        self.cellScale = 0.75f;
        self.shadowColor = [UIColor blackColor];
        self.shadowOpacity = 0.3f;
        self.shadowRadius = 10;
        self.shadowOffset = CGSizeMake(0, 3);
        self.reorderState = [BFRReorderState new];
        self.tableNode = tableNode;
        [self.tableNode.view addGestureRecognizer:self.reorderGestureRecognizer];
    }
    
    return self;
}

#pragma mark - Reordering
- (void)beginReorderAtTouchPoint:(CGPoint)touchPoint {
    if (self.reorderState.state != Ready || self.tableNode == nil) return;
    
    NSIndexPath *sourceRow = [self.tableNode indexPathForRowAtPoint:touchPoint];
    if (sourceRow == nil) return;
    
    if(![self.delegate respondsToSelector:@selector(tableNode:canReorderRowAtIndexPath:)]) return;
    if([self.delegate tableNode:self.tableNode canReorderRowAtIndexPath:sourceRow] == NO) return;
    
    [self createsnapshotNodeForCellAtIndexPath:sourceRow];
    [self animatesnapshotNodeIn];
    [self activateAutoScrollDisplayLink];
    
    CGFloat snapshotOffset = self.snapshotNode ? (self.snapshotNode.view.center.y - touchPoint.y) : 0;
    self.reorderState.state = Reordering;
    self.reorderState.sourceRow = sourceRow;
    self.reorderState.destinationRow = sourceRow;
    self.reorderState.snapshotOffset = snapshotOffset;
    
    self.sourceHeight = CGRectGetHeight([self.tableNode rectForRowAtIndexPath:sourceRow]);
    [self.tableNode reloadRowsAtIndexPaths:@[sourceRow] withRowAnimation:UITableViewRowAnimationFade];
    
    if ([self.delegate respondsToSelector:@selector(tableNodeDidBeginReordering:)]) {
        [self.delegate tableNodeDidBeginReordering:self.tableNode];
    }
}

- (void)updateReorderAtTouchPoint:(CGPoint)touchPoint {
    if (self.snapshotNode == nil) return;
    if (self.reorderState.state != Reordering) return;
    
    CGPoint newCenter = self.snapshotNode.view.center;
    newCenter.y = touchPoint.y + self.reorderState.snapshotOffset;
    self.snapshotNode.view.center = newCenter;
    [self updateDestinationRow];
}

- (void)endReorder {
    if (self.reorderState.state != Reordering && self.reorderState.destinationRow == nil) return;
    if (self.tableNode == nil) return;
    
    self.reorderState.state = Ready;
    self.reorderState.snapshotRow = self.reorderState.destinationRow;
    
    CGRect rect = [self.tableNode rectForRowAtIndexPath:self.reorderState.destinationRow];
    CGPoint rectCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    // If no values actually change inside a UIView animation block, the completion handler is called immediately.
    // This is a workaround for that case.
    if (CGPointEqualToPoint(self.snapshotNode.view.center, rectCenter)) {
        self.snapshotNode.view.center = CGPointMake(self.snapshotNode.view.center.x, self.snapshotNode.view.center.y + 0.1);
    }
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.snapshotNode.view.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    } completion:^(BOOL finished) {
        if (self.reorderState.state == Ready && self.reorderState.snapshotRow) {
            [UIView performWithoutAnimation:^ {
                [self.tableNode reloadRowsAtIndexPaths:@[self.reorderState.snapshotRow] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [self performSelector:@selector(removesnapshotNode) withObject:nil afterDelay:0.5];
            self.reorderState.snapshotRow = nil;
        }
    }];
    [self animatesnapshotNodeOut];
    [self clearAutoScrollDisplayLink];
    
    if ([self.delegate respondsToSelector:@selector(tableNodeDidFinishReordering:)]) {
        [self.delegate tableNodeDidFinishReordering:self.tableNode];
    }
}

#pragma mark - Spacer Cell
- (BOOL)shouldShowSpacerNodeForIndexPath:(NSIndexPath *)indexPath {
    if (self.reorderState.state == Reordering && [self.reorderState.destinationRow isEqual:indexPath]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Snapshow View
- (void)createsnapshotNodeForCellAtIndexPath:(NSIndexPath *)indexPath {
    [self removesnapshotNode];
    
    ASCellNode *cell = [self.tableNode nodeForRowAtIndexPath:indexPath];
    CGPoint cellOrigin = [cell.view convertPoint:cell.view.frame.origin toView:self.tableNode.view];
    CGSize cellSize = cell.frame.size;
    CGRect cellFrame = {{cellOrigin.x, cellOrigin.y}, {cellSize.width, cellSize.height}};
    
    ASDisplayNode *snapshotNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView *{
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
        [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *snapshotNode = [[UIImageView alloc] initWithImage:image];
        snapshotNode.frame = cellFrame;
        
        snapshotNode.layer.masksToBounds = NO;
        snapshotNode.layer.opacity = self.cellOpacity;
        snapshotNode.layer.transform = CATransform3DMakeScale(self.cellScale, self.cellScale, 1);
        
        snapshotNode.layer.shadowColor = self.shadowColor.CGColor;
        snapshotNode.layer.shadowOpacity = self.shadowOpacity;
        snapshotNode.layer.shadowRadius = self.shadowRadius;
        snapshotNode.layer.shadowOffset = self.shadowOffset;
        
        return snapshotNode;
    }];
    
    [self.tableNode addSubnode:snapshotNode];
    self.snapshotNode = snapshotNode;
}

- (void)removesnapshotNode {
    if (self.snapshotNode == nil) return;
    
    [self.snapshotNode removeFromSupernode];
    self.snapshotNode = nil;
}

- (void)animatesnapshotNodeIn {
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
    
    [self.snapshotNode.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotNode.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotNode.layer addAnimation:transformAnimation forKey:nil];
}

- (void)animatesnapshotNodeOut {
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
    
    [self.snapshotNode.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotNode.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotNode.layer addAnimation:transformAnimation forKey:nil];
    
    self.snapshotNode.layer.opacity = 1;
    self.snapshotNode.layer.shadowOpacity = 0;
    self.snapshotNode.layer.transform = CATransform3DIdentity;
}

#pragma mark - Destination Row

- (CGRect)rectWithCenter:(CGPoint)center andSize:(CGSize)size {
    return CGRectMake(center.x - (size.width/2), center.y - (size.height/2), size.width, size.height);
}

- (void)updateDestinationRow {
    if (self.reorderState.state != Reordering || self.reorderState.sourceRow == nil || self.reorderState.destinationRow == nil) return;
    if (self.tableNode == nil) return;
    
    NSIndexPath *newDestinationRow = [self newDestinationRow];
    NSInteger currentRow = self.reorderState.destinationRow.row;
    NSInteger currentSection = self.reorderState.destinationRow.section;
    NSIndexPath *destinationRow = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
    
    if (newDestinationRow == nil || [newDestinationRow isEqual:self.reorderState.destinationRow]) return;
    
    self.reorderState.state = Reordering;
    self.reorderState.destinationRow = newDestinationRow;
    [self.delegate tableNode:self.tableNode redorderRowAtIndexPath:destinationRow toIndexPath:newDestinationRow];
    
    [self.tableNode performBatchUpdates:^ {
        [self.tableNode deleteRowsAtIndexPaths:@[destinationRow] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableNode insertRowsAtIndexPaths:@[newDestinationRow] withRowAnimation:UITableViewRowAnimationFade];
    } completion:nil];
}

- (NSIndexPath *)newDestinationRow {
    if (self.reorderState.state != Reordering && self.reorderState.destinationRow == nil) return nil;
    if (self.tableNode == nil || self.snapshotNode == nil) return nil;
    
    CGRect snapshotFrame = [self rectWithCenter:self.snapshotNode.view.center andSize:self.snapshotNode.view.bounds.size];
    
    NSMutableArray <BFRIndexPathSnapDistance *> *rowSnapDistances = [NSMutableArray new];
    for (NSIndexPath *indexPath in [self.tableNode indexPathsForVisibleRows]) {
        CGRect rect = [self.tableNode rectForRowAtIndexPath:indexPath];
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
    for (NSInteger section = 0; section < self.tableNode.numberOfSections; section++) {
        NSInteger rowsInSection = [self.tableNode numberOfRowsInSection:section];
        
        if (section > self.reorderState.destinationRow.section) {
            CGRect rect;
            
            if (rowsInSection == 0) {
                rect = [self rectForEmptySection:section];
            } else {
                rect = [self.tableNode rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            }
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
            
            if ([self.delegate respondsToSelector:@selector(tableNode:canReorderRowAtIndexPath:)] && [self.delegate tableNode:self.tableNode canReorderRowAtIndexPath:path] == NO) {
                continue;
            }
            
            CGFloat distance = abs((int)(CGRectGetMaxY(snapshotFrame) - (int)CGRectGetMinY(rect)));
            BFRIndexPathSnapDistance *snapDistance = [[BFRIndexPathSnapDistance alloc] initWithPath:path distance:distance];
            [sectionSnapDistances addObject:snapDistance];
        } else if (section < self.reorderState.destinationRow.section) {
            CGRect rect;
            
            if (rowsInSection == 0) {
                rect = [self rectForEmptySection:section];
            } else {
                rect = [self.tableNode rectForRowAtIndexPath:[NSIndexPath indexPathForRow:rowsInSection - 1 inSection:section]];
            }
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:rowsInSection inSection:section];
            
            if ([self.delegate respondsToSelector:@selector(tableNode:canReorderRowAtIndexPath:)] && [self.delegate tableNode:self.tableNode canReorderRowAtIndexPath:path] == NO) {
                continue;
            }
            
            CGFloat distance = abs((int)(CGRectGetMinY(snapshotFrame) - (int)CGRectGetMaxY(rect)));
            BFRIndexPathSnapDistance *snapDistance = [[BFRIndexPathSnapDistance alloc] initWithPath:path distance:distance];
            [sectionSnapDistances addObject:snapDistance];
        }
    }
    
    //Combine them
    [rowSnapDistances addObjectsFromArray:sectionSnapDistances];
    
    //Find the minimum distance from all of them
    if (rowSnapDistances.count > 0) {
        return [[[rowSnapDistances sortedArrayUsingComparator:^NSComparisonResult(BFRIndexPathSnapDistance *obj1, BFRIndexPathSnapDistance *obj2) {
            return obj1.distance > obj2.distance;
        }] firstObject] indexPath];
    } else {
        return nil;
    }
}

- (CGRect)rectForEmptySection:(NSInteger)section {
    if (self.tableNode == nil) return CGRectZero;
    
    CGRect sectionRect = [self.tableNode.view rectForHeaderInSection:section];
    return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsetsMake(sectionRect.size.height, 0, 0, 0 ));
}

#pragma mark - Autoscroll
static CGFloat autoScrollThreshold = 30;
static CGFloat autoScrollMinVelocity = 60;
static CGFloat autoScrollMaxVelocity = 280;

- (CGFloat)mapValue:(CGFloat)value inRangeWithMinimum:(CGFloat)minimumA andMaximum:(CGFloat)maximumA toRangeWithMinimum:(CGFloat)minimumB andMaximum:(CGFloat)maximumB {
    return (value - minimumA) * (maximumB - minimumB) / (maximumA - minimumA) + minimumB;
}

- (CGFloat)autoScrollVelocity {
    if (self.tableNode == nil || self.snapshotNode == nil) return 0;
    
    CGRect scrollBounds = UIEdgeInsetsInsetRect(self.tableNode.view.bounds, self.tableNode.view.contentInset);
    CGFloat distanceToTop = MAX(CGRectGetMinY(self.snapshotNode.view.frame) - CGRectGetMinY(scrollBounds), 0);
    CGFloat distanceToBottom = MAX(CGRectGetMaxY(scrollBounds) - CGRectGetMaxY(self.snapshotNode.view.frame), 0);
    
    if (distanceToTop < autoScrollThreshold) {
        return [self mapValue:distanceToTop inRangeWithMinimum:autoScrollThreshold andMaximum:0 toRangeWithMinimum:-autoScrollMinVelocity andMaximum:-autoScrollMaxVelocity];
    }
    
    if (distanceToBottom < autoScrollThreshold) {
        return [self mapValue:distanceToBottom inRangeWithMinimum:autoScrollThreshold andMaximum:0 toRangeWithMinimum:autoScrollMinVelocity andMaximum:autoScrollMaxVelocity];
    }
    
    return 0;
}

- (void)activateAutoScrollDisplayLink {
    self.autoScrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLinkUpdate:)];
    [self.autoScrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.lastAutoScrollTimeStamp = NAN;
}

- (void)clearAutoScrollDisplayLink {
    [self.autoScrollDisplayLink invalidate];
    self.autoScrollDisplayLink = nil;
    self.lastAutoScrollTimeStamp = NAN;
}

- (void)handleDisplayLinkUpdate:(CADisplayLink *)displayLink {
    if (self.tableNode == nil || self.snapshotNode == nil) return;
    
    if (isnan(self.lastAutoScrollTimeStamp) == NO) {
        CGFloat scrollVelocity = [self autoScrollVelocity];
        
        if (scrollVelocity != 0) {
            CGFloat elapsedTime = displayLink.timestamp - self.lastAutoScrollTimeStamp;
            CGFloat scrollDelta = elapsedTime * scrollVelocity;
            
            CGPoint oldOffset = self.tableNode.view.contentOffset;
            [self.tableNode.view setContentOffset:CGPointMake(oldOffset.x, oldOffset.y + scrollDelta) animated:NO];
            
            CGPoint runloopOffset1 = CGPointMake(self.tableNode.view.contentOffset.x, MIN(self.tableNode.view.contentOffset.y, self.tableNode.view.contentSize.height + self.tableNode.view.contentInset.bottom - self.tableNode.view.frame.size.height));
            self.tableNode.view.contentOffset = runloopOffset1;
            
            CGPoint runloopOffset2 = CGPointMake(self.tableNode.view.contentOffset.x, MAX(self.tableNode.view.contentOffset.y, - self.tableNode.view.contentInset.top));
            self.tableNode.view.contentOffset = runloopOffset2;
            
            CGFloat actualScrollDistnace = self.tableNode.view.contentOffset.y - oldOffset.y;
            CGRect newSnapshotRect = CGRectMake(self.snapshotNode.view.frame.origin.x, self.snapshotNode.view.frame.origin.y + actualScrollDistnace, self.snapshotNode.view.frame.size.width, self.snapshotNode.view.frame.size.height);
            self.snapshotNode.view.frame = newSnapshotRect;
            
            [self updateDestinationRow];
        }
    }
    
    self.lastAutoScrollTimeStamp = displayLink.timestamp;
}

#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.tableNode == nil) return NO;
    
    CGPoint gestureLocation = [gestureRecognizer locationInView:self.tableNode.view];
    NSIndexPath *touchedIndexPath = [self.tableNode indexPathForRowAtPoint:gestureLocation];
    
    if (touchedIndexPath == nil) return NO;
    if ([self.delegate respondsToSelector:@selector(tableNode:canReorderRowAtIndexPath:)] && [self.delegate tableNode:self.tableNode canReorderRowAtIndexPath:touchedIndexPath] == NO) return NO;
    
    if ([self.delegate respondsToSelector:@selector(tableNodeWillBeginReordering:)]) {
        [self.delegate tableNodeWillBeginReordering:self.tableNode];
    }
    
    return YES;
}

- (void)handleReorderGesture:(UIGestureRecognizer *)recognizer {
    CGPoint gestureLocation = [recognizer locationInView:self.tableNode.view];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self beginReorderAtTouchPoint:gestureLocation];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateReorderAtTouchPoint:gestureLocation];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            [self endReorder];
            break;
        default:
            break;
    }
}
@end
