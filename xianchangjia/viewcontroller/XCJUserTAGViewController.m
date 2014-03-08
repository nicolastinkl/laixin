//
//  XCJUserTAGViewController.m
//  laixin
//
//  Created by apple on 3/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJUserTAGViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"

@interface XCJUserTAGViewController ()<UIAlertViewDelegate>

@end

@implementation XCJUserTAGViewController

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
    
    self.title = @"设置个性标签";
    
    self.hidesBottomBarWhenPushed = YES;
    
    UILabel * label =  (UILabel * ) [self.view subviewWithTag:1];
    [label setText:self.tags];
    int colorindex = arc4random() % 6 + 1 ;
    label.backgroundColor  = [tools colorWithIndex:colorindex];
    
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    
    UIButton * button =  (UIButton * ) [self.view subviewWithTag:2];
    [button infoStyle];
    
    [button addTarget:self action:@selector(SeetingsClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)SeetingsClick:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在处理中..."];
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.update" parameters:@{@"tags":@[self.tags]} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            [SVProgressHUD dismiss];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"设置成功" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"设置失败,请重试"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
