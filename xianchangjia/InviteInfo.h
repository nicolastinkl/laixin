//
//  InviteInfo.h
//  try
//
//  Created by JIJIA &&&&& amen on 11-7-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tools.h"
#import <CoreLocation/CoreLocation.h>
#import "TalkData.h"
#import "UserInfo.h"
/*
 新接口 ------------------------------------------------------
 周边商圈
 */
@interface Nearest_areas_Info : NSObject
@property (assign,nonatomic) NSInteger  type;
@property (assign,nonatomic) NSInteger  scene_total_num;
@property (assign,nonatomic) NSInteger	address_lat;
@property (assign,nonatomic) NSInteger	address_lng;
@property (assign,nonatomic) NSInteger	area_id;
@property (strong,nonatomic) NSString	*area_name;
@property (strong,nonatomic) NSString	*description;
@property (assign,nonatomic) NSInteger  user_num;
@property (strong,nonatomic) NSDictionary*domain_scene;

-(id)initWithJSONObject:(NSDictionary*)data;
@end

@interface SceneInfo : NSObject
@property (assign,nonatomic) NSInteger SceneInfo_id;
@property (strong,nonatomic) NSString *SceneInfo_name;
@property (strong,nonatomic) NSString *SceneInfo_description;
@property (assign,nonatomic) NSInteger address_lat;
@property (assign,nonatomic) NSInteger address_lng;
@property (strong,nonatomic) NSString *SceneInfo_showcase_image;
@property (assign,nonatomic) CLLocationDistance distanse;
@property (assign,nonatomic) NSInteger  user_num;
-(id) initWithJSONObject:(NSDictionary*) data;
-(BOOL) updateDistanse;
-(CLLocation*) getLocation;
@end
//现场列表全部信息
@interface Scene_Whole_info : NSObject
@property (strong,nonatomic) SceneInfo *sceneinfo;
@property (strong,nonatomic) NSArray *stars;
@property (strong,nonatomic) NSArray *friends;
-(id) initWithJSONObject:(NSDictionary*) data;
@end

@interface recommendations_Scene : Scene_Whole_info
@property (strong,nonatomic) SceneInfo *sceneinfo;
@property (strong,nonatomic) NSArray *stars;
@property (strong,nonatomic) NSString *reason;
@property (strong,nonatomic) NSString *tag_image;
-(id) initWithJSONObject:(NSDictionary*) data;
@end


// ------------------------------------------------------


@interface MemberInfo : NSObject
@property (assign,nonatomic) NSInteger user_id;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSDate *add_time;
@property (strong,nonatomic) NSURL *user_pic;
@property (strong,nonatomic) NSURL *user_pic_small;
@property (assign,nonatomic) BOOL isFollow;
-(id) initWithJSONObject:(NSDictionary*) data;
@end

@interface SubInviteInfo : NSObject {
@private
	NSMutableDictionary *_runingdata;
}
@property (assign,nonatomic) NSInteger invite_id;
@property (assign,nonatomic) NSInteger parent;
@property (assign,nonatomic) NSInteger creator_id;
@property (strong,nonatomic) NSString* user_name;
@property (strong,nonatomic) NSDate * time;
@property (strong,nonatomic) NSURL *user_pic;
@property (strong,nonatomic) NSURL *user_pic_small;
@property (strong,nonatomic) NSString *address;
@property (assign,nonatomic) NSInteger address_lat;
@property (assign,nonatomic) NSInteger address_lng;
@property (strong,nonatomic) NSString *creator_word;
@property (assign,nonatomic) CLLocationDistance distanse;
@property (assign,nonatomic) BOOL isfollowcreator;
@property (assign,nonatomic) NSInteger follow_count;
@property (strong,nonatomic) NSURL *invite_picture;
@property (strong,nonatomic,getter = runingdata) NSMutableDictionary *runingdata;
-(NSMutableDictionary *)runingdata;
-(id) initWithJSONObject:(NSDictionary*) oneinvite;
-(BOOL) updateDistanse;
-(CLLocation*) getLocation;
@end


//评论信息
/*{
 "content":"哦破去了",
 "comment_time":"2013-01-29 14:48:29",
 "target_post":{
 "iamge":"http://api.xianchangjia.com/15a0a857914ad9e42b07b84a235d1a0bd094b77c.jpg",
 "is_external":false
 },
 "reviewer":{
 "is_external":false,
 "user_name":"表弟:娃娃",
 "id":736,
 "avatar":"http://api.xianchangjia.com/3806d21c17e75c819a16bccb66310ee779ca69b4.jpg"
 },
 "audio":{
 "audio_src":null,
 "audio_length":0,
 "status":0
 },
 "id":1356
 },*/
