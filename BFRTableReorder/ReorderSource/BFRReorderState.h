//
//  BFRReorderState.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 Represents the state of the current reorder operation.

 - Ready: Means that the @c ASTableNode instance is ready to reorder.
 - Reordering: Means that the @c ASTableNode instance is currently reordering.
 */
typedef NS_ENUM(NSInteger, State) {
    Ready,
    Reordering
};


/**
 A simple class that controls state for the current, or proposed, reordering operation that happens via a @c BFRReorderController instance.
 */
@interface BFRReorderState : NSObject

/**
 The current state of the reorder operations, which is either ready or in progress.
 */
@property (nonatomic) State state;

/**
 Holds the row that is about to be reordered, which in turn should have a spacer node put in its place.
 */
@property (strong, nonatomic) NSIndexPath *snapshotRow;

/**
 The row where reordering started at.
 */
@property (strong, nonatomic) NSIndexPath *sourceRow;

/**
 The proposed row where the @c sourceRow is attempting to be moved to.
 */
@property (strong, nonatomic) NSIndexPath *destinationRow;

/**
 An offset that's applied to the snap shot node. This will be set by an @c BFRReorderController instance.
 */
@property (nonatomic) CGFloat snapshotOffset;

@end
