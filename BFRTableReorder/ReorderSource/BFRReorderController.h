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

@protocol BFRTableViewReorderDelegate <NSObject, ASTableDelegate>

@required
- (void)tableView:(ASTableNode *)tableView redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@optional
- (BOOL)tableView:(ASTableNode *)tableView canReorderRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewWillBeginReordering:(ASTableNode *)tableView;
- (void)tableViewDidBeginReordering:(ASTableNode *)tableView;
- (void)tableViewDidFinishReordering:(ASTableNode *)tableView;

@optional


@end

@interface BFRReorderController : NSObject

@property (nonatomic, weak) id <BFRTableViewReorderDelegate> delegate;
@property (nonatomic) NSTimeInterval longPressDuration;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) CGFloat cellOpacity;
@property (nonatomic) CGFloat cellScale;
@property (strong, nonatomic) UIColor *shadowColor;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) CGFloat sourceHeight;

- (BOOL)shouldShowSpacerCellForIndexPath:(NSIndexPath *)indexPath;
- (instancetype)initWithTableView:(ASTableNode *)tableView;

@end
