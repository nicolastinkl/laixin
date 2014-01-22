//
//  XCJJIhuoViewController.m
//  laixin
//
//  Created by apple on 14-1-22.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJJIhuoViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "QRCodeGenerator.h"


@interface XCJJIhuoViewController ()<UIActionSheetDelegate>

@end

@implementation XCJJIhuoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    int activeCode = [LXAPIController sharedLXAPIController ].currentUser.actor_level;
    if (activeCode <= 0 ) {
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在获取激活码..."];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[MLNetworkingManager sharedManager] sendWithAction:@"active.generate_code" parameters:@{@"level":@(activeCode)} success:^(MLRequest *request, id responseObject) {
            //Result={"active_code":"wD9IECBQRxUyFvo","level":1}
            if (responseObject) {
                NSDictionary * dict = responseObject[@"result"];
                NSString * stringCode = [DataHelper getStringValue:dict[@"active_code"] defaultValue:@""];
                ((UILabel *)[self.view subviewWithTag:1]).text = stringCode;

                ((UIImageView *)[self.view subviewWithTag:2]).image =  [QRCodeGenerator qrImageForString:stringCode imageSize:216.0f];
            }
            [SVProgressHUD dismiss];
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];            
        }];
    });
}

-(IBAction)ShareCode:(id)sender
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享激活码" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制激活码" otherButtonTitles:@"短信",@"微信好友", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:  ((UILabel *)[self.view subviewWithTag:1]).text];
        
    } else if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"SMS:%@",((UILabel *)[self.view subviewWithTag:1]).text]]];
    } else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"MAIL:%@",((UILabel *)[self.view subviewWithTag:1]).text]]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
