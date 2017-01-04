//
//  ViewController.m
//  BFRTableReorder
//
//  Created by Jordan Morgan on 9/14/16.
//  Copyright © 2016 Buffer. All rights reserved.
//

#import "ViewController.h"
#import "ASTableNode+BFRReorder.h"

@interface ViewController () <ASTableDataSource, ASTableDelegate, BFRTableViewReorderDelegate>

@property (strong, nonatomic, nonnull) ASTableNode *tableNode;
@property (strong, nonatomic, nonnull) NSMutableArray <NSString *> *items;
@property (strong, nonatomic, nonnull) NSMutableArray <NSMutableArray<NSString *> *> *multipleItems;
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
    
    self.tableNode = [[ASTableNode alloc] initWithStyle:self.useMultipleSections ? UITableViewStyleGrouped : UITableViewStylePlain];
    self.tableNode.delegate = self;
    self.tableNode.dataSource = self;
    self.tableNode.reorder.delegate = self;
    self.tableNode.allowsSelection = NO;
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubnode:self.tableNode];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableNode.frame = self.view.bounds;
}

#pragma mark - Reordering
- (void)tableNode:(ASTableNode *)tableNode redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
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

#pragma mark - Reorder Optional Delegate Methods
- (BOOL)tableNode:(ASTableNode *)tableNode canReorderRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableNodeWillBeginReordering:(ASTableNode *)tableNode {
    
}

- (void)tableNodeDidBeginReordering:(ASTableNode *)tableNode {
  
}

- (void)tableNodeDidFinishReordering:(ASTableNode *)tableNode {
   
}

#pragma mark - Datasource
- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return self.useMultipleSections ? self.multipleItems[section].count : self.items.count;
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return self.useMultipleSections ? self.multipleItems.count : 1;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableNode.reorder shouldShowSpacerCellForIndexPath:indexPath]) {
        ASCellNode *(^ASCellNodeBlock)() = ^ASCellNode *() {
            ASCellNode *cell = [ASCellNode new];
            cell.style.preferredSize = CGSizeMake(0, tableNode.reorder.sourceHeight);
            
            return cell;
        };
        
        return ASCellNodeBlock;
    }
    
    NSString *itemText = self.useMultipleSections ? self.multipleItems[indexPath.section][indexPath.row] : self.items[indexPath.row];
    
    return ^{
        ASTextCellNode *textCellNode = [ASTextCellNode new];
        textCellNode.text = itemText;
        return textCellNode;
    };
}

@end
