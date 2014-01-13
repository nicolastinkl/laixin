//
//  XCJAppDelegate.m
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJAppDelegate.h"
#import "CRGradientNavigationBar.h"
#import "XCAlbumAdditions.h"
#import "SinaWeibo.h"
#import "XCJLoginViewController.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "CoreData+MagicalRecord.h"
#import "LXChatDBStoreManager.h"
#import "UIAlertViewAddition.h"
#import "XCJLoginNaviController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "blocktypedef.h"
#import "XCAlbumDefines.h"
#import "Conversation.h"
#import "FCReplyMessage.h"
#import "LXUser.h"
#import <Foundation/Foundation.h>
#import "FCBeAddFriend.h"
#import "XCJGroupPost_list.h"
#import "FCBeInviteGroup.h"
#import "FCHomeGroupMsg.h"
#import "ConverReply.h"
#import "CoreData+MagicalRecord.h"
#import "FCContactsPhone.h"

static NSString * const kLaixinStoreName = @"Laixins.sqlite";

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]
@interface XCJAppDelegate()

@end

@implementation XCJAppDelegate
@synthesize sinaweiboMain;
@synthesize mainNavigateController;
@synthesize launchingWithAps;

#pragma mark ChatListNeedUpdateToalUnreadCountNotification

- (void)updateMessageTabBarItemBadge
{
    //更新其未读消息总数
//    NSUInteger totalCount = [[[ChatList shareInstance] valueForKeyPath:@"array.@sum.unreadCount"] integerValue];
    if ([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]) {
        
        __block int brage = 0;
        NSArray * array = [Conversation MR_findAll];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation * con = obj;
            brage += [con.badgeNumber integerValue];
        }];
        if (brage > 0) {
            [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",brage]];
            [UIApplication sharedApplication].applicationIconBadgeNumber = brage;
        }else{
            [self.tabBarController.tabBar.items[2] setBadgeValue:nil];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
}

/**
 *  收到消息处理 全局请求
 *
 *  @param notification  noti
 */
- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    /*
     “push”:true，//推送标记，客户端用来识别推送信息和一般应答
     “type”:“add_friend”
     “data”:{
        “user”:
        {“uid”:,
     */
    NSDictionary * MsgContent = notification.userInfo;
    NSInteger innum = [DataHelper getIntegerValue:MsgContent[@"push"] defaultValue:0];
    if (innum == 1) {
        NSString *eventType = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        if ([eventType isEqualToString:@"event"]) {
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dictEvent = dicResult[@"event"];
            
            NSString *requestKey =  [tools getStringValue:dictEvent[@"type"] defaultValue:nil];
            
            if ([requestKey isEqualToString:@"add_friend"]) {
                NSString  * uid = [tools getStringValue:dictEvent[@"uid"] defaultValue:nil];
                NSString  * eid = [tools getStringValue:dictEvent[@"eid"] defaultValue:nil];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                    FCUserDescription * newFcObj = response;
                    // Build the predicate to find the person sought
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID = %@", uid];
                    FCBeAddFriend *conversation = [FCBeAddFriend MR_findFirstWithPredicate:predicate inContext:localContext];
                    if(conversation == nil)
                    {
                        conversation =  [FCBeAddFriend MR_createInContext:localContext];
                    }
                    conversation.facebookID = uid;
                    conversation.beAddFriendShips = newFcObj;
                    conversation.addTime = [NSDate date];
                    conversation.hasAdd = @NO;
                    conversation.eid = eid;
                    [localContext MR_saveToPersistentStoreAndWait];
                    [self.tabBarController.tabBar.items[1] setBadgeValue:@""];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"add_friend_Notify" object:nil];
                } withuid:uid];
                
            }else if ([requestKey isEqualToString:@"group_invite"])
            { /*	"gid":49,
               "create_time":1389322217,
               "type":"group_invite",
               "eid":41,
               "fromuid":4    */
                NSString * gid = [tools getStringValue:dictEvent[@"gid"] defaultValue:nil];
                NSString * eid = [tools getStringValue:dictEvent[@"eid"] defaultValue:nil];
                NSString * fromuid = [tools getStringValue:dictEvent[@"fromuid"] defaultValue:nil];
                
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                    FCUserDescription *newFcObj = response;
                    
                    NSDictionary * paramess = @{@"gid":@[gid]};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                        NSDictionary * groupsss = responseObjects[@"result"];
                        NSArray * groupsDicts =  groupsss[@"groups"];
                        [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                            // Build the predicate to find the person sought
                            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID = %@", gid];
                            FCBeInviteGroup *conversation = [FCBeInviteGroup MR_findFirstWithPredicate:predicate inContext:localContext];
                            if(conversation == nil)
                            {
                                conversation =  [FCBeInviteGroup MR_createInContext:localContext];
                            }
                            conversation.groupID = gid;
                            conversation.eid = eid;
                            conversation.groupName = list.group_name;
                            conversation.groupJson = [obj JSONString];
                            conversation.fcBeinviteGroupShips = newFcObj;
                            conversation.beaddTime = [NSDate date];
                            [localContext MR_saveToPersistentStoreAndWait];
                            [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"group_invite_Notify" object:nil];
#pragma mark // 处理加入请求
                            {
                                NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"gid = %@", gid];
                                FCHomeGroupMsg *msg = [FCHomeGroupMsg MR_findFirstWithPredicate:predicatess inContext:localContext];
                                if(msg == nil)
                                {
                                    // 处理加入请求
                                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.join" parameters:@{@"gid":gid} success:^(MLRequest *request, id responseObject) {
                                        if(responseObject){
                                            // Build the predicate to find the person sought
                                            
                                        }
                                    } failure:^(MLRequest *request, NSError *error) {
                                        
                                    }];
                                    msg = [FCHomeGroupMsg MR_createInContext:localContext];
                                }
                                msg.gid = list.gid;
                                msg.gCreatorUid = list.creator;
                                msg.gName = list.group_name;
                                msg.gBoard = list.group_board;
                                msg.gDate = [NSDate dateWithTimeIntervalSinceNow:list.time];
                                msg.gbadgeNumber = @1;
                                msg.gType = [NSString stringWithFormat:@"%d",list.type];
                                [localContext MR_saveToPersistentStoreAndWait];
                            }
                            
                            
                            
                        }];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                } withuid:fromuid];
            }
        }else if ([eventType isEqualToString:@"newlike"])
        {
            //被喜欢的照片
            NSDictionary * dicResult = MsgContent[@"data"];
            NSDictionary  * likeDict = dicResult[@"like"];
            /*"postid":83,
             "uid":4,
             "time":1389426716*/
            
            NSString * postid = [DataHelper getStringValue:likeDict[@"postid"] defaultValue:@""];
            NSString * uid = [DataHelper getStringValue:likeDict[@"uid"] defaultValue:@""];
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSTimeInterval receiveTime = [DataHelper getDoubleValue:likeDict[@"time"] defaultValue:0];
             NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
            ConverReply * ConverRe = [ConverReply MR_findFirstWithPredicate:predicatess];
            if (ConverRe == nil) {
                ConverRe = [ConverReply MR_createInContext:localContext];
            }
            FCReplyMessage * message = [FCReplyMessage MR_createInContext:localContext];
            message.typeReply = @"newlike";
            message.uid = uid;
            message.postid = postid;
            message.time = @(receiveTime);
            
            [ConverRe addFcreplymesgshipsObject: message];
            ConverRe.uid = uid;
            ConverRe.postid = postid;
            ConverRe.content = @"新赞";
            ConverRe.time = @(receiveTime);
            int unreadNumber  = [ConverRe.badgeNumber intValue];
            unreadNumber ++;
            ConverRe.badgeNumber = @(unreadNumber);
            [localContext MR_saveToPersistentStoreAndWait];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
        }else if ([eventType isEqualToString:@"newreply"])
        {
            //被评论的帖子
            NSDictionary * dicResult = MsgContent[@"data"];
            NSDictionary  *replyDict = dicResult[@"reply"];
            /*"content":"刚好合适",
             "postid":83,
             "replyid":38,
             "uid":4,
             "time":1389426744*/
            
            NSString * postid = [DataHelper getStringValue:replyDict[@"postid"] defaultValue:@""];
            NSString * replyid = [DataHelper getStringValue:replyDict[@"replyid"] defaultValue:@""];
            NSString * content = [DataHelper getStringValue:replyDict[@"content"] defaultValue:@""];
            NSString * uid = [DataHelper getStringValue:replyDict[@"uid"] defaultValue:@""];
            NSTimeInterval receiveTime = [DataHelper getDoubleValue:replyDict[@"time"] defaultValue:0];
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
            ConverReply * ConverRe = [ConverReply MR_findFirstWithPredicate:predicatess];
            if (ConverRe == nil) {
                ConverRe = [ConverReply MR_createInContext:localContext];
            }
            FCReplyMessage * message = [FCReplyMessage MR_createInContext:localContext];
            message.typeReply = @"newreply";
            message.uid = uid;
            message.postid = postid;
            message.replyid = replyid;
            message.content = content;
            message.time = @(receiveTime);
            
           [ConverRe addFcreplymesgshipsObject: message];
            ConverRe.uid = uid;
            ConverRe.postid = postid;
            ConverRe.content = @"新评论";
            ConverRe.time = @(receiveTime);
            int unreadNumber  = [ConverRe.badgeNumber intValue];
            unreadNumber ++;
            ConverRe.badgeNumber = @(unreadNumber);
            
            [localContext MR_saveToPersistentStoreAndWait];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
        }else if ([eventType isEqualToString:@"fromphonebook"])
        {
            NSDictionary * dicResult = MsgContent[@"data"];
            NSArray * array = dicResult[@"users"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser * lxuser = [[LXUser alloc] initWithDict:obj];
                NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"phoneNumber = %@",lxuser.phone];
                FCContactsPhone  * phoneObj = [FCContactsPhone MR_findFirstWithPredicate:preCMD];
                if (phoneObj) {
                    phoneObj.hasLaixin = @YES;
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:lxuser withCompletion:^(id reponse, NSError *error) {
                        phoneObj.phoneFCuserDesships = reponse;
                        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                    }];                    
                }
            }];
        }
        
    }
