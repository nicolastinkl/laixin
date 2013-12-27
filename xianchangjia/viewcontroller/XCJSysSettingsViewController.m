//
//  XCJSysSettingsViewController.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJSysSettingsViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJMainLoginViewController.h"
#import "XCJAppDelegate.h"
#import "UIAlertViewAddition.h"

@interface XCJSysSettingsViewController ()<UIAlertViewDelegate>

@end

@implementation XCJSysSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)logoutClick:(id)sender {
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注销当前账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注销", nil];
    [alertview show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        [USER_DEFAULT removeObjectForKey:GlobalData_main_server];
        [USER_DEFAULT removeObjectForKey:GlobalData_user_session];
        [USER_DEFAULT synchronize];
        
        XCJMainLoginViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMainLoginViewController"];
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.mainNavigateController pushViewController:viewContr animated:NO];
        [self presentViewController:delegate.mainNavigateController animated:NO completion:^{
            delegate.tabBarController.selectedIndex = 0;
        }];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
