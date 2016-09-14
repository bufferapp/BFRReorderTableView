//
//  ReorderController.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Dreaming In Binary, LLC. All rights reserved.
//

#import "ReorderController.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ReorderState) {
    Ready,
    Reordering
};

@interface ReorderController() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic) ReorderState reorderState;
@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) CADisplayLink *autoScrollDisplayLink;
@property (nonatomic) CFTimeInterval lastAutoScrollTimeStamp;
@property (strong, nonatomic) UILongPressGestureRecognizer *reorderGestureRecognizer;

@end

@implementation ReorderController

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
        self.tableView = tableView;
        [self.tableView addGestureRecognizer:self.reorderGestureRecognizer];
        self.reorderState = Ready;
    }
    
    return self;
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
