//
//  BFRIndexPathSnapDistance.h
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/15/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFRIndexPathSnapDistance : NSObject

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) CGFloat distance;

- (instancetype)initWithPath:(NSIndexPath *)path distance:(CGFloat)distance;

@end
