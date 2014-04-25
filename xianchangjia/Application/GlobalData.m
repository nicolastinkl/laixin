//
//  GlobalData.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "GlobalData.h"
#import "SINGLETONGCD.h"
#import "XCAlbumDefines.h"
#import "tools.h"
#import "XCDataDBFactory.h"
#import "DAHttpClient.h"

@implementation GlobalData

// delegate
NSString *const GlobalData_service_url=@"GlobalData_service_url";

//weibo sina
NSString * const GlobalData_sinaweibo_userID=@"GlobalData_sinaweibo_userID";
NSString * const GlobalData_sinaweibo_accesstoken=@"GlobalData_sinaweibo_accesstoken";
NSString * const GlobalData_sinaweibo_refresh_token=@"GlobalData_sinaweibo_refresh_token";
NSString * const GlobalData_sinaweibo_expirationDate=@"GlobalData_sinaweibo_expirationDate";

NSString * const GlobalData_user_encrypted=@"GlobalData_user_encrypted";
NSString * const GlobalData_user_id=@"gd_user_id";
NSString * const GlobalData_user_name=@"gd_user_name";
NSString * const GlobalData_user_nick=@"gd_user_nick";
NSString * const GlobalData_user_session=@"gd_user_session";
NSString * const GlobalData_user_pic=@"gd_user_pic";
NSString * const GlobalData_user_pic_small=@"gd_user_pic_small";
NSString * const GlobalData_user_password=@"gd_user_password";
NSString * const GlobalData_user_sex=@"GlobalData_user_sex";
NSString * const GlobalData_user_birthday=@"GlobalData_user_birthday";
NSString * const GlobalData_user_bgImage=@"GlobalData_user_bgImage";
NSString * const GlobalData_user_married=@"GlobalData_user_married";
NSString * const GlobalData_user_signature=@"GlobalData_user_signature";  //签名
NSString * const GlobalData_user_follow=@"GlobalData_user_follow";  //关注
NSString * const GlobalData_user_followed=@"GlobalData_user_followed";  //粉丝
NSString * const GlobalData_user_pic_external=@"GlobalData_user_pic_external";  //用户图片链接是否外链
NSString * const GlobalData_user_info_bg=@"GlobalData_user_info_bg"; //用户个人主页背景图片
NSString * const GlobalData_user_active=@"GlobalData_user_active";
NSString * const GlobalData_force_update=@"GlobalData_force_update";  //是否强制更新
NSString * const GlobalData_user_cerdit=@"GlobalData_user_cerdit";      //积分
NSString * const GlobalData_user_Integral=@"GlobalData_user_Integral";
NSString * const GlobalData_user_height=@"GlobalData_user_height";
NSString * const GlobalData_user_astro=@"GlobalData_user_astro";
NSString * const GlobalData_user_age=@"GlobalData_user_age";

NSString * const GlobalData_user_desInfo=@"GlobalData_user_desInfo";

NSString * const GlobalData_user_friends_num=@"GlobalData_user_friends_num";
NSString * const GlobalData_user_followers_num=@"GlobalData_user_followers_num";
NSString * const GlobalData_user_avatar_external=@"GlobalData_user_avatar_external"; //用户图片链接是否外链
NSString * const GlobalData_user_background_external=@"GlobalData_user_background_external"; //用户背景图片链接是否外链
NSString * const GlobalData_user_is_follower=@"GlobalData_user_is_follower"; //用户背景图片链接是否外链


NSString * const KEY_USERNAME_PASSWORD = @"com.company.app.usernamepassword";
NSString * const KEY_USERSESSION= @"com.company.app.usersession";
NSString * const KEY_PASSWORD = @"com.company.app.password";

