//
//  BFRReorderController.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ReorderSpacerCellStyle) {
    Automatic,
    Hidden,
    Transparent
};

@protocol BFRTableViewReorderDelegate <NSObject>

@required
- (void)tableView:(UITableView *)tableView redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

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
@property (nonatomic) ReorderSpacerCellStyle spacerCellStyle;

- (UITableViewCell *)spacerCellAtIndexPath:(NSIndexPath *)indexPath;
- (instancetype)initWithTableView:(UITableView *)tableView;

@end
