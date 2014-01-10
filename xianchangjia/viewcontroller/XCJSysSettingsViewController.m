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
        [USER_DEFAULT removeObjectForKey:KeyChain_Laixin_account_sessionid];
        [USER_DEFAULT synchronize];
        
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.tabBarController.selectedIndex = 0;
        UINavigationController * XCJLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"XCJLoginNaviController"];
        [self presentViewController:XCJLoginNaviController animated:NO completion:nil];
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