//    [self updateMessageTabBarItemBadge];
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
    
    self.launchingWithAps=[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self initAllControlos];
    
    //注册推送通知
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeNewsstandContentAvailability)];
     
    [self copyDefaultStoreIfNecessary];
    [MagicalRecord setupCoreDataStackWithStoreNamed:kLaixinStoreName];
    
    /* receive websocket message*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketDidReceivePushMessage:)
                                                 name:MLNetworkingManagerDidReceivePushMessageNotification
                                               object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateMessageTabBarItemBadge)
//                                                 name:@"updateMessageTabBarItemBadge"
//                                               object:nil];

   

    [self updateMessageTabBarItemBadge];
    // Override point for customization after application launch.
    return YES;
}

- (void) initAllControlos
{
    if (!self.tabBarController) {
        self.tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
    }
//    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBackground"]];
    //     [self.tabBarController.tabBar.items[0] setBadgeValue:@"New"];
    
    UIImage * tabBG =  [UIImage imageNamed:@"tabBarBackground"];
//    tabBG =  [tabBG imageWithAlignmentRectInsets:UIEdgeInsetsMake(1,1,1,1)];
    [self.tabBarController.tabBar setBackgroundImage:tabBG];
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[0];
        item.selectedImage = [UIImage imageNamed:@"tabBarRecentsIconSelected"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[1];
        item.selectedImage = [UIImage imageNamed:@"index_friends_hi"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[2];
        item.selectedImage = [UIImage imageNamed:@"index_msg"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[3];
        item.selectedImage = [UIImage imageNamed:@"tabBarContactsIconSelected"];
    }
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {    
    NSString* devtokenstring=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@" " withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //devtokenstring:  d8009e6c8e074d1bbcb592f321367feaef5674a82fc4cf3b78b066b7c8ad59bd
    NSLog(@"devtokenstring : %@",devtokenstring);
    if([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid].length > 1){
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //1 debug    ....   0 release
            NSDictionary * parames = @{@"device_token":devtokenstring,@"is_debug":@(NEED_OUTPUT_LOG)};
            [[MLNetworkingManager sharedManager] sendWithAction:@"ios.reg"  parameters:parames success:^(MLRequest *request, id responseObject) {
            } failure:^(MLRequest *request, NSError *error) {
            }];
        });
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    NSLog(@"error : %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
}

//接受到苹果推送的回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    /*{
     aps =     {
     alert = "you id code:38434";
     badge = 1;
     sound = default;
     };
     }*/
    NSLog(@"Receive Notify: %@", userInfo);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    //    NSLog(@"Receive Notify: %@", userInfo);
    //NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    //如果当前程序状态是激活的。
    
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        SystemSoundID id = 1007; //声音
        AudioServicesPlaySystemSound(id);
        //下面是发送一个本地消息，暂时不知道是为何
        UILocalNotification* _localNotification = [[UILocalNotification alloc] init];
        _localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        _localNotification.alertBody = [NSString stringWithFormat:@"%@",alert];
        _localNotification.alertAction = [NSString stringWithFormat:@"%@",alert];
        [[UIApplication sharedApplication] presentLocalNotificationNow:_localNotification];
        //显示这个推送消息
        [UIAlertView showAlertViewWithTitle:@"来信" message:[NSString stringWithFormat:@"%@",alert]];
    }
    
    // [BPush handleNotification:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
      [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
