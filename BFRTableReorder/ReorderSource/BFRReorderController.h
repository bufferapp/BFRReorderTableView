//
//  BFRReorderController.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>


/**
 Reordering delegate meant to be used with @c ASTableNode instances.
 */
@protocol BFRTableViewReorderDelegate <NSObject, ASTableDelegate>

@required

/**
 The primary function to reorder items in @c ASTableNode instances. Here you'll define what should happen to the datasource when a reorder operation occurs.

 @param tableNode The tableNode instance reordering is occurring on.
 @param fromIndexPath The @c NSIndexPath where the node is moving from.
 @param toIndexPath the @c NSIndexPath where the node is moving to.
 */
- (void)tableNode:(ASTableNode *)tableNode redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@optional


/**
 If NO is returned here, reordering logic does not occur at the given @c NSIndexPath.

 @param tableNode The tableNode instance reordering is occurring on.
 @param indexPath The proposed @c NSIndexPath to apply reordering logic against.
 @return A BOOL value indicating whether or not reordering logic should occur at the given @c NSIndexPath.
 */
- (BOOL)tableNode:(ASTableNode *)tableNode canReorderRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 Invoked right before reordering logic occurs.

 @param tableNode The tableNode instance reordering is occurring on.
 */
- (void)tableNodeWillBeginReordering:(ASTableNode *)tableNode;


/**
 Invoked right after reordering logic begins.

 @param tableNode The tableNode instance reordering is occurring on.
 */
- (void)tableNodeDidBeginReordering:(ASTableNode *)tableNode;


/**
 Invoked right after reordering logic finishes.

 @param tableNode The tableNode instance reordering is occurring on.
 */
- (void)tableNodeDidFinishReordering:(ASTableNode *)tableNode;

@optional


@end


/**
 This class houses the logic for reordering @c ASCellNode instances. It's meant to be used as a category for any @c ASTableNode instance. It works by shuffling around data source items via it's delegate property, @cBFRTableViewReorderDelegate, and by creating a snapshot node that is dragged up and down that mimics the look of the node that was long pressed on. The snapshot node is configurable via the public properties found in this class. Note that you should invoke @c -(BOOL)shouldShowSpacerNodeForIndexPath:indexPath within @c -(ASCellNodeBlock)tableNode:tableNodenodeBlockForRowAtIndexPath: to see whether or not you should supply a spacer node at the given @c NSIndexPath. 
 */
@interface BFRReorderController : NSObject


/**
 The primary delegate of an @c ASTableNode instance that controls reordering.
 */
@property (nonatomic, weak) id <BFRTableViewReorderDelegate> delegate;

/**
 The duration that should elapse before reordering begins.
 */
@property (nonatomic) NSTimeInterval longPressDuration;

/**
 The duration of all the animations that occur during reordering, such as the snapshot node being created and table reorder operations.
 */
@property (nonatomic) NSTimeInterval animationDuration;

/**
 The opacity that the snapshot node will have during reordering.
 */
@property (nonatomic) CGFloat cellOpacity;

/**
 The scale that the snapshot node will have during reordering.
 */
@property (nonatomic) CGFloat cellScale;

/**
 The color that the snapshot node will have during reordering, if a shadow is used.
 */
@property (strong, nonatomic) UIColor *shadowColor;

/**
 The shadow opacity that the snapshot node will have during reodering, if a shadow is used.
 */
@property (nonatomic) CGFloat shadowOpacity;

/**
 The radius of the shadow that the snapshot node will have during reordering, if a shadow is used.
 */
@property (nonatomic) CGFloat shadowRadius;

/**
 The offset of the shadow that the snapshot node will have during reordering, if a shadow is used.
 */
@property (nonatomic) CGSize shadowOffset;

/**
 When reordering occurs, this will represent the height of the node that the snapshot node is about to mimic. This can be set by the API consumer as well, should various edge cases present themselves. Typically, you should set your spacer node's height to this value.
 */
@property (nonatomic) CGFloat sourceHeight;


/**
 Returns YES if a spacer node should be displayed by the consumer in it's node block for the @c NSIndexPath. This helps with the presentation of the node, which makes it appear as if it is fading away when the snapshot node passes over it.
 
 @param indexPath The @c NSIndexPath where the check for a spacer node will occur.
 @return Returns YES if the consumer should supply a dummy space node for inside of their node block at the given @c NSIndexPath.
 */
- (BOOL)shouldShowSpacerNodeForIndexPath:(NSIndexPath *)indexPath;


/**
 Initializes a fully configurable reodering instance.

 @param tableNode The tableNode instance to use reordering with.
 @return A reordering controller instance. More setup can occur after initialization via its public properties.
 */
- (instancetype)initWithTableView:(ASTableNode *)tableNode;

@end