NSString * const GlobalData_user_Mainview_guid=@"GlobalData_user_Mainview_guid";  //是否显示用户引导
NSString * const GlobalData_user_Loginview_guid=@"GlobalData_user_Loginview_guid";  //是否显示开机用户引导
NSString * const GlobalData_user_Mainview_guid_count=@"GlobalData_user_Mainview_guid_count";  //用户引导 计数
NSString * const GlobalData_OPENMUSICLOCATION=@"GlobalData_OPENMUSICLOCATION";  //是否开启声波定位
NSString * const GlobalData_new_mail_count=@"gd_new_mail_count";
NSString * const GlobalData_run_count=@"gd_run_count";
NSString * const GlobalData_phoneserver=@"gd_phoneserver";
NSString * const GlobalData_gobindphone=@"gd_gobindphone";
NSString * const GlobalData_lastcommentindex=@"gd_lastcommentindex";
NSString * const GlobalData_unreadcomment=@"gd_unreadcomment";
NSString * const GlobalData_autosynccontact=@"gd_autosynccontact";
NSString * const GlobalData_notifysound=@"gd_notifysound";
NSString * const GlobalData_mappagefirstuse=@"gd_mappagefirstuse";
NSString * const GlobalData_usecnmap=@"gd_usecnmap";
NSString * const GlobalData_lastmailindex=@"gd_lastmailindex";
NSString * const GlobalData_nowvision=@"gd_nowvision";
NSString * const GlobalData_nowvisiondownloadlink=@"gd_nowvisiondownloadlink";
NSString * const GlobalData_rejectvision=@"gd_rejectvision";
NSString * const GlobalData_createinvitefirstuse=@"gd_createinvitefirstuse";
NSString * const GlobalData_hasSuccessedLogin=@"gd_hasSuccessedLogin";
NSString * const GlobalData_lastCheckUrlTime=@"GlobalData_lastCheckUrlTime";
NSString * const GlobalData_main_url=@"GlobalData_main_url";
NSString * const GlobalData_safe_main_url=@"GlobalData_safe_main_url";
NSString * const GlobalData_main_server=@"GlobalData_main_server";
NSString * const GlobalData_upload_url=@"GlobalData_upload_url";
NSString * const GlobalData_upload_headurl=@"GlobalData_upload_headurl";
NSString * const GlobalData_stopsyncweibo=@"GlobalData_stopsyncweibo";
NSString * const GlobalData_safe_main_NewServer_URL=@"GlobalData_safe_main_NewServer_URL";
NSString * const GlobalData_recommend_scene=@"GlobalData_recommend_scene";
NSString * const GlobalData_recommend_user=@"GlobalData_recommend_user";
NSString * const GlobalData_lat=@"GlobalData_lat";
NSString * const GlobalData_lng=@"GlobalData_lng";


NSString * const GlobalData_HomeViewSips = @"HomeViewSips";
NSString * const GlobalData_HomeViewLocatoinSips=@"HomeViewLocatoinSips";

const int AppVision=1;

NSString * const MainCheckSite=1?@"http://xianchangjia.com/jumpcheck/urllist.txt":@"http://xianchangjia.com/jumpcheck/urllist_dbg.txt";

NSString * const Notify_UpdateUnreadMailCount=@"Notify_UpdateUnreadMailCount";
NSString * const Notify_UpdateUnreadCommentCount=@"Notify_UpdateUnreadCommentCount";

NSString * const GlobalData_apn_notification_name = @"APNJumpeName";
NSString * const GlobalData_apn_notification_name_faviorites = @"APNfaviorites";
NSString * const GlobalData_apn_notification_name_nowjoin_address=@"APNnowjoin";
NSString * const GlobalData_apn_notification_name_userfootdata = @"userfootdata";



/*user data cache*/
NSString * const GlobalData_CACHE_USER_INFO_SELF=@"GlobalData_CACHE_USER_INFO_SELF";
NSString * const GlobalData_CACHE_USER_INFO_OTHERS=@"GlobalData_CACHE_USER_INFO_OTHERS";  // <dic>
NSString * const GlobalData_CACHE_USER_INFO_BK=@"GlobalData_CACHE_USER_INFO_BK";  // User bk image
NSString * const GlobalData_CACHE_USER_INFO_ICON=@"GlobalData_CACHE_USER_INFO_ICON";  // user icon
/* Login user exit status */
NSString * const GlobalData_CACHE_USER_EXIT_STATUS=@"GlobalData_CACHE_USER_EXIT_STATUS";

NSString * const GlobalData_apn_notification_name_LocalNofityMessageCount_old = @"GlobalData_apn_notification_name_LocalNofityMessageCount_old";

/*change bg image*/
NSString * const GlobalData_apn_notification_name_changeBg=@"GlobalData_apn_notification_name_changeBg";


NSString * const GlobalData_user_ScenseIp=@"GlobalData_user_ScenseIp";
/*welcome view main and chat view*/
NSString * const GlobalData_mainview_welcome=@"GlobalData_mainview_welcome";
NSString * const GlobalData_chatview_welcome=@"GlobalData_chatview_welcome";


/*sina weibo and qq weibo   my self view*/
NSString * const GlobalData_weibo_sina_qq_self=@"GlobalData_weibo_sina_qq_self";

