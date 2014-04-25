//
//  XCJLoginViewController.m
//  xianchangjia
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJLoginViewController.h"
#import "XCJAppDelegate.h"
#import "UIAlertViewAddition.h"
#import "UIAlertView+AFNetworking.h"
#import "XCAlbumAdditions.h"

@interface XCJLoginViewController ()

@end

@implementation XCJLoginViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (SinaWeibo *)sinaweibo
{
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweiboMain;
}

- (IBAction)SinaLoginClick:(id)sender {
    
    SinaWeibo *sinaweibo = [self sinaweibo];
    if (!sinaweibo) {
        sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:xianchangjiaURI andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
        if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
        {
            sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
            sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
            sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
        }
    }
    [sinaweibo logIn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate initWeiboView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    SLog(@"%@",[response URL]);
}

- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    SLog(@"didReceiveRawData");
}
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    SLog(@"didFailWithError");
}
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    SLog(@"didFinishLoadingWithResult");
    
}

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn");
	// 判断是否有数据 没有登录失败
	if(!sinaweibo||!sinaweibo.userID||!sinaweibo.accessToken){
        [UIAlertView showAlertViewWithMessage:@"登陆失败"];
		return;
	}
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
	[ud  setValue:sinaweibo.userID forKey:GlobalData_sinaweibo_userID];
	[ud  setValue:sinaweibo.accessToken forKey:GlobalData_sinaweibo_accesstoken];
	[ud  setValue:sinaweibo.refreshToken forKey:GlobalData_sinaweibo_refresh_token];
	[ud  setValue:sinaweibo.expirationDate forKey:GlobalData_sinaweibo_expirationDate];
	[ud synchronize];
	
	NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *postdata=[[NSMutableDictionary alloc] init];
	if (sinaweibo.refreshToken) {
		[postdata setObject:sinaweibo.refreshToken forKey:@"access_token"];
	}else{
		[postdata setObject:sinaweibo.accessToken forKey:@"access_token"];
	}
	[postdata setObject:@"1" forKey:@"first_signin"];
    [postdata setObject:@"ios" forKey:@"platform"];
	[postdata setObject:@"200" forKey:@"version"];
    [postdata setObject:sinaweibo.userID forKey:@"fb_id"];
    NSString *oldsession=[[NSUserDefaults standardUserDefaults] objectForKey:GlobalData_user_session];
    if(oldsession)
    {
		[postdata setObject:oldsession forKey:@"sessionid"];
	}
    SLog(@"dic=====%@",authData);
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"user" Action:@"signin_by_sina_weibo" success:^(id dic) {
		SLog(@"dic=====%@",dic);
		if([self  respondsToSelector:@selector(endLogin:)])
		{
			[self performSelector:@selector(endLogin:) withObject:dic];
		}
	} error:^(NSInteger index) {
		[self performSelector:@selector(endLoginError)];
	} failure:^(NSError *error) {
		[self performSelector:@selector(endLoginError)];
	}];
    
}

-(void) endLogin:(NSMutableDictionary*)result
{
	if (result)
    {
		if (![result objectForKey:@"user"]) {
			[self performSelector:@selector(endLoginError)];
			return;
		}
		//sessionid  force_update   client_vision
		[USER_DEFAULT setObject:[result objectForKey:@"sessionid"] forKey:GlobalData_user_session];
        //		[USER_DEFAULT setObject:[result objectForKey:@"force_update"] forKey:GlobalData_force_update];
		NSDictionary * userinfo = [result objectForKey:@"user"];
		[[GlobalData sharedGlobalData] pullUserData:userinfo];  //初始化个人信息
		[USER_DEFAULT setValue:[NSNumber numberWithBool:YES] forKey:GlobalData_hasSuccessedLogin];
		[[GlobalData sharedGlobalData] initCurrentDeciviceDBDataBase];
//		[[GlobalData sharedGlobalData] initCurrentDecivice];
		/*login success*/
		[[NSNotificationCenter defaultCenter] postNotificationName:GlobalData_XMPP_NEWINVITE_REGISTER_NEWACCOUNT object:nil];
#pragma mark   初始化数据库
		[GCDHelper dispatchBlock:^{
			NSString *key = [NSString stringWithFormat:@"Key_Show_Home_TargetToSecoundView_Marks_v.%@", [BundleHelper bundleShortVersionString]];
			[USER_DEFAULT setBool:NO forKey:key];
			//sign user status is login success
			[USER_DEFAULT setObject:@"YES" forKey:GlobalData_CACHE_USER_EXIT_STATUS];
			[USER_DEFAULT setBool:YES forKey:GlobalData_user_Mainview_guid];
			[USER_DEFAULT setInteger:0  forKey:GlobalData_user_Mainview_guid_count];
			[USER_DEFAULT setBool:NO forKey:GlobalData_stopsyncweibo];
			[USER_DEFAULT setBool:NO forKey:GlobalData_notifysound];
			[USER_DEFAULT setBool:NO forKey:GlobalData_OPENMUSICLOCATION];
			[USER_DEFAULT setBool:NO forKey:@"logoutClick"];
			[USER_DEFAULT setBool:YES forKey:GlobalData_recommend_scene];
			[USER_DEFAULT setBool:YES forKey:GlobalData_recommend_user];
			[USER_DEFAULT synchronize];
			/*初始化首页数据*/
			[[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];		//通知mainappController 更新本地资料
			
		} completion:^{
			[self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
		}];
	}
	else
	{
		[self performSelector:@selector(endLoginError)];
	}
    
}


-(void) endLoginError
{
	[UIAlertView showAlertViewWithMessage:@"登陆失败"];
    
	if ([self sinaweibo]) {
        [[self sinaweibo] logOut];
    }
}


- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    if ([self sinaweibo]) {
//       [[self sinaweibo] logOut];
    }
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    SLog(@"sinaweiboLogInDidCancel");
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    SLog(@"logInDidFailWithError %@",[error userInfo]);
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    SLog(@"accessTokenInvalidOrExpired %@",[error userInfo]);
}


@end
