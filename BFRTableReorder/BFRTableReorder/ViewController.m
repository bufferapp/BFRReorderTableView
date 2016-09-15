//
//  ViewController.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+BFRReorder.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, BFRTableViewReorderDelegate>

@property (strong, nonatomic) NSMutableArray <NSString *> *items;
@property (strong, nonatomic) NSMutableArray <NSMutableArray<NSString *> *> *multipleItems;
@property (nonatomic) BOOL useMultipleSections;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.useMultipleSections = YES;
    self.items = [[NSMutableArray alloc] initWithArray:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"]];
    
    NSMutableArray *section1 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil];
    NSMutableArray *section2 = [[NSMutableArray alloc] initWithObjects:@"3", @"4", nil];
    NSMutableArray *section3 = [[NSMutableArray alloc] initWithObjects:@"5", @"6", nil];
    self.multipleItems = [[NSMutableArray alloc] initWithArray:@[section1, section2, section3]];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tv.delegate = self;
    tv.dataSource = self;
    tv.rowHeight = 48;
    tv.reorder.delegate = self;
    
    [self.view addSubview:tv];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    [tv.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [tv.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [tv.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [tv.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

#pragma mark - Reordering
- (void)tableView:(UITableView *)tableView redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    if (self.useMultipleSections) {
        NSString *item = self.multipleItems[fromIndexPath.section][fromIndexPath.row];
        [self.multipleItems[fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
        [self.multipleItems[toIndexPath.section] insertObject:item atIndex:toIndexPath.row];
    } else {
        NSString *item = self.items[fromIndexPath.row];
        [self.items removeObjectAtIndex:fromIndexPath.row];
        [self.items insertObject:item atIndex:toIndexPath.row];
    }
}

#pragma mark - Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.useMultipleSections ? 2 : 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.useMultipleSections ? 3 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *spacerCell = [tableView.reorder spacerCellForIndexPath:indexPath];
    if (spacerCell) {
        return spacerCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if (self.useMultipleSections) {
        cell.textLabel.text = self.multipleItems[indexPath.section][indexPath.row];
    } else {
        cell.textLabel.text = self.items[indexPath.row];
    }
    
    return cell;
}

@end
