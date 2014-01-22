//
//  XCJActiveViewController.m
//  laixin
//
//  Created by apple on 14-1-22.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJActiveViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "UIAlertViewAddition.h"

@interface XCJActiveViewController ()

@end

@implementation XCJActiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)hiddenKeyboard:(id)sender
{
    UITextField * text =     ((UITextField *) [self.view subviewWithTag:1]);
    if ([text isFirstResponder]) {
        [text resignFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton * button = ((UIButton *) [self.view subviewWithTag:2]);
    [button infoStyle];
    [button addTarget:self action:@selector(activeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    ((UITextField *) [self.view subviewWithTag:1]).text = self.code;
}

-(IBAction)activeClick:(id)sender
{
    UITextField * text =     ((UITextField *) [self.view subviewWithTag:1]);
    NSString * CurrentCode = text.text;
    if (CurrentCode && CurrentCode.length > 0) {
        [SVProgressHUD show];
        [[MLNetworkingManager sharedManager] sendWithAction:@"active.do" parameters:@{@"active_code":CurrentCode} success:^(MLRequest *request, id responseObject) {
            //	Result={"active_level":1,"active_by":1}
            if (responseObject) {
                NSDictionary * result = responseObject[@"result"];
                //返回激活等级和激活者的id
                NSInteger level = [DataHelper getIntegerValue:result[@"active_level"] defaultValue:0];
                if (level > 0) {
                    
                }
                
                [SVProgressHUD dismiss];
                NSString * activeByUID =  [DataHelper getStringValue:result[@"active_by"]  defaultValue:@""];
                if (activeByUID.length > 0) {
                    // check this uid is my friends???
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesByNetCompletion:^(id response, NSError *error) {
                        [[[LXAPIController sharedLXAPIController]  chatDataStoreManager] setFriendsUserDescription:response];
                    } withuid:activeByUID];
                    
                    [UIAlertView showAlertViewWithMessage:@"激活成功"];
                }else{
                    [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
                }
            }
            
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
        }];
    }else{
        [UIAlertView showAlertViewWithMessage:@"请输入正确激活码"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
