//
//  BFRReorderState.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, State) {
    Ready,
    Reordering
};

@interface BFRReorderState : NSObject

@property (nonatomic) State state;
@property (strong, nonatomic) NSIndexPath *snapshotRow;
@property (strong, nonatomic) NSIndexPath *sourceRow;
@property (strong, nonatomic) NSIndexPath *destinationRow;
@property (nonatomic) CGFloat snapshotOffset;

@end
