//
//  XCJRegisterViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJRegisterViewController.h"
#import "XCAlbumAdditions.h"
#import "NSString+Addition.h"
#import "UIAlertViewAddition.h"
#import "Sequencer.h"
#import "LXAPIController.h"
#import "MLNetworkingManager.h"
#import "LXRequestFacebookManager.h"
#import "XCJCompleteUserInfoViewController.h"

@interface XCJRegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *PhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *yanzhengNumber;
@property (weak, nonatomic) IBOutlet UIImageView *image_success;
@property (weak, nonatomic) IBOutlet UIButton *button_getYanzhengma;

@property (weak, nonatomic) IBOutlet UIButton *button_Next;
@property (weak, nonatomic) IBOutlet UILabel *Label_text;


@end

@implementation XCJRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)GetYanzhengClick:(id)sender {
    // 验证手机号码是否正确
    if ([self.PhoneNumber.text isValidPhone])
    {
        [self.PhoneNumber resignFirstResponder];
        [self runSequncer:self.PhoneNumber.text];
    }
    else
    {
        [UIAlertView showAlertViewWithMessage:@"手机号码格式错误"];
        //提示输入正确手机号码
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    self.image_success.hidden = YES;
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.PhoneNumber becomeFirstResponder];
    });
}

- (void) initControlls
{
    UIButton * buttonBack = (UIButton *) [self.view subviewWithTag:11];
    UIButton * buttonNext = (UIButton *) [self.view subviewWithTag:12];
    [buttonBack addTarget:self action:@selector(BackClick:) forControlEvents:UIControlEventTouchUpInside];
     [buttonNext addTarget:self action:@selector(CompleteClick:) forControlEvents:UIControlEventTouchUpInside];
   
}

- (void) initFindPwdControlls{
    UIButton * buttonBack = (UIButton *) [self.view subviewWithTag:11];
    [buttonBack addTarget:self action:@selector(BackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.Label_text.text = @"";
    [self.button_Next setTitle:@"下一步" forState:UIControlStateNormal];
    [self.button_Next addTarget:self action:@selector(CompleteClick:) forControlEvents:UIControlEventTouchUpInside];
}

//#warning get user infomation  with get pwd
-(IBAction)getPwdClick:(id)sender
{
    //get user infomation
    {
        return;
        // connection of websocket server
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
}


//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{

    // MARK just test
    //setup 1: http://192.168.1.7:8080/getcode?phone=13067575126  reponse :{"code": "2931"}
    //setup 2:http://192.168.1.7:8080/PhoneLogin?phone=13067575126&code=5660 response : {"sessionid": "Iq3sReGP7tOgezR", "ws": "ws:\/\/127.0.0.1:8000\/ws", "timeout": 1388460332.698927}
    // next resperform action login
//}


-(IBAction)BackClick:(id)sender
{
    
    if ([self.PhoneNumber isFirstResponder]) {
        [self.PhoneNumber resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)CompleteClick:(id)sender
{
    if (self.yanzhengNumber.text.length < 4) {
        [UIAlertView showAlertViewWithMessage:@"请填写正确验证码"];
        return;
    }
    
    if ([self.yanzhengNumber isFirstResponder]) {
        [self.yanzhengNumber resignFirstResponder];
    }
    
    if ([self.PhoneNumber isFirstResponder]) {
        [self.PhoneNumber resignFirstResponder];
    }
    
    if ( self.yanzhengNumber.text.length &&  self.PhoneNumber.text) {
        [SVProgressHUD show];
        NSString * paremsResult = [NSString stringWithFormat:@"PhoneLogin?phone=%@&code=%@",self.PhoneNumber.text,self.yanzhengNumber.text];
        //                     [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response2, NSError * error2) {
            if (!error2) {
                /*{
                 "sessionid":"fxuTnPKqQOwH29a",
                 "ws":"ws://127.0.0.1:8000/ws",
                 "timeout":1388472185.910526
                 }*/
                NSString * sessionID = [DataHelper getStringValue:response2[@"sessionid"] defaultValue:@"" ];
                NSString * serverURL =  [DataHelper getStringValue:response2[@"wss"] defaultValue:@"" ];
                if (sessionID.length > 0) {
                    [USER_DEFAULT setObject:sessionID forKey:KeyChain_Laixin_account_sessionid];
                    [USER_DEFAULT setObject:serverURL forKey:KeyChain_Laixin_systemconfig_websocketURL];
                    [USER_DEFAULT synchronize];
                    
                    [[MLNetworkingManager sharedManager] webSocket];  // connection
                    NSDictionary * parames = @{@"sessionid":sessionID};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
                        [SVProgressHUD dismiss];
                        NSDictionary * dict = responseObject[@"result"];
                        LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
                        [USER_DEFAULT setObject:currentUser.uid forKey:KeyChain_Laixin_account_user_id];
                        [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
                        XCJCompleteUserInfoViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCompleteUserInfoViewController"];
                        [self.navigationController pushViewController:viewContr animated:YES];
                    } failure:^(MLRequest *request, NSError *error) {
                        [self loginError];
                    }];
                    //setup next viewcontroller
                }
            }else{
                [self loginError];
            }
        } withParems:paremsResult];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)runSequncer :(NSString * )phone
{
    Sequencer *sequencer = [[Sequencer alloc] init];
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        [SVProgressHUD showWithStatus:@"正在获取验证码"];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError * error) {
            if (!error) {
                NSString * yanzhengCode =  [response objectForKey:@"code"];
                if (yanzhengCode) {
                    [SVProgressHUD dismiss];
                    
                    NSString * string = [MobClick getConfigParams:@"AutoFillYanzhengma"];
                    if ([string isEqualToString:@"1"]) {

                        self.yanzhengNumber.text = yanzhengCode;
                    }
                    [self.yanzhengNumber becomeFirstResponder];
                    
//                    self.image_success.hidden = NO;
                    self.button_getYanzhengma.enabled = NO;
                }else{
                    [self loginError:@"获取验证码失败"];
                }
            }else{
                [self loginError:@"获取验证码失败,请检查网络设置"];
            }
        } withParems:[NSString stringWithFormat:@"getcode?phone=%@",phone]];
    }];
    [sequencer run];
}

-(void) loginError
{
    [SVProgressHUD dismiss];
    [UIAlertView showAlertViewWithTitle:@"失败" message:@"验证码出错"];
}

-(void) loginError:(NSString * ) msg
{
    [SVProgressHUD dismiss];
    [UIAlertView showAlertViewWithTitle:@"错误" message:msg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
