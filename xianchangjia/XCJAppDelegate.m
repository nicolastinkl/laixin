//
//  XCJAppDelegate.m
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJAppDelegate.h"
#import "CRGradientNavigationBar.h"
#import "XCAlbumDefines.h"
#import "SinaWeibo.h"
#import "XCJLoginViewController.h"

#import "ChatList.h"
#import "MLNetworkingManager.h"


#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]
@interface XCJAppDelegate()

@property (nonatomic,strong) UITabBarController *tabBarController;

@end

@implementation XCJAppDelegate
@synthesize sinaweiboMain;
@synthesize mainNavigateController;


#pragma mark ChatListNeedUpdateToalUnreadCountNotification

- (void)updateMessageTabBarItemBadge
{
    if (!self.tabBarController) {
        self.tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
    }
    //更新其未读消息总数
    NSUInteger totalCount = [[[ChatList shareInstance] valueForKeyPath:@"array.@sum.unreadCount"] integerValue];
    if (totalCount>0) {
        NSString *badge = @"99+";
        if (totalCount<=99) {
            badge = [NSString stringWithFormat:@"%d",totalCount];
        }
        [self.tabBarController.tabBar.items[2] setBadgeValue:badge];
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalCount;
    }else{
        [self.tabBarController.tabBar.items[2] setBadgeValue:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
//    NSDictionary *userInfo  = notification.userInfo;
    
}

-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xf16149).CGColor, (id)UIColorFromRGB(0xf14959).CGColor, nil];
    ///setup 4:
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
   
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /**
     *  login view navigationbar
     */
    mainNavigateController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    //NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xFFFFFF).CGColor, (id)UIColorFromRGB(0xFFFFFF).CGColor, nil];
    //    ///setup 4:
    //[[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[mainNavigateController navigationBar] setTranslucent:YES];
    [[mainNavigateController navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[ChatList shareInstance]getDataFromLocalDB]; //从本地存储获得
    [self updateMessageTabBarItemBadge]; //更新未读条目数
    //添加监视
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageTabBarItemBadge) name:ChatListNeedUpdateToalUnreadCountNotification object:nil];
    
    //添加WebSocket监视
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSocketDidReceivePushMessage:) name:MLNetworkingManagerDidReceivePushMessageNotification object:nil];
    
    
    
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

//    ///setup 1:
   
//    ///setup 2:
    UIColor *firstColor =  [UIColor colorWithRed:255.0f/255.0f green:42.0f/255.0f blue:104.0f/255.0f alpha:1.0f];
    UIColor *secondColor = [UIColor colorWithRed:255.0f/255.0f green:90.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
//    ///setup 3:
   //NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xf16149).CGColor, (id)UIColorFromRGB(0xf14959).CGColor, nil];
//    ///setup 4:
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[navigationController navigationBar] setTranslucent:YES]; // Remember, the default value is YES.
    ///setup 5:
//    DemoViewController *viewController = [[DemoViewController alloc] init];
//    [navigationController setViewControllers:@[viewController]];
    
//    [self.window setRootViewController:navigationController];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
     */
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void) initWeiboView
{
    XCJLoginViewController * viewcon = (XCJLoginViewController*)mainNavigateController.topViewController;
    /*sina weibo*/
	sinaweiboMain = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:xianchangjiaURI andDelegate:viewcon];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        sinaweiboMain.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        sinaweiboMain.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        sinaweiboMain.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sinaweiboMain handleOpenURL:url]) {
		return  [sinaweiboMain handleOpenURL:url];
	}
    return YES;
}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([sinaweiboMain handleOpenURL:url]) {
		return  [sinaweiboMain handleOpenURL:url];
	}
    return YES;
}

 
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
