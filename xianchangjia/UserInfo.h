//
//  UserInfo.h
//  try
//
//  Created by JIJIA &&&&& apple on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TalkData;
@interface UserInfo : NSObject
@property (assign,nonatomic) NSInteger user_id;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSURL* user_pic;
@property (strong,nonatomic) NSURL* user_pic_small;
@property (assign,nonatomic) int sex;
@property (strong,nonatomic) NSDate *birthday;
@property (assign,nonatomic) int marriage;
-(id)initWithJSONObject:(NSDictionary*)data;
@end

/*super object of user*/
@interface UserInfo_default : NSObject
@property (assign,nonatomic) NSInteger user_id;
@property (assign,nonatomic) NSInteger user_followers_num;
@property (assign,nonatomic) NSInteger user_friends_num;
@property (assign,nonatomic) NSInteger user_gender;
@property (assign,nonatomic) NSInteger user_marriage;
@property (assign,nonatomic) BOOL avatar_external_BOL;
@property (assign,nonatomic) BOOL is_follower;
@property (assign,nonatomic) BOOL background_external_BOL;
@property (assign,nonatomic) BOOL user_active;
@property (strong,nonatomic) NSDate *birthday;
@property (strong,nonatomic) NSString *user_profile;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSString *user_avatar_image_big;
@property (strong,nonatomic) NSString *user_avatar_image;
@property (strong,nonatomic) NSString *user_background_image;
@property (strong,nonatomic) NSString *background_image;

@property (strong,nonatomic) NSString *user_age;
@property (assign,nonatomic) NSInteger user_height;
@property (strong,nonatomic) NSString *user_astro;

@property (strong,nonatomic) NSString *user_desInfo;
@property (strong,nonatomic) NSString *auth_type;

@property (assign,nonatomic) BOOL can_invite;
@property (assign,nonatomic) unsigned long long auth_id;
 

-(id)initWithJSONObject:(NSDictionary*)data;
@end

/*现场用户列表*/
@interface SenceUserinfo : NSObject
@property (assign,nonatomic) NSInteger Scene_user_join_count;
@property (strong,nonatomic) NSString* Scene_user_rank;
@property (assign,nonatomic) NSInteger Scene_user_role_id;
@property (strong,nonatomic) NSString* Scene_user_role_name;
@property (strong,nonatomic) NSDate *  Scene_user_join_time;
@property (assign,nonatomic) NSInteger Scene_user_has_post;
@property (strong,nonatomic) UserInfo_default * userinfo;
-(id)initWithDictionary:(NSDictionary*)obj;
@end

/*照片流*/
@interface User_Piclog : NSObject
@property (assign,nonatomic) unsigned long long rowindex;
@property (assign,nonatomic) NSInteger			sender_id;				//发送人ID
@property (strong,nonatomic) NSDate   *time;
@property (strong,nonatomic) NSString *address;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *small_url;
@property (strong,nonatomic) NSString *small_url_Most;  //最小的预览图
@property (assign,nonatomic) NSInteger reply_count;
@property (strong,nonatomic) NSMutableArray *comments;
@property (strong,nonatomic) NSMutableArray *likes;

@property (strong,nonatomic) TalkData * talkdataMain;
-(id)initWithJSONObject:(NSDictionary*)data;
@end

//私信ModelInfo   
@interface DirectMessageInfo : NSObject
@property (assign,nonatomic) NSInteger		rowid;					//rowid
@property (assign,nonatomic) NSInteger		sender_id;				//发送人ID
@property (assign,nonatomic) NSInteger		recipient_id;			//收件人ID
@property (strong,nonatomic) NSString		*messagetext;			//私信内容
@property (strong,nonatomic) NSString		*sender_screen_name;    //昵称
@property (strong,nonatomic) NSDate			*created_at;			//发送时间
@property (strong,nonatomic) NSString		*sender_profile_image_url; // 发送人头像链接
@end



@interface FollowUserInfo : UserInfo
+(FollowUserInfo*) infoWithDictionary:(NSDictionary*)obj;
-(id)initWithDictionary:(NSDictionary*)obj;
@property (strong,nonatomic) NSString *profile;
@property (assign,nonatomic) BOOL isFollowed;
@property (assign,nonatomic) BOOL isgoodFriend;
@end