/*sina weibo and qq weibo*/
NSString * const GlobalData_weibo_sina_qq =@"GlobalData_weibo_sina_qq";


/*the last one near_invite data*/
NSString * const GlobalData_near_invite=@"GlobalData_near_invite";

/*change root invite data*/
NSString * const GlobalData_apn_notification_name_change_rootInvite_data=@"GlobalData_apn_notification_name_change_rootInvite_data";
NSString * const GlobalData_apn_notification_name_change_Invite_data=@"GlobalData_apn_notification_name_change_Invite_data";

//getsubinvites cache
NSString * const GlobalData_near_subinvites=@"GlobalData_near_subinvites";


/* close take view notify */
NSString * const GlobalData_SENDPICSUCCESSS_CLOSE_TAKEPICVIEW=@"GlobalData_SENDPICSUCCESSS_CLOSE_TAKEPICVIEW";

/* XMPP New Register  Account */
NSString * const GlobalData_XMPP_NEWREGSITER_ACCOUNT=@"GlobalData_XMPP_NEWREGSITER_ACCOUNT";


/* XMPP Register New Invite  */
NSString * const GlobalData_XMPP_NEWINVITE_MSG_REGISTER_ADD=@"GlobalData_XMPP_NEWINVITE_MSG_REGISTER_ADD";
NSString * const GlobalData_XMPP_NEWINVITE_MSG_REGISTER_REMOVE=@"GlobalData_XMPP_NEWINVITE_MSG_REGISTER_REMOVE";

/*退出登录XMPP*/
NSString * const GlobalData_XMPP_LOGINOUTXMPP=@"GlobalData_XMPP_LOGINOUTXMPP";

/*XMPP Notify Msg*/
NSString * const GlobalData_XMPP_NEWINVITE_REGISTER_NEWACCOUNT=@"GlobalData_XMPP_NEWINVITE_REGISTER_NEWACCOUNT";

/*XMPP Single InviteView Notify Msg*/
NSString * const GlobalData_XMPP_SINGLE_INVITEVIEW_MSG=@"GlobalData_XMPP_SINGLE_INVITEVIEW_MSG";


/*XMPP - direct_message  私信*/
NSString * const GlobalData_XMPP_DIRECT_MESSAGE=@"GlobalData_XMPP_DIRECT_MESSAGE";
/*XMPP 刷新界面*/
NSString * const GlobalData_XMPP_DIRECT_MESSAGE_REFERESHTABLE=@"GlobalData_XMPP_DIRECT_MESSAGE_REFERESHTABLE";
/*XMPP 现场首页图片改变*/
NSString * const GlobalData_XMPP_SCENE_CHANGE_BGIMAGE=@"GlobalData_XMPP_SCENE_CHANGE_BGIMAGE";
NSString * const GlobalData_XMPP_SCENE_CHANGE_BGIMAGE_SENDNOTIFY=@"GlobalData_XMPP_SCENE_CHANGE_BGIMAGE_SENDNOTIFY";

/*XMPP 现场最美图片改变*/
NSString * const GlobalData_XMPP_SCENE_MOST_BUEATIFUL=@"GlobalData_XMPP_SCENE_MOST_BUEATIFUL";
NSString * const GlobalData_XMPP_SCENE__MOST_BUEATIFUL_SENDNOTIFY=@"GlobalData_XMPP_SCENE__MOST_BUEATIFUL_SENDNOTIFY";


/*XMPP 商家后台消息推送 */
NSString * const GlobalData_XMPP_BUSINESS_MESSAGE=@"GlobalData_XMPP_BUSINESS_MESSAGE";
NSString * const GlobalData_XMPP_BUSINESS_MESSAGE_SENDNOTIFY=@"GlobalData_XMPP_BUSINESS_MESSAGE_SENDNOTIFY";

/*评论信息来照片了*/
NSString * const GlobalData_XMPP_COMMITPHOTO=@"GlobalData_XMPP_COMMITPHOTO";
NSString * const GlobalData_XMPP_COMMITPHOTO_SENDNOTIFY=@"GlobalData_XMPP_COMMITPHOTO_SENDNOTIFY";


/*关注信息 */
NSString * const GlobalData_XMPP_ATTENTION_MESSAGE = @"GlobalData_XMPP_ATTENTION_MESSAGE"; //Attention
NSString * const GlobalData_XMPP_ATTENTION_MESSAGE_SENDNOTIFY= @"GlobalData_XMPP_ATTENTION_MESSAGE_SENDNOTIFY";


