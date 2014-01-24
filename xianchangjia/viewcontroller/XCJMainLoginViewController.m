//
//  XCJMainLoginViewController.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJMainLoginViewController.h"
#import "XCAlbumAdditions.h"
#import "Sequencer.h"
#import "LXAPIController.h"
#import "LXRequestFacebookManager.h"
#import "NSString+Addition.h"
#import "UIAlertViewAddition.h"
#import "MLNetworkingManager.h"
#import "XCJRegisterViewController.h"
#import "XCJAppDelegate.h"
#import "FCAccount.h"
#import "CoreData+MagicalRecord.h"

@interface XCJMainLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *button_yanzhengCode;

@end

@implementation XCJMainLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapges];
    
    {
        UIView * viewKey = (UIView *) [self.view subviewWithTag:2];
        viewKey.top = self.view.height - viewKey.height;
        UILabel *label = (UILabel *) [viewKey subviewWithTag:3];
        label.width = .5f;
    }
    {
        UIView * viewKeyMain = (UIView *) [self.view subviewWithTag:1];
        UIButton *loginButton = (UIButton *) [viewKeyMain subviewWithTag:5];
        
        {
//            UIImage* originalImage =[[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_normal"] stretchableImageWithLeftCapWidth:11.0 topCapHeight:0.0];
            //normal
            UIImage *originalImage = [UIImage imageNamed:@"fbc_promobutton_36_2_5_2_5_normal"];
            UIEdgeInsets insets = UIEdgeInsetsMake(2,5,2,5);
            UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
            [loginButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
        }
        {
            //Highlighted
            UIImage *originalImage = [UIImage imageNamed:@"fbc_promobutton_36_2_5_2_5_highlighted.png"];
            UIEdgeInsets insets = UIEdgeInsetsMake(2,5,2,5);
            UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
            [loginButton setBackgroundImage:stretchableImage forState:UIControlStateHighlighted];
        }
        
        [loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        //266 30
    }
}

-(IBAction)getyanzhengCode:(id)sender
{
 
    UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
    UITextField * phoneText = (UITextField *) [viewKey subviewWithTag:2];
    if ([phoneText.text isValidPhone])
    {
        [SVProgressHUD show];
        [self runSequncer:phoneText.text];
    }
    else
    { 
        [UIAlertView showAlertViewWithMessage:@"手机号码格式错误"];
        //提示输入正确手机号码
    }
}
-(IBAction) loginClick:(id)sender
{
    UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
    UITextField * phoneText = (UITextField *) [viewKey subviewWithTag:2];
    UITextField * pwdText = (UITextField *) [viewKey subviewWithTag:3];
    
    if (phoneText.text.length == 11 && pwdText.text.length >= 4) {
        if ([phoneText.text isValidPhone])
        {
            
            if ([phoneText isFirstResponder]) {
                [phoneText resignFirstResponder];
            }
            
            if ([pwdText isFirstResponder]) {
                [pwdText resignFirstResponder];
            }
    
            [self loginwithPhonePwd:phoneText.text pwd:pwdText.text];
        }
        else
        {
            [UIAlertView showAlertViewWithMessage:@"手机号码格式错误"];
        }
    }else{
        [UIAlertView showAlertViewWithMessage:@"请输入正确手机号或验证码"];
    }
}

-(void)hideKeyboard
{
    UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
    UITextField * phoneText = (UITextField *) [viewKey subviewWithTag:2];
    UITextField * pwdText = (UITextField *)  [viewKey subviewWithTag:3];
    if ([phoneText isFirstResponder]) {
        [phoneText resignFirstResponder];
    }
    if ([pwdText isFirstResponder]) {
        [pwdText resignFirstResponder];
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
        viewKey.top = 0;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        // default top is 70  when keyboard show ... 0
        UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
        viewKey.top = 70;
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
    UITextField * phoneText = (UITextField *) [viewKey subviewWithTag:2];
    UITextField * pwdText = (UITextField *) [viewKey subviewWithTag:3];
    if (textField == phoneText) {
        if (textField.text.length >= 1)
            ((UIImageView *) [viewKey subviewWithTag:6]).image = [UIImage imageNamed:@"login_user_highlighted_os7"];
        else
            ((UIImageView *) [viewKey subviewWithTag:6]).image = [UIImage imageNamed:@"login_user_os7"];
        
    }else if (textField == pwdText)
    {
        if (textField.text.length >= 1)
            ((UIImageView *) [viewKey subviewWithTag:7]).image = [UIImage imageNamed:@"login_key_highlighted_os7"];
        else
            ((UIImageView *) [viewKey subviewWithTag:7]).image = [UIImage imageNamed:@"login_key_os7"];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 3) {
        // 验证手机号码是否正确
        UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
        UITextField * phoneText = (UITextField *) [viewKey subviewWithTag:2];
        if ([phoneText.text isValidPhone])
            [self runSequncer:phoneText.text];
        else
        {
            [UIAlertView showAlertViewWithMessage:@"手机号码格式错误"];
            //提示输入正确手机号码
            return  NO;
        }
        
         return YES;
    }
    
    // MARK just test
    //setup 1: http://192.168.1.7:8080/getcode?phone=13067575126  reponse :{"code": "2931"}
    //setup 2:http://192.168.1.7:8080/PhoneLogin?phone=13067575126&code=5660 response : {"sessionid": "Iq3sReGP7tOgezR", "ws": "ws:\/\/127.0.0.1:8000\/ws", "timeout": 1388460332.698927}
    // next resperform action login
    
    return NO;
}

- (void)runSequncer :(NSString * )phone
{
    Sequencer *sequencer = [[Sequencer alloc] init];
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError * error) {
             if (!error) {
                 NSString * yanzhengCode =  [response objectForKey:@"code"];
                 if (yanzhengCode.length > 0) {
                     [SVProgressHUD dismiss];
                     self.button_yanzhengCode.enabled = NO;
                     
                     NSString * string = [MobClick getConfigParams:@"AutoFillYanzhengma"];
                     if ([string isEqualToString:@"1"]) {
                         
                         UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
                         UITextField * pwdText = (UITextField *) [viewKey subviewWithTag:3];
                         pwdText.text = yanzhengCode;
                         
                     }
                     
                 }else{
                     self.button_yanzhengCode.enabled = YES;
                     [SVProgressHUD showErrorWithStatus:@"获取验证码失败"];
                 }
             }else{
                     self.button_yanzhengCode.enabled = YES;
                 [SVProgressHUD showErrorWithStatus:@"获取验证码失败"];
             }
        } withParems:[NSString stringWithFormat:@"getcode?phone=%@",phone]];
    }];
    
    [sequencer run];
}

