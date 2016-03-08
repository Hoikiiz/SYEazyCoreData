//
//  InfoViewController.m
//  SYEasyCoreDataDemo
//
//  Created by WeiCheng—iOS_1 on 16/3/8.
//  Copyright © 2016年 com.sunyang. All rights reserved.
//

#import "InfoViewController.h"
#import "SYEasyCoreDataManager.h"
#import "User+CoreDataProperties.h"

@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *detailTF;
@property (strong, nonatomic) SYEasyCoreDataManager *coreDataManager;
@end


@implementation InfoViewController

- (SYEasyCoreDataManager *)coreDataManager {
    if (!_coreDataManager) {
        _coreDataManager = [SYEasyCoreDataManager sharedCoreDataManager];
    }
    return _coreDataManager;
}

- (IBAction)confirmBtnClick:(id)sender {
    NSString *username = self.usernameTF.text?:@"Defalut";
    NSNumber *age = [NSNumber numberWithInteger:self.ageTF.text.integerValue]?:@0;
    NSString *detail = self.detailTF.text?:@"Nothing";
    User *user = (User *)[self.coreDataManager managedObjectWithEntityName:@"User"];
    user.username = username;
    user.age = age;
    user.detail = detail;
    [self.coreDataManager save];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