@interface commentpostInfo : NSObject
@property (assign,nonatomic) unsigned long long comment_id;
@property (assign,nonatomic) unsigned long long to_post_id;
@property (strong,nonatomic) NSString *comment_content;
@property (strong,nonatomic) NSString *comment_time;
@property (strong,nonatomic) NSString *comment_image_url;

@property (strong,nonatomic) UserInfo_default *userinfo;

//@property (assign,nonatomic) NSInteger comment_user_userid;
//@property (strong,nonatomic) NSString *comment_user_avatar;
//@property (strong,nonatomic) NSString *comment_user_name;

@property (assign,nonatomic) NSInteger comment_audio_status;
@property (assign,nonatomic) NSInteger comment_audio_length;
@property (strong,nonatomic) NSString *comment_audio_src;

-(id) initWithJSONObject:(NSDictionary*) oneinvite;
@end


@interface InviteLog : NSObject
@property (assign,nonatomic) NSInteger user_id;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSURL *user_pic;
@property (strong,nonatomic) NSURL *user_pic_small;
@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSDate *time;
-(id) initWithJSONObject:(NSDictionary*) oneinvite;
@end
@interface InviteInfoData : SubInviteInfo
@property (strong,nonatomic) NSDate * endtime;
@property (assign,nonatomic) BOOL certification;
@property (assign,nonatomic) BOOL active;
@property (assign,nonatomic) NSInteger coupon_count;
@property (assign,nonatomic) NSInteger join_count;
@property (assign,nonatomic) NSInteger credit;
@property (strong,nonatomic) NSArray *recent_talk;
@property (strong,nonatomic) NSArray *subinvites;
@property (assign,nonatomic) NSInteger subinvitecount;
@property (strong,nonatomic) NSArray *star;
@property (strong,nonatomic) NSArray *members;
@property (assign,nonatomic) BOOL hasdevice;
@property (assign,nonatomic) NSInteger time_proposal;
//@property (assign,nonatomic) BOOL joined;
@property (assign,nonatomic) BOOL isfavorite;
@property (strong,nonatomic) NSString * area_name;
@property (strong,nonatomic) NSString * index;  //每个现场索引
@property (strong,nonatomic) NSString * scene_cover_image;
-(id) initWithJSONObject:(NSDictionary*) oneinvite;
-(BOOL) isMemberLeave:(MemberInfo*) member;
-(BOOL) updateDistanse;
-(NSComparisonResult) compare:(InviteInfoData*) other;
-(NSComparisonResult) compareDesc:(InviteInfoData*) other;
@end

@class WaitConfirmJoinData;
enum {
	JOINTYPE_SOUNDWAVE = 1,
	JOINTYPE_IPADDRESS = 2,
	JOINTYPE_GPS=3,
	JOINTYPE_SONG=4,
	};

@interface JoinInviteInfoData :NSObject
@property (assign,nonatomic) NSUInteger invite_id;
@property (assign,nonatomic) BOOL joined;
@property (assign,nonatomic) NSDate *jointime;
@property (strong,nonatomic) CLLocation *location;
@property (strong,nonatomic) NSString *address;
@property (assign,nonatomic) BOOL certification;
@property (assign,nonatomic) int jointype;
@property (strong,nonatomic) NSNumber *SoundWaveData;
-(id) initWithJSONObject:(NSDictionary*) oneinvite;
-(id) initWithWaitConfirmJoinData:(WaitConfirmJoinData*)data;
@end

@interface  WaitConfirmJoinData : NSObject {
@private
    NSInteger invite_id;
    NSString* user_name;
    NSString *address;
    CLLocation *location;
    NSString *creator_word;
    CLLocationDistance distanse;
}
@property (assign,nonatomic) NSInteger invite_id;
@property (strong,nonatomic) NSString* user_name;
@property (strong,nonatomic) NSString *address;
@property (strong,nonatomic) CLLocation *location;
@property (strong,nonatomic) NSString *creator_word;
@property (assign,nonatomic) CLLocationDistance distanse;
-(id) initWithJSONObject:(NSDictionary*)data;
@end

