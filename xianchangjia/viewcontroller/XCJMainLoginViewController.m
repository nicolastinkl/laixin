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

@interface XCJMainLoginViewController ()<UITextFieldDelegate>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapges];
    
    {
        UIView * viewKey = (UIView *) [self.view subviewWithTag:2];
        viewKey.top = self.view.height - viewKey.height;
        UILabel *label = (UILabel *) [viewKey subviewWithTag:4];
        label.height = .5f;
    }
    {
        UIView * viewKeyMain = (UIView *) [self.view subviewWithTag:1];
        UILabel *label = (UILabel *) [viewKeyMain subviewWithTag:4];
        label.height = .5f;
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
                 if (yanzhengCode) {
                     NSString * paremsResult = [NSString stringWithFormat:@"PhoneLogin?phone=%@&code=%@",phone,yanzhengCode];
//                     [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
                           [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response2, NSError * error2) {
                               if (!error2) {
                                   /*{
                                    "sessionid":"fxuTnPKqQOwH29a",
                                    "ws":"ws://127.0.0.1:8000/ws",
                                    "timeout":1388472185.910526
                                    }*/
                                   NSString * sessionID =  [response2 objectForKey:@"sessionid"];
                                   NSString * serverURL =  @"ws://192.168.1.11:8000/ws";//[response2 objectForKey:@"ws"];
                                   if (sessionID) {
                                       
                                       [USER_DEFAULT setObject:sessionID forKey:KeyChain_Laixin_account_sessionid];
                                       [USER_DEFAULT setObject:serverURL forKey:KeyChain_Laixin_systemconfig_websocketURL];
                                       [USER_DEFAULT synchronize];
                                       
                                       [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                           // connection of websocket server
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];
                                           /*
                                            {
                                            "func":"function_name",
                                                "parm":{
                                                "parm1":value,
                                                }
                                            }
                                            */
                                           
                                           SRWebSocket * websocket =  [[MLNetworkingManager sharedManager] webSocket];
                                           SLog(@"state : %d", [websocket readyState]);
                                           //        NSDictionary * parames = @{@"func":@"session.start",@"parm":@{@"sessionid":sessionid}};
                                           NSDictionary * parames = @{@"sessionid":sessionID};
                                            [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
                                                NSDictionary * dict = responseObject[@"result"];
                                                LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
                                                 [USER_DEFAULT setObject:currentUser.uid forKey:KeyChain_Laixin_account_user_id];
                                                [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
                                                
                                           } failure:^(MLRequest *request, NSError *error) { 
                                           }];
                                       }];
                                   }
                               }else{
                                   [self loginError];
                               }
                           } withParems:paremsResult];
                 }else{
                     [self loginError];
                 }
             }else{
                 [self loginError];
             }
        } withParems:[NSString stringWithFormat:@"getcode?phone=%@",phone]];
    }];
    
    [sequencer run];
}

-(void) loginError
{
    [UIAlertView showAlertViewWithTitle:@"登陆失败" message:@"用户或密码错误"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRegister"])
    {
        XCJRegisterViewController *vc = (XCJRegisterViewController *)[segue destinationViewController];
        [vc initControlls];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