/*版本提醒更新*/
NSString * const GlobalData_XIANCHANGJIA_VERSION_NOTIRY=@"GlobalData_XIANCHANGJIA_VERSION_NOTIRY";  //版本提醒次数  每次打开软件累积加+1
NSString * const GlobalData_XIANCHANGJIA_VERSION_NOTIRY_NEVER=@"GlobalData_XIANCHANGJIA_VERSION_NOTIRY_NEVER";  //版本提醒次数 再也不再提示


/*消息提示栏进入消息中心界面*/
NSString * const GlobalData_XMPPMSG_TATGETWITHNOTIVTYVIEW=@"GlobalData_XMPPMSG_TATGETWITHNOTIVTYVIEW";

SINGLETON_GCD(GlobalData);


-(NSDate*) lastCheckUrlTime
{
	return [NSDate dateWithTimeIntervalSinceReferenceDate:[USER_DEFAULT doubleForKey:GlobalData_lastCheckUrlTime]];
}
-(void) setLastCheckUrlTime:(NSDate *)time
{
	[USER_DEFAULT setDouble:time.timeIntervalSinceReferenceDate forKey:GlobalData_lastCheckUrlTime];
}
////////new server url
-(NSString*) NewServer_URL
{
	return [USER_DEFAULT valueForKey:GlobalData_safe_main_NewServer_URL];
}
-(void) setNewServer_URL_bate:(NSString *)url
{
	[USER_DEFAULT setValue:url forKey:GlobalData_safe_main_NewServer_URL];
}
-(NSURL*) main_url
{
	return [USER_DEFAULT URLForKey:GlobalData_main_url];
}
-(void) setMain_url:(NSURL *)main_url
{
	[USER_DEFAULT setURL:main_url forKey:GlobalData_main_url];
}
-(NSURL*) safe_main_url
{
	return [USER_DEFAULT URLForKey:GlobalData_safe_main_url];
}
-(void) setSafe_main_url:(NSURL *)safe_main_url
{
	[USER_DEFAULT setURL:safe_main_url forKey:GlobalData_safe_main_url];
}
-(NSString *) main_server
{
	return [USER_DEFAULT stringForKey:GlobalData_main_server];
}
-(void)setMain_server:(NSString *)main_server
{
	[USER_DEFAULT setValue:main_server forKey:GlobalData_main_server];
}
-(NSString*) upload_url
{
	return [USER_DEFAULT stringForKey:GlobalData_upload_url];
}
-(void)setUpload_url:(NSString *)upload_url
{
	[USER_DEFAULT setValue:upload_url forKey:GlobalData_upload_url];
}
-(NSString *)upload_headurl
{
	return [USER_DEFAULT stringForKey:GlobalData_upload_headurl];
}
-(void)setUpload_headurl:(NSString *)upload_headurl
{
	return [USER_DEFAULT setValue:upload_headurl forKey:GlobalData_upload_headurl];
}

/**
 *  if has login
 *
 *  @return BOOL
 */
-(BOOL)hasLogin
{
	NSString *session=[USER_DEFAULT objectForKey:GlobalData_user_session];
	return session!=nil;
}

/**
 *  add Commond
 *
 *  @param req <#req description#>
 */
-(void)addCommentCommandInfo:(NSMutableDictionary*)req
{
    if ([USER_DEFAULT objectForKey:GlobalData_user_session]) {
		[req setObject:[USER_DEFAULT objectForKey:GlobalData_user_session] forKey:@"sessionid"];
	}
	
	BOOL stopsycweibo=[[USER_DEFAULT objectForKey:GlobalData_stopsyncweibo] boolValue];
	if(stopsycweibo)
	{	//停止发微博
		[req setObject:[NSNumber numberWithInt:0] forKey:@"stopsync"];
	}else{
		//发微博
		[req setObject:[NSNumber numberWithInt:1] forKey:@"stopsync"];
	}
	
    [req setObject:[NSNumber numberWithInt:0] forKey:@"stopsync"]; //停止 发微博
    
	NSNumber * lng = [USER_DEFAULT valueForKey:GlobalData_lng];
    NSNumber * lat = [USER_DEFAULT valueForKey:GlobalData_lat];
    if (lng != nil && lat != nil) {
        NSMutableDictionary* locobj=[[NSMutableDictionary alloc] init];
        [locobj setObject:lat forKey:@"lat"];
        [locobj setObject:lng forKey:@"lng"];
        [locobj setObject:[NSNumber numberWithInt:10] forKey:@"alt"];
        [req setObject:locobj forKey:@"location"];
    }
}