@interface InviteDetailInfo : NSObject
@property (assign,nonatomic) NSInteger join_state;
@property (assign,nonatomic) NSInteger address_lat;
@property (assign,nonatomic) NSInteger address_lng;
@property (assign,nonatomic) NSInteger creator_id;
@property (strong,nonatomic) NSString *creator_name;
@property (strong,nonatomic) NSString *crearor_word;
@property (strong,nonatomic) NSString *address_str;
@property (strong,nonatomic) NSURL *creator_pic;
@property (strong,nonatomic) NSURL *creator_pic_small;
@property (strong,nonatomic) NSString* src_phone;
@property (strong,nonatomic) NSString* src_title;
@property (strong,nonatomic) NSDate *time,*endtime;
@property (assign,nonatomic) NSInteger coupon_count;
@property (assign,nonatomic) BOOL certification;
@property (assign,nonatomic) BOOL active;
@property (assign,nonatomic) NSInteger join_count;
@property (assign,nonatomic) BOOL isfavorite;
@property (assign,nonatomic) NSInteger credit;
-(id)initWithJSONObject:(NSDictionary*)data;
-(CLLocation*) getLocation;
@end


@interface MessageInfo : NSObject
@property (assign,nonatomic) NSInteger index_message;
@property (assign,nonatomic) NSInteger id_message;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSURL *creator_pic;
@property (strong,nonatomic) NSURL *creator_pic_small;
@property (assign,nonatomic) NSInteger type;
@property (strong,nonatomic) NSDate *time;
-(id)initWithJSONObject:(NSDictionary*)data;
@end


/*member info*/
@interface InviteMemberInfo : UserInfo
@property (strong,nonatomic) NSDate* time;
@property (assign,nonatomic) NSInteger state;
@property (assign,nonatomic) BOOL isleave;
@property (assign,nonatomic) NSUInteger reqphone_count;
@property (strong,nonatomic) NSString * profile;

/*new add
 "time":"2012-10-23 14:38:57",
 "join_count":1,
 "member_role":"",
 "member_role_id":0,
 "rank":0,
 "member_credits":0,
 "follow_num":69,
 "followby_num":46,
 */
@property (strong,nonatomic) NSURL* user_bk_pic;
@property (assign,nonatomic) int join_count;
@property (assign,nonatomic) int member_role_id;
@property (assign,nonatomic) int member_credits;
@property (assign,nonatomic) int rank;
@property (strong,nonatomic) NSString *member_role;
@property (assign,nonatomic) int follow_num;
@property (assign,nonatomic) int followby_num;
@property (assign,nonatomic) BOOL isFollow;

-(id)initWithJSONObject:(NSDictionary*)data;
@end



/*invite favorites*/
@interface InvitefavoriteInfo : InviteInfoData
@property (assign,nonatomic) NSInteger new_talk_count;
-(id)initWithJSONObject:(NSDictionary*)data;
@end




/*新接口
 现场背景数据模型 信息
 */
@interface Scene_bgImage_change_Info : NSObject
@property (strong,nonatomic) NSDate* start_time;
@property (assign,nonatomic) NSInteger type;
@property (assign,nonatomic) NSUInteger duration;
@property (assign,nonatomic) NSUInteger scene_id;
@property (strong,nonatomic) NSString * Message;
@property (strong,nonatomic) NSString * url;

-(id)initWithJSONObject:(NSDictionary*)data;
@end



/*
商家消息
 {"scene_id":5778,"type":30,"from":"现场+","theme":"消息推送","content":"偶吧刚拿四大","timestamp":"2012-10-12 21-21-21"}
*/
@interface Business_Message : NSObject
@property (assign,nonatomic) NSInteger scene_id;
@property (strong,nonatomic) NSString *	from;
@property (strong,nonatomic) NSString *	theme;
@property (strong,nonatomic) NSString *	content;
@property (strong,nonatomic) NSString *	timestamp;
@property (strong,nonatomic) NSString *	imageUrl;
-(id)initWithJSONObject:(NSDictionary*)data;
@end


/*
 新照片评论信息
 {"type":50,"commit_userid":12931,"commit_picrowid":123213,"commit_nick":"tinkl","commit_content":"偶吧刚拿四大","created_at":"2012-10-12 21-21-21","commit_userpic":"http://userpic","commit_image_url":"http://ajsdkfjadklsadsfdas"}

 */
