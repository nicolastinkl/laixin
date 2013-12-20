//
//  GlobalData.h
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalData : NSObject

#define scene_most_bueatiful  10   //现场最美
#define table_scene_most_bueatiful  @"table_scene_most_bueatiful"   //现场最美 表名

#define scene_background	  20   //现场背景
#define table_scene_background		@"table_scene_background"		//现场背景 表名


#define  table_Have_check_message @"table_Have_check_message"   //关注消息  表名

/*动态*/
#define Attention_user_message		  40	//关注某人
#define  table_Attention_user_message @"Attention_user_message"   //关注消息  表名



#define commit_photo_message		  50	//对照片 评论
#define table_commit_photo_message  @"table_commit_photo_message"   //评价照片消息 表名

#define table_commit_photo_message_Unread  @"table_commit_photo_message_Unread"   //评价照片消息 未读消息
/*私信*/
#define chat_message		  100	//私信
#define table_chat_message_info  @"table_chat_message_info"			//详细信息表名
#define table_chat_message_list_info  @"table_chat_message_list_info"   // 未读消息以及所有用户消息列表

/*消息*/
#define business_message      30	//商家消息

#define table_business_list_change  @"table_business_list_change"

/*总类型*/
#define table_Message_Music  @"table_Message_Music"

#define table_All_XCFriends  @"table_All_XCFriends"

#define table_All_XCNewFans  @"table_All_XCNewFans"

#define table_All_XCMessage_activity  @"table_All_XCMessage_activity"

#define table_All_XCDomain_scense  @"table_All_XCDomain_scense"

#define table_All_XCRecomment_scense  @"table_All_XCRecomment_scense"

#define table_All_XCFavi_scense  @"table_All_XCFavi_scense"

#define table_All_XCRecomment_user  @"table_All_XCRecomment_user"

#define table_All__Notity_Message_activity_UserUseXC  @"table_All__Notity_Message_activity_UserUseXC" //首次登陆推荐好友在使用现场加 table

#define table_All__Notity_Message_activity_PhotoCommit  @"table_All__Notity_Message_activity_PhotoCommit" //集成照片评论列表 table
extern NSString *const GlobalData_service_url;

extern NSString * const GlobalData_sinaweibo_userID;
extern NSString * const GlobalData_sinaweibo_accesstoken;
extern NSString * const GlobalData_sinaweibo_refresh_token;
extern NSString * const GlobalData_sinaweibo_expirationDate;
#pragma mark  用户相关信息
extern NSString * const GlobalData_user_encrypted; //是否是md5值传到服务器取数据
extern NSString * const GlobalData_user_id;
extern NSString * const GlobalData_user_name;
extern NSString * const GlobalData_user_password;
extern NSString * const GlobalData_user_session;
extern NSString * const GlobalData_user_pic;   //480 b
extern NSString * const GlobalData_user_pic_small;  //480  m
extern NSString * const GlobalData_user_sex;
extern NSString * const GlobalData_user_birthday;
extern NSString * const GlobalData_user_bgImage;
extern NSString * const GlobalData_user_married;
extern NSString * const GlobalData_user_signature;  //签名
extern NSString * const GlobalData_user_friends_num;
extern NSString * const GlobalData_user_followers_num;
extern NSString * const GlobalData_user_desInfo;
extern NSString * const GlobalData_user_cerdit; //积分
extern NSString * const GlobalData_user_ScenseIp;

extern NSString * const GlobalData_user_height;
extern NSString * const GlobalData_user_astro;
extern NSString * const GlobalData_user_age;
extern NSString * const GlobalData_user_Integral;
extern NSString * const GlobalData_force_update;  //是否强制更新
extern NSString * const GlobalData_user_avatar_external; //用户图片链接是否外链
extern NSString * const GlobalData_user_background_external; //用户背景图片链接是否外链
extern NSString * const GlobalData_user_is_follower; //用户背景图片链接是否外链
extern NSString * const GlobalData_user_info_bg;  //背景图片String
extern NSString * const GlobalData_user_active;
#pragma mark  用户引导页
extern NSString * const GlobalData_user_Mainview_guid;  //是否显示用户引导
extern NSString * const GlobalData_user_Loginview_guid;  //是否显示开机用户引导
extern NSString * const GlobalData_user_Mainview_guid_count;  //用户引导 计数
#pragma mark  系统相关信息
extern NSString * const GlobalData_OPENMUSICLOCATION;  //是否开启声波定位
extern NSString * const GlobalData_new_mail_count;
extern NSString * const GlobalData_run_count;
extern NSString * const GlobalData_phoneserver;
extern NSString * const GlobalData_gobindphone;
extern NSString * const GlobalData_lastcommentindex;
extern NSString * const GlobalData_autosynccontact;
extern NSString * const GlobalData_notifysound;
extern NSString * const GlobalData_mappagefirstuse;
extern NSString * const GlobalData_unreadcomment;
extern NSString * const GlobalData_usecnmap;
extern NSString * const GlobalData_lastmailindex;
extern NSString * const GlobalData_nowvision;
extern NSString * const GlobalData_nowvisiondownloadlink;
extern NSString * const GlobalData_rejectvision;
extern NSString * const GlobalData_createinvitefirstuse;
extern NSString * const GlobalData_hasSuccessedLogin;
extern NSString * const GlobalData_lastCheckUrlTime;
extern NSString * const GlobalData_main_url;
extern NSString * const GlobalData_safe_main_url;
extern NSString * const GlobalData_main_server;
extern NSString * const GlobalData_upload_url;
extern NSString * const GlobalData_stopsyncweibo;
extern NSString * const GlobalData_safe_main_NewServer_URL; //new server  url
extern NSString * const GlobalData_recommend_scene;
extern NSString * const GlobalData_recommend_user;
extern NSString * const GlobalData_lat;
extern NSString * const GlobalData_lng;

