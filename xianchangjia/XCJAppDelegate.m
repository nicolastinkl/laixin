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
#import "FCUserDescription.h"
#import "FCMessage.h" 
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "PayPellog.h"
//#import <Instabug/Instabug.h>

#import "BundleHelper.h"

#define audioLengthDefine 1050

static NSString * const kLaixinStoreName = @"Laixins";

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]
@interface XCJAppDelegate()<UITabBarControllerDelegate>

@end

@implementation XCJAppDelegate
@synthesize sinaweiboMain;
@synthesize mainNavigateController;
@synthesize launchingWithAps;

#pragma mark update umeng data
- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:kAppkeyForYoumeng reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}



- (void)onlineConfigCallBack:(NSNotification *)note {
    
    SLLog(@"online config has fininshed and note = %@", note.userInfo);
}

#pragma mark ChatListNeedUpdateToalUnreadCountNotification

- (void)updateMessageTabBarItemBadge
{
    //更新其未读消息总数
//    NSUInteger totalCount = [[[ChatList shareInstance] valueForKeyPath:@"array.@sum.unreadCount"] integerValue];
    if ([XCJAppDelegate hasLogin]) {
        
        __block int brage = 0;
        NSArray * array = [Conversation MR_findAll];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation * con = obj;
            brage += [con.badgeNumber integerValue];
        }];
        if (brage > 0) {
            [self.tabBarController.tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%d",brage]];
            [UIApplication sharedApplication].applicationIconBadgeNumber = brage;
        }else{
            [self.tabBarController.tabBar.items[0] setBadgeValue:nil];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        
        NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
        ConverReply * ConverRe = [ConverReply MR_findFirstWithPredicate:predicatess];
        if ([ConverRe.content isEqualToString:@"新朋友圈消息"]) {
            [self.tabBarController.tabBar.items[2] setBadgeValue:@"新"];
        }else{
            if ([[ConverRe badgeNumber] intValue] > 0) {
                 [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",[ConverRe.badgeNumber intValue]]];
            }
           
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
     “type”:“event”
     “data”:{
     “event”:
     {“type”:,
     add_friend  group_invite 
     
     “push”:true，//推送标记，客户端用来识别推送信息和一般应答
     “type”:“newlike” //newlike newreply newmsg newpost
     
     “data”:{ }
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
                    if (response) {
                        FCUserDescription * newFcObj = response;
                        // Build the predicate to find the person sought
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID == %@", uid];
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
                        [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"add_friend_Notify" object:nil];
                    }
                   
                } withuid:uid];
                
            }else if ([requestKey isEqualToString:@"group_invite"])
            { /*
               "gid":49,
               "create_time":1389322217,
               "type":"group_invite",
               "eid":41,
               "fromuid":4    */
                NSString * gid = [tools getStringValue:dictEvent[@"gid"] defaultValue:nil];
                NSString * eid = [tools getStringValue:dictEvent[@"eid"] defaultValue:nil];
                NSString * fromuid = [tools getStringValue:dictEvent[@"fromuid"] defaultValue:nil];
                
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                    if (response) {
                        FCUserDescription *newFcObj = response;
                        [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
                        NSDictionary * paramess = @{@"gid":@[gid]};
                        [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                            NSDictionary * groupsss = responseObjects[@"result"];
                            NSArray * groupsDicts =  groupsss[@"groups"];
                            [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                                // Build the predicate to find the person sought
                                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID == %@", gid];
                                FCBeInviteGroup *conversation = [FCBeInviteGroup MR_findFirstWithPredicate:predicate inContext:localContext];
                                if(conversation == nil)
                                {
                                    conversation =  [FCBeInviteGroup MR_createInContext:localContext];
                                }
                                conversation.groupID = gid;
                                conversation.eid = eid;
                                conversation.groupName = list.group_name;
                                conversation.groupJson = [obj JSONString];
                                conversation.hasAdd = @NO;
                                conversation.fcBeinviteGroupShips = newFcObj;
                                conversation.beaddTime = [NSDate date];
                                [localContext MR_saveToPersistentStoreAndWait];
                                
                                // Build the predicate to find the person sought
                                // target to chat view
                                NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid]];
                                Conversation * array =  [Conversation MR_findFirstWithPredicate:pre];
                                if (!array) {
                                    [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_message_GroupBeinvite];
                                    [USER_DEFAULT synchronize];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"group_invite_Notify" object:nil];
                                    // create new
                                    /* Conversation * conversation =  [Conversation MR_createInContext:localContext];
                                     conversation.lastMessage = list.group_board;
                                     conversation.lastMessageDate = [NSDate date];
                                     conversation.messageType = @(XCMessageActivity_UserGroupMessage);
                                     conversation.messageStutes = @(messageStutes_incoming);
                                     conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,@"0"];
                                     conversation.facebookName = list.group_name;
                                     conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid];
                                     conversation.badgeNumber = @1;
                                     [localContext MR_saveOnlySelfAndWait];
                                     SystemSoundID id = 1007; //声音
                                     AudioServicesPlaySystemSound(id);
                                     // 处理加入请求
                                     [self joingroup:list.gid]; // ok  join
                                     */
                                }else{
                                    //更新群信息
                                    if (![array.facebookName isEqualToString:list.group_name]) {
                                        array.facebookName = list.group_name;
                                        array.lastMessageDate = [NSDate date];
                                        [localContext MR_saveOnlySelfAndWait];
                                    }
                                }
                                
                                /*if (list.type == 1) {
                                 //首页群组
                                 [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
                                 }else if (list.type == 2) {
                                 //聊天群组
                                 
                                 NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid]];
                                 Conversation * conversation  = [Conversation MR_findFirstWithPredicate:pre];
                                 if (conversation == nil) {
                                 // create new
                                 conversation =  [Conversation MR_createInContext:localContext];
                                 conversation.lastMessage = @"你被邀请加入群聊";
                                 conversation.lastMessageDate = [NSDate date];
                                 conversation.messageType = @(XCMessageActivity_UserGroupMessage);
                                 conversation.messageStutes = @(messageStutes_incoming);
                                 conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,@"0"];
                                 conversation.facebookName = list.group_name;
                                 conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
                                 conversation.badgeNumber = @0;
                                 [localContext MR_saveOnlySelfAndWait];
                                 }
                                 }
                                 #pragma mark                处理加入请求
                                 {
                                 NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"gid == %@", gid];
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
                                 }*/
                            }];
                        } failure:^(MLRequest *request, NSError *error) {
                        }];
                    }
                   
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
            
            [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",unreadNumber]];
            
            
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
            
            int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
            if (localreplyid < [replyid intValue]) {
                [USER_DEFAULT setInteger:[replyid intValue] forKey:KeyChain_Laixin_Max_ReplyID];
                [USER_DEFAULT synchronize];
            }
            
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
            
            [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",unreadNumber]];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
            
            
        }else if ([eventType isEqualToString:@"fromphonebook"])
        {
            NSDictionary * dicResult = MsgContent[@"data"];
            NSArray * array = dicResult[@"users"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser * lxuser = [[LXUser alloc] initWithDict:obj];
                NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"phoneNumber == %@",lxuser.phone];
                FCContactsPhone  * phoneObj = [FCContactsPhone MR_findFirstWithPredicate:preCMD];
                if (phoneObj) {
                    phoneObj.hasLaixin = @YES;
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:lxuser withCompletion:^(id reponse, NSError *error) {
                        phoneObj.phoneFCuserDesships = reponse;
                        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                    }];                    
                }
            }];
        }else if ([eventType isEqualToString:@"newmsg"])
        {
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"message"];
            
            // update lastmessage id index
            NSInteger indexMsgID = [DataHelper getIntegerValue:dicMessage[@"msgid"] defaultValue:0];
            
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            {
//                FCMessage  find this infomation
                NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
                FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
                if (message) {
                    return; // change by tinkl   ....MARK:  has this record
                }
            }
            
            NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
            
            //out view
            NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
            NSString * typeMessage = [tools getStringValue:dicMessage[@"type"] defaultValue:@""];
            // Build the predicate to find the person sought
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
            Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
            if(conversation == nil)
            {
                conversation =  [Conversation MR_createInContext:localContext];
            }
            
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            if ([content isNilOrEmpty]) {
                content = @"";
            }
            msg.text = content;
            NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            msg.sentDate = date;
            // message did come, this will be on left
            msg.messageStatus = @(YES);
            msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
            if ([typeMessage isEqualToString:@"txt"]) {
                if ([content containString:@"sticker_"]) {
                    msg.messageType = @(messageType_emj);
                    conversation.lastMessage = @"[表情]";
                }else{
                    msg.messageType = @(messageType_text);
                    conversation.lastMessage = content;
                }
            }else if ([typeMessage isEqualToString:@"emj"]) {
                if ([content containString:@"sticker_"]) {
                    msg.messageType = @(messageType_emj);
                    conversation.lastMessage = @"[表情]";
                }else{
                    msg.messageType = @(messageType_text);
                    conversation.lastMessage = content;
                }
            }else if ([typeMessage isEqualToString:@"pic"]) {
                //image
                msg.messageType = @(messageType_image);
                conversation.lastMessage = @"[图片]";
                msg.imageUrl = imageurl;
            }else if ([typeMessage isEqualToString:@"vic"]) {
                //audio
                NSString * audiourl = [tools getStringValue:dicMessage[@"voice"] defaultValue:@""];
                conversation.lastMessage = @"[语音]";
                msg.audioUrl = audiourl;
                msg.messageType = @(messageType_audio);
                int length  = [dicMessage[@"length"] intValue];
                msg.audioLength = @(length/audioLengthDefine);
            }else if ([typeMessage isEqualToString:@"map"]) {
                conversation.lastMessage = @"[位置信息]";
                msg.imageUrl = imageurl;
                msg.messageType = @(messageType_map);
            }else if ([typeMessage isEqualToString:@"video"]) {
                conversation.lastMessage = @"[视频]";
                msg.videoUrl = imageurl;
                msg.messageType = @(messageType_video);
            }

            
            conversation.lastMessageDate = date;
            conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
            conversation.messageStutes = @(messageStutes_incoming);
            conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
            conversation.facebookName = @"";
            conversation.facebookId = facebookID;
            // increase badge number.
            int badgeNumber = [conversation.badgeNumber intValue];
            badgeNumber ++;
            conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
            
            [conversation addMessagesObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];// MR_saveOnlySelfAndWait];
            
            SystemSoundID id = 1007; //声音
            AudioServicesPlaySystemSound(id);
            
            // update tabbar item  badge
            [self updateMessageTabBarItemBadge];
            
        }else if([eventType isEqualToString:@"newpost"]){
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"post"];
            NSString * gid = [tools getStringValue:dicMessage[@"gid"] defaultValue:@""];
            NSString * uid = [tools getStringValue:dicMessage[@"uid"] defaultValue:@""];
            NSString * facebookID = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
            if([uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
            {
                return;
            }
            NSString * content = dicMessage[@"content"];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
            
            // Build the predicate to find the person sought
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
            Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
            if(conversation == nil)
            {
                //查看我是否有加入此圈子
//                return;
//                conversation =  [Conversation MR_createInContext:localContext];
                
            }else {
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                    if (response) {
                        FCUserDescription * localdespObject = response;
                        if (imageurl.length > 5)
                        {
                            conversation.lastMessage = [NSString stringWithFormat:@"%@:[图片]",localdespObject.nick];
                        }else
                        {
                            conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
                        }
                        
                        conversation.lastMessageDate = date;
                        conversation.messageStutes = @(messageStutes_incoming);
                        // increase badge number.
                        int badgeNumber = [conversation.badgeNumber intValue];
                        badgeNumber ++;
                        conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                        
                        [localContext MR_saveToPersistentStoreAndWait];
                        
                        SystemSoundID id = 1007; //声音
                        AudioServicesPlaySystemSound(id);
                    }
                    
                    
                } withuid:uid];
            }
            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:dicMessage];
            int oldpostid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_FriendGroup_messageID];
            if (oldpostid <= 0 || oldpostid != [post.postid intValue]) {
                [USER_DEFAULT setInteger:[post.postid intValue] forKey:KeyChain_Laixin_Max_FriendGroup_messageID];
                [USER_DEFAULT synchronize];
                
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
                ConverReply * ConverRe = [ConverReply MR_findFirstWithPredicate:predicatess];
                if (ConverRe == nil) {
                    ConverRe = [ConverReply MR_createInContext:localContext];
                }
                ConverRe.uid = post.uid;
                ConverRe.postid = post.postid;
                ConverRe.content = @"新朋友圈消息";
                ConverRe.time = @(post.time);
                
                [localContext MR_saveToPersistentStoreAndWait];
                //提示有新朋友圈消息
                if ([ConverRe.badgeNumber intValue]<=0) {
                    [self.tabBarController.tabBar.items[2] setBadgeValue:@"新"];
                }else{
                    [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",[ConverRe.badgeNumber intValue]]];
                }
                
            }

          
            
            //然后更新朋友圈最新发图
            
#pragma mark 这里是群组聊天室 代码
            
//            NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[NSString stringWithFormat:@"UID_%@", gid]];  //or postid
//            FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
//            if (message) {
//                return; // change by tinkl   ....MARK:  has this record
//            }
            
            //获取群组消息类型 然后做相关写入操作
            /*NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"gid == %@ ",gid];
            FCHomeGroupMsg * groupMessage = [FCHomeGroupMsg MR_findFirstWithPredicate:parCMDss];
            if ([groupMessage.gType isEqualToString: @"1"]) {
                 //
//                [self updateMessageTabBarItemBadge];
                int badge =  [groupMessage.gbadgeNumber intValue];
                badge += 1;
                groupMessage.gbadgeNumber = @(badge);
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                
            }else if ([groupMessage.gType isEqualToString:@"2"]) {
                //out view
                NSString * content = dicMessage[@"content"];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                
                // Build the predicate to find the person sought
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
                Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
                if(conversation == nil)
                {
                    conversation =  [Conversation MR_createInContext:localContext];
                }
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                msg.sentDate = date;
                if (imageurl.length > 5)
                {
                    msg.messageType = @(messageType_image);
                    conversation.lastMessage = @"[图片]";
                }
                else
                {
                    msg.messageType = @(messageType_text);
                    conversation.lastMessage = content;
                }
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                msg.messageId = [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                    FCUserDescription * localdespObject = response;
                    conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
                } withuid:uid];
                conversation.lastMessageDate = date;
                conversation.messageStutes = @(messageStutes_incoming);
                // increase badge number.
                int badgeNumber = [conversation.badgeNumber intValue];
                badgeNumber ++;
                conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                
                [conversation addMessagesObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
                
                SystemSoundID id = 1007; //声音
                AudioServicesPlaySystemSound(id);
            }
            
        }*/
        }else if([eventType isEqualToString:@"paylog"])
        {
            /**
             *  新的支付信息
             */
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * logMessage = dicResult[@"log"];
            if (logMessage) {
                PayPellog * paylog = [PayPellog turnObject:logMessage];
                if (paylog) {
                    // notify: new pay info
                    NSString * title;
                    NSString * description;
                    if([[NSString stringWithFormat:@"%d",paylog.uid] isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
                    {
                        title= @"新订单信息";
                        description = @"我的订单";
                    }
                    else
                    {
                        title = @"新订单提到我是联系人";
                        description =@"我是联系人的订单";
                    }
                    
                    NSString *stringss;
                    if (paylog.amount >= 100) {
                        stringss =  [NSString stringWithFormat:@"￥%d.00",paylog.amount/100];
                    }else{
                        if (paylog.amount >=10) {
                            stringss =  [NSString stringWithFormat:@"￥0.%d",paylog.amount];
                        }else{
                            stringss =  [NSString stringWithFormat:@"￥0.0%d",paylog.amount];
                        }
                    }
                    
                    SystemSoundID id = 1007; //声音
                    AudioServicesPlaySystemSound(id);
                    NSString * messagessLog =[NSString stringWithFormat:@"商品名称:%@\n K歌指导员%d位,\n支付价格:%@ \n \n更多详情请进入\n'%@'中查看",paylog.productname,paylog.ex_people,stringss,description];
                    [UIAlertView showAlertViewWithTitle:title message:messagessLog];
                    
                    
                }
            }

            
        }
    }
}


