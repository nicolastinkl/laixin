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
#import "XCJLoginNaviController.h"
#import "XCJAboutViewController.h"


@interface XCJSysSettingsViewController ()<UIAlertViewDelegate>

@end

@implementation XCJSysSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
        [SVProgressHUD show];
        double delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //ios.unreg()   logout
            [[MLNetworkingManager sharedManager] sendWithAction:@"ios.unreg" parameters:@{} success:^(MLRequest *request, id responseObject) {
                [[[MLNetworkingManager sharedManager] webSocket] close];
                // clear You can remove the application's persistent domain like this:
                NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LaixinCloseDBMessageNotification object:nil];
                
                XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
                delegate.tabBarController.selectedIndex = 0;
                [SVProgressHUD dismiss];
                UINavigationController * XCJLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"XCJLoginNaviController"];
                [self presentViewController:XCJLoginNaviController animated:NO completion:nil];

            } failure:^(MLRequest *request, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"注销失败"];
            }];
        });
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // check out update sdk
            [MobClick checkUpdate];
            [UIAlertView showAlertViewWithMessage:@"已经是最新版本"];
        }
        
        if (indexPath.row == 1) {
            // check out update sdk
            [SVProgressHUD showSuccessWithStatus:@"清理完成"];
        }
        
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
     ShowService
     ShowPrivate
     ShowAboutLaixin
     */
    XCJAboutViewController * view = (XCJAboutViewController *)  segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"ShowService"]) {
        view.title = @"服务协议";
        view.viewTypeIndex = serviceview;
    }else if ([segue.identifier isEqualToString:@"ShowPrivate"]) {
        view.title = @"隐私政策";
        view.viewTypeIndex = privateview;
    }else if ([segue.identifier isEqualToString:@"ShowAboutLaixin"]) {
        view.title = @"关于来信";
        view.viewTypeIndex = aboutview;
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
