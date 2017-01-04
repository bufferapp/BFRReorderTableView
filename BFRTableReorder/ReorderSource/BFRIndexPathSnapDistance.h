//
//  BFRIndexPathSnapDistance.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 A small class that holds information to help computes distances from the snap shot node to other cell nodes to know where animations, reordering and other opertaions should occur at.
 */
@interface BFRIndexPathSnapDistance : NSObject


/**
 The given @c NSIndexPath that is being used to reorder to or away from.
 */
@property (strong, nonatomic) NSIndexPath *indexPath;

/**
 Holds the distance a snap shot node is being moved away from, or to, another cell node.
 */
@property (nonatomic) CGFloat distance;


/**
 Returns an instance of a @c BFRIndexPathSnapDistance to aid with reordering away and from index paths.

 @param path The current @c NSIndexPath to be checked against.
 @param distance The current distance to the next index path that the snap shot node is going to, or moving away from.
 @return An instance of @c BFRIndexPathSnapDisance.
 */
- (instancetype)initWithPath:(NSIndexPath *)path distance:(CGFloat)distance;

@end