/*device*/
extern NSString * const GlobalData_HomeViewSips;
extern NSString * const GlobalData_HomeViewLocatoinSips;

extern NSString * const MainCheckSite;

extern NSString * const Notify_UpdateUnreadMailCount;
extern NSString * const Notify_UpdateUnreadCommentCount;

/*APN Notification*/
extern NSString * const GlobalData_apn_notification_name;
extern NSString * const GlobalData_apn_notification_name_faviorites;
extern NSString * const GlobalData_apn_notification_name_nowjoin_address;
extern const int AppVision;
extern NSString * const GlobalData_apn_notification_name_userfootdata;

/*change root invite data*/
extern NSString * const GlobalData_apn_notification_name_change_rootInvite_data;
extern NSString * const GlobalData_apn_notification_name_change_Invite_data;
/*user data cache*/
extern NSString * const GlobalData_CACHE_USER_INFO_SELF;
extern NSString * const GlobalData_CACHE_USER_INFO_OTHERS;  // dic

extern NSString * const GlobalData_CACHE_USER_INFO_BK;  // User bk image
extern NSString * const GlobalData_CACHE_USER_INFO_ICON;  // user icon
/* Login user exit status */
extern NSString * const GlobalData_CACHE_USER_EXIT_STATUS;


/*local message */
extern NSString * const GlobalData_apn_notification_name_LocalNofityMessageCount_old;

/*change bg image*/
extern NSString * const GlobalData_apn_notification_name_changeBg;

/*welcome view main and chat view*/
extern NSString * const GlobalData_mainview_welcome;
extern NSString * const GlobalData_chatview_welcome;

/*sina weibo and qq weibo   binding*/
extern NSString * const GlobalData_weibo_sina_qq;

/*sina weibo and qq weibo   my self view*/
extern NSString * const GlobalData_weibo_sina_qq_self;


/*the last one near_invite data*/
extern NSString * const GlobalData_near_invite;

//getsubinvites cache
extern NSString * const GlobalData_near_subinvites;

/* close take view notify */
extern NSString * const GlobalData_SENDPICSUCCESSS_CLOSE_TAKEPICVIEW;

/* XMPP New Register  Account */
extern NSString * const GlobalData_XMPP_NEWREGSITER_ACCOUNT;

/*XMPP Notify Msg*/
extern NSString * const GlobalData_XMPP_NEWINVITE_REGISTER_NEWACCOUNT;
/*退出登录XMPP*/
extern NSString * const GlobalData_XMPP_LOGINOUTXMPP;

/* XMPP Register New Invite  */
extern NSString * const GlobalData_XMPP_NEWINVITE_MSG_REGISTER_ADD;
extern NSString * const GlobalData_XMPP_NEWINVITE_MSG_REGISTER_REMOVE;

/*XMPP Single InviteView Notify Msg*/
extern NSString * const GlobalData_XMPP_SINGLE_INVITEVIEW_MSG;

/*XMPP - direct_message  私信*/
extern NSString * const GlobalData_XMPP_DIRECT_MESSAGE;
/*XMPP 刷新界面*/
extern NSString * const GlobalData_XMPP_DIRECT_MESSAGE_REFERESHTABLE;
/*XMPP 现场首页图片改变*/
extern NSString * const GlobalData_XMPP_SCENE_CHANGE_BGIMAGE;
extern NSString * const GlobalData_XMPP_SCENE_CHANGE_BGIMAGE_SENDNOTIFY;

/*XMPP 现场最美会员图片改变*/
extern NSString * const GlobalData_XMPP_SCENE_MOST_BUEATIFUL;
extern NSString * const GlobalData_XMPP_SCENE__MOST_BUEATIFUL_SENDNOTIFY;

/*新照片评论 */
extern NSString * const GlobalData_XMPP_COMMITPHOTO;
extern NSString * const GlobalData_XMPP_COMMITPHOTO_SENDNOTIFY;

/*关注信息 */
extern NSString * const GlobalData_XMPP_ATTENTION_MESSAGE; //Attention
extern NSString * const GlobalData_XMPP_ATTENTION_MESSAGE_SENDNOTIFY;


/*XMPP 商家后台消息推送 */
extern NSString * const GlobalData_XMPP_BUSINESS_MESSAGE;
extern NSString * const GlobalData_XMPP_BUSINESS_MESSAGE_SENDNOTIFY;


/*版本提醒更新*/
extern NSString * const GlobalData_XIANCHANGJIA_VERSION_NOTIRY;  //版本提醒次数  每次打开软件累积加+1
extern NSString * const GlobalData_XIANCHANGJIA_VERSION_NOTIRY_NEVER;  //版本提醒次数 再也不再提示

/*消息提示栏进入消息中心界面*/
extern NSString * const GlobalData_XMPPMSG_TATGETWITHNOTIVTYVIEW;


//  KEYCHAIN
extern NSString * const KEY_USERNAME_PASSWORD;
extern NSString * const KEY_USERSESSION;
extern NSString * const KEY_PASSWORD;


+(GlobalData * ) sharedGlobalData;
-(BOOL) hasLogin;
-(void) addCommentCommandInfo:(NSMutableDictionary*)req;
-(void) pullUserData:(NSDictionary * ) dic;
- (void) initCurrentDeciviceDBDataBase;
- (void) AddUserCredit;
- (void) initCurrentScenseIPAdress;
@end