-(void) joingroup:(NSString * ) gid
{
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.join" parameters:@{@"gid":gid} success:^(MLRequest *requestsd, id responseObjectsd) {
        
    } failure:^(MLRequest *requestsd, NSError *errorsd) {
        
    }];
}
-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xf16149).CGColor, (id)UIColorFromRGB(0xf14959).CGColor, nil];
    ///setup 4:
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
}

/**
 *  分享链接给好友
 *
 *  @param url <#url description#>
 */
- (void) sendImageContentURLData:(NSString * ) url
{
    _scene = WXSceneSession;
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [NSString stringWithFormat:@"%@邀请您支付",[USER_DEFAULT  stringForKey:KeyChain_Laixin_account_user_nick]];
    message.description = @"来信易宝支付,100%放心";
    [message setThumbImage:[UIImage imageNamed:@"易宝支付Logo.jpg"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    
    [WXApi sendReq:req];
    
}

- (void) sendImageContent:(int ) type withImageData:(NSData * ) imagedata
{
    if (type == 0) {
         _scene = WXSceneSession;
    }else if(type == 1){
        _scene = WXSceneTimeline;
    }else{
        _scene = WXSceneFavorite;
    }
    WXMediaMessage *message = [WXMediaMessage message];
//    [message setThumbImage:[UIImage imageNamed:@"res5thumb.png"]];
    WXImageObject *ext = [WXImageObject object];
    ext.imageData =imagedata;
    
    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    UIImage* image = [UIImage imageWithData:ext.imageData];
    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];
    [MobClick checkUpdate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.launchingWithAps=[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self initAllControlos];
    
//    [Instabug KickOffWithToken:@"6fd7d2d10a87f33de702536bcd70470c" CaptureSource:InstabugCaptureSourceUIKit FeedbackEvent:InstabugFeedbackEventShake IsTrackingLocation:YES];
//    [Instabug setColorTheme:InstabugColorThemeFlatWhite];
//    
//    [Instabug setCommentInvalidText:@"请输入至少一个字"];
//    [Instabug setCommentPlaceholder:@"请输入您使用来信不爽的地方"];
//    [Instabug setAlertsTitle:@"提示"];
//    [Instabug setEmailInvalidText:@"请输入您的电子邮件 方面来信团队回复您的反馈"];
//    [Instabug setUserDataString:@"您可以在屏幕上绘画或者添加文本"];
//    [Instabug setEmailPlaceholder:@"您的电子邮件"];
//    [Instabug setButtonsColor:ios7BlueColor];
//    [Instabug setButtonsFontColor:[UIColor whiteColor]];
//    [Instabug setShowThankYouAlert:NO];
//    [Instabug setShowScreenshot:NO];
//    [Instabug setStartAlertText:@"在来信使用过程中,您只要有使用不爽的地方都可以摇一摇截图发给来信团队.我们将非常感谢您的反馈"];
    //向微信注册
    [WXApi registerApp:kAppkeyForWeChat withDescription:[NSString stringWithFormat:@"%@ %@", [BundleHelper bundleDisplayNameString], [BundleHelper bundleShortVersionString]]];
    
    
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
     [reach startNotifier];
    
    //注册推送通知
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeNewsstandContentAvailability)];
    
    
    [self copyDefaultStoreIfNecessary:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
    
    if ([XCJAppDelegate hasLogin]) {
//        [self laixinStepupDB];
        [self updateMessageTabBarItemBadge];
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    //第一次调用这个方法的时候，系统会提示用户让他同意你的app获取麦克风的数据
    // 其他时候调用方法的时候，则不会提醒用户
    // 而会传递之前的值来要求用户同意
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            // 用户同意获取数据
        } else {
            // 可以显示一个提示框告诉用户这个app没有得到允许？
        } 
    }];
    
    /* receive websocket message*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketDidReceivePushMessage:)
                                                 name:MLNetworkingManagerDidReceivePushMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(laixinCloseNotification:)
                                                 name:LaixinCloseDBMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(laixinStepupNotification:)
                                                 name:LaixinSetupDBMessageNotification
                                               object:nil];
    
    
    
  
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ReceiveAllMessage)
                                                 name:@"LoginInReceivingAllMessage"
                                               object:nil];

   
    // Override point for customization after application launch.
    return YES;
}

-(void) reachabilityChanged: (NSNotification*)note {
    Reachability * reach = [note object];
     if(![reach isReachable])
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
         // notify websocket close
         [UIAlertView showAlertViewWithMessage:@"网络不可用,请检查您的网络设置"];
         
     }else{
         // notify websocket reConntect
         [self LoginInReceivingAllMessage];
         
     }
    
}

-(void) changeScene:(NSInteger)scene
{
    _scene = scene;
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger index =  tabBarController.selectedIndex;
//    if (index == 2) {
//        [tabBarController.tabBar.items[2] setBadgeValue:nil];
//    }
//    
    if (index == 1) {
        //[tabBarController.tabBar.items[1] setBadgeValue:nil];
    }
}

- (void)laixinCloseNotification:(NSNotification *)notification
{
    if (notification.object) {
        NSString * userID = [DataHelper getStringValue:notification.object defaultValue:@""];
        if (userID.length > 0) {
            NSString * strDBName = [NSString stringWithFormat:@"%@_%@.sqlite",kLaixinStoreName,userID];
            [self copyDefaultStoreIfNecessary:strDBName];
            [MagicalRecord cleanUp];
        }
    }else{
         [MagicalRecord cleanUp];
    }
}
-(void) laixinStepupDB
{
    NSString * userID = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
    if (userID.length > 0) {
        NSString * strDBName = [NSString stringWithFormat:@"%@_%@.sqlite",kLaixinStoreName,userID];
        [self copyDefaultStoreIfNecessary:strDBName];
        [MagicalRecord setupCoreDataStackWithStoreNamed:strDBName];
    }
}

- (void)laixinStepupNotification:(NSNotification *)notification
{
    if (notification.object) {
        NSString * userID = [DataHelper getStringValue:notification.object defaultValue:@""];
        if (userID.length > 0) {
            NSString * strDBName = [NSString stringWithFormat:@"%@_%@.sqlite",kLaixinStoreName,userID];
            [self copyDefaultStoreIfNecessary:strDBName];
            [MagicalRecord setupCoreDataStackWithStoreNamed:strDBName];
        }
    }else{
        [self copyDefaultStoreIfNecessary:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
        [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
    }
}


- (void) initAllControlos
{
    if (!self.tabBarController) {
        self.tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
        self.tabBarController.delegate = self;
    }
//    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBackground"]];
    //     [self.tabBarController.tabBar.items[0] setBadgeValue:@"New"];
    
//    UIImage * tabBG =  [UIImage imageNamed:@"tabBarBackground"];
//    tabBG =  [tabBG imageWithAlignmentRectInsets:UIEdgeInsetsMake(1,1,1,1)];
//    [self.tabBarController.tabBar setBackgroundImage:tabBG];
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[2];
        item.selectedImage = [UIImage imageNamed:@"tabBarRecentsIconSelected"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[1];
        item.selectedImage = [UIImage imageNamed:@"index_friends_hi"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[0];
        item.selectedImage = [UIImage imageNamed:@"index_msg"];
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[3];
        item.selectedImage = [UIImage imageNamed:@"tabBarContactsIconSelected"];
    }
}

///bak of the database
- (void) copyDefaultStoreIfNecessary:(NSString * ) laixinDBname;
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:laixinDBname];
    
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:[storeURL path]])
    {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[laixinDBname stringByDeletingPathExtension] ofType:[laixinDBname pathExtension]];
        
		if (defaultStorePath)
        {
            NSError *error;
			BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                SLLog(@"Failed to install default recipe store");
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
    // tell websocket disconnect
    if([XCJAppDelegate hasLogin])
    {
        
        SLLog(@"applicationDidEnterBackground webSocket close");
        [[[MLNetworkingManager sharedManager] webSocket] close];
    }
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(void) ReceiveAllMessage
{
    
    if(![XCJAppDelegate hasLogin])
         return;
    {
        { //我的好友
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"hasAdd == %@",@NO];
            NSUInteger cont = [FCBeAddFriend MR_countOfEntitiesWithPredicate:pre];
            if (cont > 0 || [USER_DEFAULT boolForKey:KeyChain_Laixin_message_GroupBeinvite]) {
                [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
            }else{
                [self.tabBarController.tabBar.items[1] setBadgeValue:nil];
            }
        }
        // 读取事件
        // get  event.read(pos=0)
        NSInteger MaxEid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_Event_messageID];
        [[MLNetworkingManager sharedManager] sendWithAction:@"event.read"  parameters:@{@"pos":@(MaxEid)} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * dict = responseObject[@"result"];
                NSArray * array = dict[@"events"];
                __block NSInteger manEIDTwo = 0;
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * typeStr =  [DataHelper getStringValue:obj[@"type"] defaultValue:@""];
                    NSInteger curretnEid =[DataHelper getIntegerValue:obj[@"eid"] defaultValue:0];
                    if (manEIDTwo < curretnEid) {
                        manEIDTwo = curretnEid;
                        [USER_DEFAULT setInteger:manEIDTwo forKey:KeyChain_Laixin_Max_Event_messageID];
                        [USER_DEFAULT synchronize];
                    }
                    [self initEventData:typeStr Data:obj];
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
    
    //读取未读私信
    //message.read(afterid=0) 读私信
    __block NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
    //        [FCMessage MR_findFirstOrderedByAttribute:@"messageId" ascending:YES];
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.read" parameters:@{@"afterid":@(messageIndex)} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketDidOpen" object:nil];
            
            NSDictionary * resultDict = responseObject[@"result"];
            NSArray * array = resultDict[@"message"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                /*
                 “msgid”:
                 “uid”:
                 “content”:
                 “time”: */
                NSInteger curretnEid =[DataHelper getIntegerValue:obj[@"msgid"] defaultValue:0];
                if (messageIndex < curretnEid) {
                    messageIndex = curretnEid;
                    [USER_DEFAULT setInteger:messageIndex forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    [USER_DEFAULT synchronize];
                }
                
                {
                    //MARK THIS
                    NSString *facebookID = [tools getStringValue:obj[@"fromid"] defaultValue:@""];
                    
                    //out view
                    NSString * content = [tools getStringValue:obj[@"content"] defaultValue:@""];
                    NSString * imageurl = [tools getStringValue:obj[@"picture"] defaultValue:@""];
                    
                    NSString * typeMessage = [tools getStringValue:obj[@"type"] defaultValue:@""];
                    // Build the predicate to find the person sought
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
                    Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
                    if(conversation == nil)
                    {
                        conversation =  [Conversation MR_createInContext:localContext];
                    }
                    
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    if ([content isNilOrEmpty]) {
                        content = @"";
                    }
                    msg.text = content;
                    NSTimeInterval receiveTime  = [obj[@"time"] floatValue];
                    //fix local time from server time...
//                    receiveTime = receiveTime + 10;
                    
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
//                    SLog(@"receiveTime : %@",date);
                    msg.sentDate = date;
                    // message did come, this will be on left
                    msg.messageStatus = @(YES);
                    msg.messageId = [tools getStringValue:obj[@"msgid"] defaultValue:@"0"];
                    
                    if ([typeMessage isEqualToString:@"txt"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            //                                        conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            //                                        conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"emj"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            //                                        conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            //                                        conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"pic"]) {
                        //image
                        msg.messageType = @(messageType_image);
                        //                                    conversation.lastMessage = @"[图片]";
                        msg.imageUrl = imageurl;
                    }else if ([typeMessage isEqualToString:@"vic"]) {
                        //audio
                        NSString * audiourl = [tools getStringValue:obj[@"voice"] defaultValue:@""];
                        //                                    conversation.lastMessage = @"[语音]";
                        msg.audioUrl = audiourl;
                        msg.messageType = @(messageType_audio);
                        int length  = [obj[@"length"] intValue];
                        msg.audioLength = @(length/audioLengthDefine);
                    }else if ([typeMessage isEqualToString:@"map"]) {
                        //                                    conversation.lastMessage = @"[位置信息]";
                        msg.imageUrl = imageurl;
                        msg.messageType = @(messageType_map);
                    }else if ([typeMessage isEqualToString:@"video"]) {
                        //                                    conversation.lastMessage = @"[视频]";
                        msg.videoUrl = imageurl;
                        msg.messageType = @(messageType_video);
                    }
                    
                    conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
                    conversation.lastMessageDate = date;
                    conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,[tools getStringValue:obj[@"msgid"] defaultValue:@"0"]];
                    if ([typeMessage isEqualToString:@"txt"]) {
                        if ([content containString:@"sticker_"]) {
                            conversation.lastMessage = @"[表情]";
                        }else{
                            conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"emj"]) {
                        if ([content containString:@"sticker_"]) {
                            conversation.lastMessage = @"[表情]";
                        }else{
                            conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"pic"]) {
                        //image
                        conversation.lastMessage = @"[图片]";
                    }else if ([typeMessage isEqualToString:@"vic"]) {
                        conversation.lastMessage = @"[语音]";
                    }else if ([typeMessage isEqualToString:@"map"]) {
                        conversation.lastMessage = @"[位置信息]";
                    }else if ([typeMessage isEqualToString:@"video"]) {
                        conversation.lastMessage = @"[视频]";
                    }
                    
                    conversation.messageStutes = @(messageStutes_incoming);
                    conversation.facebookName = @"";
                    conversation.facebookId = facebookID;
                    // increase badge number.
                    int badgeNumber = [conversation.badgeNumber intValue];
                    badgeNumber ++;
                    conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                    [conversation addMessagesObject:msg];
                    [localContext MR_saveToPersistentStoreAndWait];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:MLNetworkingManagerDidReceiveForcegroundMessageNotification object:@{@"message":msg,@"fromid":facebookID}];
                }
                
                // update tabbar item  badge
                [self updateMessageTabBarItemBadge];
            }];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
        
    }];
    
    //读取最新评论信息
    
    {
        int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
        if (localreplyid > 0) {
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.get_new_reply" parameters:@{@"from_reply":@(localreplyid)} success:^(MLRequest *request, id responseObject) {
                if(responseObject)
                {
                    NSDictionary * dict = responseObject[@"result"];
                    NSArray *arrayReplys = dict[@"replys"];
                    [arrayReplys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if (obj) {
                            NSDictionary *replyDict = obj;
                            NSString * postid = [DataHelper getStringValue:replyDict[@"postid"] defaultValue:@""];
                            NSString * replyid = [DataHelper getStringValue:replyDict[@"replyid"] defaultValue:@""];
                            
                            int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
                            if (localreplyid < [replyid intValue]) {
                                [USER_DEFAULT setInteger:[replyid intValue] forKey:KeyChain_Laixin_Max_ReplyID];
                                [USER_DEFAULT synchronize];
                            }
                            
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
                            
                            [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",unreadNumber]];
                            
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
                        }
                    }];
                    
                    
                }
            } failure:^(MLRequest *request, NSError *error) {
                
            }];
        }
    }
    
    //读取朋友圈新事件
    {
        NSDictionary * parames = @{@"count":@"1"};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_timeline"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //    postid = 12;
            /*
             Result={
             “posts”:[*/
            if (responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"posts"];
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if(idx == 0)
                    {
                        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                        int oldpostid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_FriendGroup_messageID];
                        if (oldpostid <= 0 || oldpostid != [post.postid intValue]) {
                            [USER_DEFAULT setInteger:[post.postid intValue] forKey:KeyChain_Laixin_Max_FriendGroup_messageID];
                            [USER_DEFAULT synchronize];
                            
                            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                            NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
                            ConverReply * ConverRe = [ConverReply MR_findFirstWithPredicate:predicatess];
                            if (ConverRe == nil) {
                                ConverRe = [ConverReply MR_createInContext:localContext];
                            }
                            ConverRe.uid = post.uid;
                            ConverRe.postid = post.postid;
                            ConverRe.content = @"新朋友圈消息";
                            ConverRe.time = @(post.time);
                            
                            [localContext MR_saveToPersistentStoreAndWait];
                            //提示有新朋友圈消息
                            if ([ConverRe.badgeNumber intValue]<=0) {
                                [self.tabBarController.tabBar.items[2] setBadgeValue:@"新"];
                            }else{
                                [self.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",[ConverRe.badgeNumber intValue]]];
                            }
                            
                        }
                        
                    }
                    
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
}

