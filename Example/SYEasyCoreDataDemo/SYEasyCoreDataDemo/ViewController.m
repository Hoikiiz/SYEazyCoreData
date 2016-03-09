//
//  ViewController.m
//  SYEasyCoreDataDemo
//
//  Created by SunYang on 16/3/7.
//  Copyright © 2016年 com.sunyang. All rights reserved.
//

#import "ViewController.h"
#import "SYEasyCoreDataManager.h"
#import "User+CoreDataProperties.h"
#import "InfoViewController.h"
static NSString *cellIdentifier = @"cell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) SYEasyCoreDataManager *coreDataManager;

@end

@implementation ViewController

#pragma mark - Lazy initialized

- (NSArray *)dataArray {
    if (!_dataArray) {
        SYEasyCoreDataSortParameter *sp = [[SYEasyCoreDataSortParameter alloc] initWithProper:@"age" acsend:true];
//        SYEasyCoreDataQueryParameter *qp = [[SYEasyCoreDataQueryParameter alloc] initWithKey:@"age" value:@"30" compare:SYEasyCoreDataQueryParameterCompareNotEqual];
        _dataArray = [[self.coreDataManager queryAllObjectFromCoreDataWithEntityName:@"User" options:@{kSYCoreDataSortParameters:@[sp]}] mutableCopy];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataArray = nil;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightBBIClick)];
    self.navigationItem.rightBarButtonItem = rightBBI;
    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(leftBBIClick)];
    self.navigationItem.leftBarButtonItem = leftBBI;
}

- (void)leftBBIClick {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Tips" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Reolad Data",@"Add Data", nil];
    [al show];
}

- (void)rightBBIClick {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)reloadData {
    self.dataArray = nil;
    for (NSInteger i = 0; i < 100; i ++) {
        User *user = (User *)[self.coreDataManager managedObjectWithEntityName:@"User"];
        user.username = @"Counting";
        user.age = @(i + 1);
        user.detail = [NSString stringWithFormat:@"Test data %d",arc4random()%1000];
    }
    [self.coreDataManager save];
    [self.tableView reloadData];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [self reloadData];
            break;
        case 2: {
            InfoViewController *ivc = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
            [self.navigationController pushViewController:ivc animated:YES];
            break;
        }
        default:
            break;
    }
}


@end
