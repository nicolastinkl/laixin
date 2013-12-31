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
#import "tools.h"
#import "ChatList.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "CoreData+MagicalRecord.h"
#import "LXChatDBStoreManager.h"
#import "XCJLoginNaviController.h"

static NSString * const kLaixinStoreName = @"Laixins.sqlite";

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]
@interface XCJAppDelegate()



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

///所有消息接收器
- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    /*NSDictionary * MsgContent  = notification.userInfo;
    NSString *requestKey = [tools getStringValue:MsgContent[@"cdata"] defaultValue:nil];
    if ([requestKey isEqualToString:@"LoginSuccess"]) {
        
    }else if([requestKey isEqualToString:@"user.info"])
    {
        
    }
    SLog(@"webSocketDidReceivePushMessage : %@",requestKey);*/
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
//    mainNavigateController = [[XCJLoginNaviController alloc] init];
//    [[mainNavigateController navigationBar] setBarStyle:UIBarStyleBlack];
//
//    
//     [[mainNavigateController navigationBar] setTranslucent:YES];
    //NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xFFFFFF).CGColor, (id)UIColorFromRGB(0xFFFFFF).CGColor, nil];
    //    ///setup 4:
    //[[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
//    [[mainNavigateController navigationBar] setTranslucent:YES];
//    [[mainNavigateController navigationBar] setHidden:YES];

    
//    [[ChatList shareInstance]getDataFromLocalDB]; //从本地存储获得
//    [self updateMessageTabBarItemBadge]; //更新未读条目数
//    //添加监视
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageTabBarItemBadge) name:ChatListNeedUpdateToalUnreadCountNotification object:nil];
    
    //添加WebSocket监视
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSocketDidReceivePushMessage:) name:MLNetworkingManagerDidReceivePushMessageNotification object:nil];

    [self copyDefaultStoreIfNecessary];
    [MagicalRecord setupCoreDataStackWithStoreNamed:kLaixinStoreName];
    
    // Override point for customization after application launch.
    return YES;
}

///bak of the database
- (void) copyDefaultStoreIfNecessary;
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:kLaixinStoreName];
    
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:[storeURL path]])
    {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[kLaixinStoreName stringByDeletingPathExtension] ofType:[kLaixinStoreName pathExtension]];
        
		if (defaultStorePath)
        {
            NSError *error;
			BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                NSLog(@"Failed to install default recipe store");
            }
		}
	}
    
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
      [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
