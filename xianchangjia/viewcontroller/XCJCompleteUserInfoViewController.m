//
//  XCJCompleteUserInfoViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJCompleteUserInfoViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJSuperViewController.h"
#import "XCJCompleteUploadImgViewController.h"
#import "MLNetworkingManager.h"
#import "UIAlertViewAddition.h"
#import "LXRequestFacebookManager.h"

@interface XCJCompleteUserInfoViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *NickText;
@property (weak, nonatomic) IBOutlet UIButton *ManBtn;
@property (weak, nonatomic) IBOutlet UIButton *MaleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *image_man;
@property (weak, nonatomic) IBOutlet UIImageView *image_male;

@property (weak, nonatomic) IBOutlet UITextField *PhoneText;
@end

@implementation XCJCompleteUserInfoViewController

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
    [self setNeedsStatusBarAppearanceUpdate];
    
	// Do any additional setup after loading the view.
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.NickText becomeFirstResponder];
    });
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(IBAction)popThisView:(id)sender
{
    [self popCurrentViewController];
}

/**
 *  选择男士
 *
 *  @param sender <#sender description#>
 */
- (IBAction)selectManClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.image_man.hidden = NO;
        self.image_male.hidden = YES;
    }];
}

/**
 *  选择女士
 *
 *  @param sender <#sender description#>
 */
- (IBAction)selectMaleClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.image_man.hidden = YES;
        self.image_male.hidden = NO;
    }];
}

-(IBAction)OpenGallery:(id)sender
{
    
    if (self.PhoneText.text.length > 0 && self.PhoneText.text.length < 11) {
        [UIAlertView showAlertViewWithMessage:@"电话号码必须是11位,您可以选择不填"];
        return;
    }
    UIAlertView  * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"选择性别后将不可更改" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        if (self.NickText.text.length > 1) {
            int sex = 0;
            if (!self.image_man.hidden) {
                sex  = 1;
            }
            else if (!self.image_male.hidden)
            {
                sex  = 2;
            }else{
                sex  = 0;
            }
            [self.NickText resignFirstResponder];
            [SVProgressHUD show];
            if (self.PhoneText.text.length == 11) {
                //这里才进入查找处理
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.find"  parameters:@{@"phone":self.PhoneText.text} success:^(MLRequest *request, id responseObject) {
                    NSDictionary * resultDict = responseObject[@"result"];
                    NSArray * array = [DataHelper getArrayValue:resultDict[@"users"] defaultValue:[NSMutableArray array]];
                    
                    NSDictionary *userinfo = [array lastObject];
                    if (userinfo && array.count > 0) {
                        LXUser * user = [[LXUser alloc] initWithDict:userinfo];
                        [[MLNetworkingManager sharedManager] sendWithAction:@"circle.by_user" parameters:@{@"uid": user.uid} success:^(MLRequest *request, id responseObject) {
                            /*!
                             *  更新昵称
                             */
                            [self completeUserNick:sex];
                        } failure:^(MLRequest *request, NSError *error) {
                             [UIAlertView showAlertViewWithMessage:@"当前联系人激活失败"];
                        }];
                    }else{
                        [UIAlertView showAlertViewWithMessage:@"当前号码没有此联系人"];
                    }
                    
                } failure:^(MLRequest *request, NSError *error) {
                }];
            }else{
                /*!
                 *  更新昵称
                 */
                [self completeUserNick:sex];
            }
            
          
            
        }else{
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"昵称不可用"];
        }
        
        //  ios 高级 “美餐网” 外卖，o2o
        
    }
    
}

-(void) completeUserNick:(int) sex
{

    NSDictionary * parames = @{@"nick":self.NickText.text,@"sex":@(sex),@"position":@"四川 成都"};
    //nick, signature,sex, birthday, marriage, height
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
        [SVProgressHUD dismiss];
        
        XCJCompleteUploadImgViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCompleteUploadImgViewController"];
        [self.navigationController pushViewController:viewContr animated:YES];
    } failure:^(MLRequest *request, NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