@interface NewCommitPhoto_Message : NSObject
@property (assign,nonatomic) NSInteger commit_userid;
@property (assign,nonatomic) unsigned long long commit_picrowid;
@property (strong,nonatomic) NSString *created_at;
@property (strong,nonatomic) NSString *commit_nick;
@property (strong,nonatomic) NSString *commit_content;
@property (strong,nonatomic) NSString *commit_userpic;
@property (strong,nonatomic) NSString *commit_image_url;
@property (assign,nonatomic) NSInteger have_audio;
@property (assign,nonatomic) NSInteger user_pic_external;
-(id)initWithJSONObject:(NSDictionary*)data;
@end



/*声波加入的现场*/
@interface InviteJoined : NSObject
@property (assign,nonatomic) NSInteger scene_id;
@property (assign,nonatomic) NSInteger address_lat;
@property (assign,nonatomic) NSInteger address_lng;
@property (strong,nonatomic) NSString *	address;
@property (strong,nonatomic) NSString *	check_time;
@property (strong,nonatomic) NSString *	showcase_image;
@property (assign,nonatomic) NSInteger certification;
@property (assign,nonatomic) NSInteger jointype;
@property (strong,nonatomic) NSString *	prompt;  //打开信息
@property (assign,nonatomic) NSInteger checkin_status;//成功状态 0失败1成功
@property (assign,nonatomic) bool ignore_interval;

-(id)initWithJSONObject:(NSDictionary*)oneinvite;
@end



@interface InvitefavoriteInfoNew : NSObject
/*"scene_id":18052,
 "add_time":"2012-11-12 14:39:43",
 "parent":18047,
 "address":"滇草香云南原生态火锅(工体店)",
 "address_lat":39932561,
 "address_lng":116443486,
 "creator_word":"其他火锅,keikkk hello!",*/

@property (assign,nonatomic) NSInteger scene_id;
@property (assign,nonatomic) NSInteger parent;
@property (strong,nonatomic) NSString *	address;
@property (strong,nonatomic) NSString *	creator_word;
@property (strong,nonatomic) NSDate *	add_time;
@property (assign,nonatomic) NSInteger address_lat;
@property (assign,nonatomic) NSInteger address_lng;
@property (strong,nonatomic) NSArray *recent_talk;
@property (strong,nonatomic) NSArray *star;
-(id)initWithJSONObject:(NSDictionary*)oneinvite;
@end


/*{
 "user_info":{
 "user_id":6281,
 "user_name":"17",
 "user_pic":"http://tp4.sinaimg.cn/3137494895/180/5651302531/0",
 "user_pic_small":"http://tp4.sinaimg.cn/3137494895/50/5651302531/0"
 },
 "scene_id":"41",
 "parent":"40",
 "start_time":null,
 "address":"ALFA餐吧",
 "address_lat":"39933407",
 "address_lng":"116440216",
 "creator_word":"",
 "endtime":null,
 "talkinfo":{
 "user_word":"楼上楼下都很有感觉",
 "image":"http://livep-photobarn.stor.sinaapp.com/cb263c9eff69f99eb614f384bb15812fd1b9bb3d",
 "small_img":"http://livep-photobarn.stor.sinaapp.com/medium/cb263c9eff69f99eb614f384bb15812fd1b9bb3d",
 "audiosrc":null,
 "audiolength":"0"
 }
 },
 好友生活圈
 */

@interface Friends_Nearest_areas_Info : NSObject<NSCoding>
@property (strong,nonatomic) UserInfo_default *userinfo;
@property (strong,nonatomic) NSString		  *image;
@property (strong,nonatomic) NSString		  *small_img;
@property (strong,nonatomic) NSString		  *scene_address;

-(id)initWithJSONObject:(NSDictionary*)oneinvite;
@end


@interface MessageListInfo : NSObject
/*childid int,message_screent_name  text,lastMessageText text, sender_profile_image_url text, unreadMessages int, created_at double)*/
@property (assign,nonatomic) NSInteger childid;
@property (strong,nonatomic) NSString *	message_screent_name;
@property (strong,nonatomic) NSString *	lastMessageText;
@property (strong,nonatomic) NSString *	sender_profile_image_url;
@property (assign,nonatomic) NSInteger unreadMessages;
@property (strong,nonatomic) NSString	  *	created_at;
-(id)initWithJSONObject:(NSDictionary*)data;
@end

