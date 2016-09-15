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

@property (strong, nonatomic) NSMutableArray <NSMutableArray<NSString *> *> *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *section1 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil];
    NSMutableArray *section2 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil];
    NSMutableArray *section3 = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil];
    self.items = [[NSMutableArray alloc] initWithArray:@[section1, section2, section3]];
    
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
    NSString *item = self.items[fromIndexPath.section][fromIndexPath.row];
    [self.items[fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
    [self.items[toIndexPath.section] insertObject:item atIndex:toIndexPath.row];
}

#pragma mark - Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.items[indexPath.section][indexPath.row];
    return cell;
}

@end
