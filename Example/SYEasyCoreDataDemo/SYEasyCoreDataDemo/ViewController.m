//
//  ViewController.m
//  SYEasyCoreDataDemo
//
//  Created by WeiCheng—iOS_1 on 16/3/7.
//  Copyright © 2016年 com.sunyang. All rights reserved.
//

#import "ViewController.h"
#import "SYEasyCoreDataManager.h"
#import "User+CoreDataProperties.h"

static NSString *cellIdentifier = @"cell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) SYEasyCoreDataManager *coreDataManager;
@end

@implementation ViewController

#pragma mark - Lazy initialized

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[self.coreDataManager queryObjectFromCoreDataWithEntityName:@"User" sortParamters:@{@"age":@(true)}] mutableCopy];
    }
    return _dataArray;
}

- (SYEasyCoreDataManager *)coreDataManager {
    if (!_coreDataManager) {
        _coreDataManager = [SYEasyCoreDataManager sharedCoreDataManager];
    }
    return _coreDataManager;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightBBIClick)];
    self.navigationItem.rightBarButtonItem = rightBBI;
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftBBIClick)];
    self.navigationItem.leftBarButtonItem = leftBBI;
}

- (void)leftBBIClick {
    
}

- (void)rightBBIClick {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    User *user = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",user.username,user.age];
    cell.detailTextLabel.text = user.detail;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    User *userToDelete = self.dataArray[indexPath.row];
    [self.dataArray removeObject:userToDelete];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