/**
 *  fill user info
 *
 *  @param dic user json dic
 */
-(void) pullUserData:(NSDictionary * ) result
{
    if (result==nil) {
        return;
	} 
     
 
    
	[USER_DEFAULT setObject:[result objectForKey:@"xmpp_password"] forKey:GlobalData_user_password];
	if([result valueForKey:@"signature"]!=nil&&[result valueForKey:@"signature"]!=[NSNull null])
	{
        [USER_DEFAULT setObject:[result objectForKey:@"signature"] forKey:GlobalData_user_signature];
	}
    
	if([result valueForKey:@"avatar"]!=nil&&[result valueForKey:@"avatar"]!=[NSNull null])
	{
        [USER_DEFAULT setObject:[result objectForKey:@"avatar"] forKey:GlobalData_user_pic];
	}
    
    
    
	if ([result valueForKeyPath:@"avatar"]) {
        NSString * strurl = [NSString stringWithFormat:@"%@",[result valueForKeyPath:@"avatar"]];
        NSString * newurl = [tools ReturnNewURLBySize:strurl lengDp:180 status:@""];
        [USER_DEFAULT setValue:newurl forKey:GlobalData_user_pic_small];
	}
    
	if([result valueForKey:@"followers_count"]!=nil&&[result valueForKey:@"followers_count"]!=[NSNull null])
	{
		[USER_DEFAULT setValue:[result objectForKey:@"followers_count"] forKey:GlobalData_user_followers_num];
	}
    
    
	if([result valueForKey:@"avatar_external"]!=nil&&[result valueForKey:@"avatar_external"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"avatar_external"] forKey:GlobalData_user_avatar_external];
	}
    
    
	if([result valueForKey:@"friends_count"]!=nil&&[result valueForKey:@"friends_count"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"friends_count"] forKey:GlobalData_user_friends_num];
	}
    
    
    
	if([result valueForKey:@"birthday"]!=nil&&[result valueForKey:@"birthday"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"birthday"] forKey:GlobalData_user_birthday];
	}
    
    
	if([result valueForKey:@"is_follower"]!=nil&&[result valueForKey:@"is_follower"]!=[NSNull null])
	{
		[USER_DEFAULT setValue:[result objectForKey:@"is_follower"] forKey:GlobalData_user_is_follower];
	}
    
    
	if([result valueForKey:@"active"]!=nil&&[result valueForKey:@"active"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"active"] forKey:GlobalData_user_active];
	}
    
    
	if([result valueForKey:@"background_external"]!=nil&&[result valueForKey:@"background_external"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"background_external"] forKey:GlobalData_user_background_external];
	}
    
    
    
    if([result valueForKey:@"id"]!=nil&&[result valueForKey:@"id"]!=[NSNull null])
    {
        [USER_DEFAULT setValue:[result objectForKey:@"id"] forKey:GlobalData_user_id];
    }
    
	//GlobalData_user_info_bg
    
    
	if([result valueForKey:@"background"]!=nil&&[result valueForKey:@"background"]!=[NSNull null])
	{
		[USER_DEFAULT setValue:[result objectForKey:@"background"] forKey:GlobalData_user_info_bg];
	}
    
    
    
	if([result valueForKey:@"background_image"]!=nil&&[result valueForKey:@"background_image"]!=[NSNull null])
	{
		[USER_DEFAULT setValue:[result objectForKey:@"background_image"] forKey:GlobalData_user_bgImage];
	}
    
    
	if([result valueForKey:@"name"]!=nil&&[result valueForKey:@"name"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"name"] forKey:GlobalData_user_name];
	}
    
    
    
	if([result valueForKey:@"gender"]!=nil&&[result valueForKey:@"gender"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"gender"] forKey:GlobalData_user_sex];
	}
    
	//sex
	if([result valueForKey:@"marriage"]!=nil&&[result valueForKey:@"marriage"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"marriage"] forKey:GlobalData_user_married];
	}
	if([result valueForKey:@"age"]!=nil&&[result valueForKey:@"age"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result objectForKey:@"age"] forKey:GlobalData_user_age];
	}
    
	if([result valueForKey:@"astro"]!=nil&&[result valueForKey:@"astro"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result valueForKey:@"astro"] forKey:GlobalData_user_astro];
	}
	if([result valueForKey:@"height"]!=nil&&[result valueForKey:@"height"]!=[NSNull null])
	{
        [USER_DEFAULT setValue:[result valueForKey:@"height"] forKey:GlobalData_user_height];
	}
    
	//	NSString * user_desInfo = [NSString  stringWithFormat:@" %@ %@ %@ %@cm",[USER_DEFAULT integerForKey:GlobalData_user_sex] == 1?@"男":@"女",[result valueForKeyPath:@"age"],[result valueForKeyPath:@"astro"],[result valueForKeyPath:@"height"]];
	//	[USER_DEFAULT setObject:user_desInfo forKey:GlobalData_user_desInfo];
	[USER_DEFAULT synchronize];
}

