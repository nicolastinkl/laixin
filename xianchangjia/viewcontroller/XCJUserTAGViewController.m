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

@interface XCJUserTAGViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

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

    if (colorindex > 7) {
        colorindex = 6;
    }
    
    UITextView * textview =  (UITextView * ) [self.view subviewWithTag:5];
    if (IS_4_INCH)
        [textview setHeight:250.0f];
    else
        [textview setHeight:150.0f];
    
    
    UIImageView * imview =  (UIImageView * ) [self.view subviewWithTag:3];
    imview.layer.cornerRadius = 5;
    imview.layer.masksToBounds = YES;
    imview.image = [UIImage imageNamed:[NSString stringWithFormat:@"med-name-bg-%d",colorindex]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(SeetingsClick:)];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     [self.navigationController popViewControllerAnimated:YES];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
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
}
-(IBAction)SeetingsClick:(id)sender
{
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确定设置标签后将不可修改" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定设置" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