-(void) LoginInReceivingAllMessage
{
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if([XCJAppDelegate hasLogin]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidreceingWithMsg" object:nil];
            
            NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
            NSDictionary * parames = @{@"sessionid":sessionid};
            [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObjectsss) {
               
                NSDictionary * userinfo = responseObjectsss[@"result"];
                LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
                if (currentUser) {
                    [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
                    [self ReceiveAllMessage];
                }else{
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
                }
            } failure:^(MLRequest *request, NSError *error) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
            }];
    }
    });
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    SLog(@"applicationWillEnterForeground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //查看 websocket是否有关闭
    
//    if ([[MLNetworkingManager sharedManager].webSocket readyState] >= SR_CLOSING) {
//       
//    }
     [self LoginInReceivingAllMessage];
}

-(void) initEventData:(NSString *) requestKey Data:(NSDictionary  *)dictEvent
{
    if ([requestKey isEqualToString:@"add_friend"]) {
        NSString  * uid = [tools getStringValue:dictEvent[@"uid"] defaultValue:nil];
        NSString  * eid = [tools getStringValue:dictEvent[@"eid"] defaultValue:nil];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            if (response) {
                FCUserDescription * newFcObj = response;
                // Build the predicate to find the person sought
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID == %@", uid];
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
                [self.tabBarController.tabBar.items[1] setBadgeValue:@"新"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"add_friend_Notify" object:nil];
            }
           
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
            if (response) {
                FCUserDescription *newFcObj = response;
                
                NSDictionary * paramess = @{@"gid":@[gid]};
                [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                    NSDictionary * groupsss = responseObjects[@"result"];
                    NSArray * groupsDicts =  groupsss[@"groups"];
                    [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                        // Build the predicate to find the person sought
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID == %@", gid];
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
                        
                        
                        {
                            
                            // Build the predicate to find the person sought
                            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                            // target to chat view
                            NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid]];
                            Conversation * array =  [Conversation MR_findFirstWithPredicate:pre];
                            if (!array) {
                                // create new
                                
                                
                                [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_message_GroupBeinvite];
                                [USER_DEFAULT synchronize];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"group_invite_Notify" object:nil];
                                
                                //                            Conversation * conversation =  [Conversation MR_createInContext:localContext];
                                //                            conversation.lastMessage = list.group_board;
                                //                            conversation.lastMessageDate = [NSDate date];
                                //                            conversation.messageType = @(XCMessageActivity_UserGroupMessage);
                                //                            conversation.messageStutes = @(messageStutes_incoming);
                                //                            conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,@"0"];
                                //                            conversation.facebookName = list.group_name;
                                //                            conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid];
                                //                            conversation.badgeNumber = @0;
                                //                            [localContext MR_saveOnlySelfAndWait];
                            }else{
                                //更新群信息
                                if (![array.facebookName isEqualToString:list.group_name]) {
                                    array.facebookName = list.group_name;
                                    array.lastMessageDate = [NSDate date];
                                    [localContext MR_saveOnlySelfAndWait];
                                }
                            }
                            
                            /*NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"gid == %@", gid];
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
                             */
                        }
                    }];
                } failure:^(MLRequest *request, NSError *error) {
                }];
            }
           
        } withuid:fromuid];
    }

}