///初始化Decivices
- (void) initCurrentDeciviceDBDataBase
{
	if ([self hasLogin]) {
		
		[[XCDataDBFactory shardDataFactory] closeDatabase];
		//	开启数据库
		NSString * databaseName = [NSString stringWithFormat:@"%@_%@",[USER_DEFAULT objectForKey:GlobalData_user_id],TableName];
		[[XCDataDBFactory shardDataFactory] CreateDataBase:databaseName];
		SLog(@"databaseName:%@",databaseName);
        
         double delayInSeconds = 0.1;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         //TODO: Get User Credit ...
         NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
         [self addCommentCommandInfo:postdata];
         [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"credit" Action:@"get" success:^(id obj) {
             SLog(@"%@",obj);
             int cun = [[obj valueForKey:@"total_credits"] intValue];
             if (cun > 0) {
                 [USER_DEFAULT setInteger:cun forKey:GlobalData_user_cerdit];
                 [USER_DEFAULT synchronize];
             }
         } error:^(NSInteger index) {
         
         } failure:^(NSError *error) {
         
         }];
         });
	}
    
}

///增加用户积分
- (void) AddUserCredit
{
	if ([self hasLogin]) {
		
        NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
        [self addCommentCommandInfo:postdata];
        [postdata setValue:@"10" forKey:@"credit"];
        [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"credit" Action:@"add" success:^(id obj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectCredit" object:nil];
        } error:^(NSInteger index) {
            
        } failure:^(NSError *error) {
            
        }];
	}
}

/// 初始化现场所有Ip地址
-(void) initCurrentScenseIPAdress
{
    NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
    [postdata setValue:@"2" forKey:@"sceneid"];
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"bigscreen" Action:@"getscenelanip" success:^(id obj) {
        NSInteger r = [[obj valueForKeyPath:@"response_code"] intValue];
        if (r == 1) {
            NSArray * arrayIpList = [obj valueForKeyPath:@"iplist"];
            /*
             "iplist":[
             "192.168.8.247",
             "129.5.89.45"
             ]
             */
            if (arrayIpList) {
                [USER_DEFAULT setObject:arrayIpList forKey:GlobalData_user_ScenseIp];
                [USER_DEFAULT synchronize];
            }
        }
    } error:^(NSInteger index) {
        
    } failure:^(NSError *error) {
        
    }];
}
-(NSString*) facImageNameWithIndex:(NSInteger) index
{
    if (self.FacArray == nil) {
        self.FacArray = @[@"sticker_126361874215276",
                          @"sticker_126361884215275",
                          @"sticker_126361890881941",
                          @"sticker_126361900881940",
                          @"sticker_126361910881939",
                          @"sticker_126361920881938",
                          @"sticker_126361957548601",
                          @"sticker_126361967548600",
                          @"sticker_126361974215266",
                          @"sticker_126361987548598",
                          @"sticker_126361994215264",
                          @"sticker_126362007548596",
                          @"sticker_126362027548594",
                          @"sticker_126362034215260",
                          @"sticker_126362044215259",
                          @"sticker_126362064215257",
                          @"sticker_126362074215256",
                          @"sticker_126362080881922",
                          @"sticker_126362087548588",
                          @"sticker_126362100881920",
                          @"sticker_126362107548586",
                          @"sticker_126362117548585",
                          @"sticker_126362124215251",
                          @"sticker_126362130881917",
                          @"sticker_126362137548583",
                          @"sticker_126362160881914",
                          @"sticker_126362167548580",
                          @"sticker_126362180881912",
                          @"sticker_126362187548578",
                          @"sticker_126362230881907",
                          @"sticker_126362207548576",
                          @"sticker_126362197548577"];
    }
    
    if (index < self.FacArray.count) {
        return self.FacArray[index];
    }
    return @"";
}

@end