-(void) loginwithPhonePwd:(NSString * ) phone pwd:(NSString * ) yanzhengCode
{
    [SVProgressHUD show];
    NSString * paremsResult = [NSString stringWithFormat:@"PhoneLogin?phone=%@&code=%@",phone,yanzhengCode];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response2, NSError * error2) {
        if (response2) {
            /*{
             "sessionid":"fxuTnPKqQOwH29a",
             "ws":"ws://127.0.0.1:8000/ws",
             "timeout":1388472185.910526
             }*/
            NSString * sessionID = [DataHelper getStringValue:response2[@"sessionid"] defaultValue:@""];
            NSString * serverURL = [DataHelper getStringValue:response2[@"ws"] defaultValue:@""];
           // NSString * timeout = [DataHelper getStringValue:response2[@"timeout"] defaultValue:@""];
            
            if (sessionID.length > 1) {
                
                [USER_DEFAULT setObject:sessionID forKey:KeyChain_Laixin_account_sessionid];
                [USER_DEFAULT setObject:serverURL forKey:KeyChain_Laixin_systemconfig_websocketURL];
                [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_account_HasLogin];
                [USER_DEFAULT synchronize];
                
                SRWebSocket * websocket =  [[MLNetworkingManager sharedManager] webSocket];
                if ( [websocket readyState] > SR_OPEN ) {
                    [websocket open];
                }
                SLLog(@"state : %d", [websocket readyState]);
                // connection of websocket server
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];
                 
                [SVProgressHUD dismiss];
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                }];
            }else{
                [self loginError];   
            }
        }else{
            [self loginError];
        }
    } withParems:paremsResult];
}

-(void) loginError
{
    [SVProgressHUD dismiss];
    [UIAlertView showAlertViewWithTitle:@"登陆失败" message:@"用户或验证码错误"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRegister"])
    {
        XCJRegisterViewController *vc = (XCJRegisterViewController *)[segue destinationViewController];
        [vc initControlls];
    }else if ([[segue identifier] isEqualToString:@"showforgetPwd"])
    {
        XCJRegisterViewController *vc = (XCJRegisterViewController *)[segue destinationViewController];
        UILabel * title  = (UILabel *) [vc.view subviewWithTag:5];
        title.text = @"找回用户";
        [vc initFindPwdControlls];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