+(BOOL) hasLogin
{
    if([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid].length > 1 && [USER_DEFAULT boolForKey:KeyChain_Laixin_account_HasLogin]){
        return YES;
    }
    return NO;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* devtokenstring=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@" " withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //devtokenstring:  d8009e6c8e074d1bbcb592f321367feaef5674a82fc4cf3b78b066b7c8ad59bd
    SLLog(@"devtokenstring : %@",devtokenstring);
    
    [USER_DEFAULT setValue:devtokenstring forKey:KeyChain_Laixin_account_devtokenstring];
    [USER_DEFAULT synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    SLLog(@"error : %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
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
   // NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    //    NSLog(@"Receive Notify: %@", userInfo);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    //如果当前程序状态是激活的。
    
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
//        SystemSoundID id = 1007; //声音
//        AudioServicesPlaySystemSound(id);
//        //下面是发送一个本地消息，暂时不知道是为何
//        UILocalNotification* _localNotification = [[UILocalNotification alloc] init];
//        _localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//        _localNotification.alertBody = [NSString stringWithFormat:@"%@",alert];
//        _localNotification.alertAction = [NSString stringWithFormat:@"%@",alert];
//        [[UIApplication sharedApplication] presentLocalNotificationNow:_localNotification];
//        //显示这个推送消息
//        [UIAlertView showAlertViewWithTitle:@"来信" message:[NSString stringWithFormat:@"%@",alert]];
        SLLog(@"push : %@",[NSString stringWithFormat:@"%@",alert]);
    }
    
    // [BPush handleNotification:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
      [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
