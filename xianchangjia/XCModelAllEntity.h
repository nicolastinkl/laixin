//
//  XCModelAllEntity.h
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-9.
//
//

#import "LKDAOBase.h"

@interface XCModelAllEntity : LKModelBase

@end

/*私信*/
@interface Message_private_user : LKModelBase

@property(assign,nonatomic)NSInteger sender_id;
@property(assign,nonatomic)NSInteger recipient_id;
@property(strong,nonatomic)NSString *text;
@property(strong,nonatomic)NSString *sender_screen_name;
@property(strong,nonatomic)NSString *sender_profile_image_url;
@property(strong,nonatomic)NSString *created_at;
@property(strong,nonatomic)NSString *msgUUID;
@property(assign,nonatomic)NSInteger msgStutas;  //0送达  1已读  2失败
@property(assign,nonatomic)NSInteger msgType;	 //0默认文本类型  1录音类型  2图片类型 3 位置信息类型

- (id)initWithJsonDictionary:(NSDictionary*)dic;
@end

/*
 1:父表 统计所有未读信息 人员
 message_screent_name  接受人昵称
 unreadMessages  未读消息条数
 childid      对应子表id  ---- userid -- table
 sender_profile_image_url 头像URL
 lastMessageText 最后一条内容
 created_at  最后一条内容产生的时间
 */
@interface Message_private_list : LKModelBase
@property(assign,nonatomic) NSInteger childid;
@property(strong,nonatomic)NSString   *message_screent_name;
@property(assign,nonatomic) NSInteger unreadMessages;
@property(strong,nonatomic)NSString   *sender_profile_image_url;
@property(strong,nonatomic)NSString   *created_at;
@property(strong,nonatomic)NSString   *lastMessageText;
//- (id)initWithJsonDictionary:(NSDictionary*)dic;
@end

@interface Message_music_check : LKModelBase
//scene_id, address, prompt , check_time ,checkin_status ,jointype
@property(assign,nonatomic) NSInteger scene_id;
@property(strong,nonatomic) NSString *address;
@property(strong,nonatomic) NSString *check_time;

@end

@interface Message_Comment_postInfo : LKModelBase
@property (assign,nonatomic) int comment_id;
@property (assign,nonatomic) int to_post_id; 
@property (assign,nonatomic) NSInteger readStatus; //是否已读状态
@property (strong,nonatomic) NSString *comment_json;
@end

@interface Message_Comment_unread : LKModelBase
@property (assign,nonatomic) int comment_unread_id;
@property (assign,nonatomic) int comment_unread_type;
@property (assign,nonatomic) int comment_unread_number;
@property (strong,nonatomic) NSString *comment_unread_sign;
@end

/*类型一  有声音提醒类型*/
@interface Message_type_Music : LKModelBase
@property (strong,nonatomic) NSString *typeName;
@property (assign,nonatomic) int	   unreadNumber;
@property (assign,nonatomic) int	   type;
@end

@interface Friend_New_statuss_all : LKModelBase
@property (assign,nonatomic) int	   user_id;
@property (strong,nonatomic) NSString *user_name;
@property (strong,nonatomic) NSString *user_sign;
@property (strong,nonatomic) NSString *user_url;
@property (assign,nonatomic) int	   user_unReadNumber;
@property (assign,nonatomic) int	   user_hasread;  //0:unread  1: read
@property (strong,nonatomic) NSString *user_update_time;
@property (strong,nonatomic) NSString *user_photo_ids;
@property (strong,nonatomic) NSString *user_json;
@end

@interface notify_new_fans : LKModelBase
@property (assign,nonatomic) int user_id;
@property (assign,nonatomic) int user_hasBeingAdd;  //0:unadd  1: add
@property (strong,nonatomic) NSString *user_json;
@property (strong,nonatomic) NSString *user_new_time;
@end

@interface Message_activity : LKModelBase

@property (nonatomic,assign)    int	   zmessagetypeid;
@property (strong,nonatomic) NSString *ztitle;
@property (strong,nonatomic) NSString *zContent;
@property (strong,nonatomic) NSString *zPKID;
@property (assign,nonatomic) NSInteger zmessageHasread;  //0 unread  1 read
@property (strong,nonatomic) NSString *zmessagetype;
@property (strong,nonatomic) NSString *zphotourl;
@property (strong,nonatomic) NSString *zuserurl;
@property (strong,nonatomic) NSString *zdate;
@property (strong,nonatomic) NSString *zuser_json;
@property (strong,nonatomic) NSString *zpayload_json;
@property (strong,nonatomic) NSString *zother_json;

@property(assign,nonatomic) NSInteger privateMsgchildid;
@property(assign,nonatomic) NSInteger privateMsgunreadMessages;
@property(strong,nonatomic)NSString   *privateMsg_screent_name;
@property(strong,nonatomic)NSString   *privateMsgSendUrl;
@property(strong,nonatomic)NSString   *privateMsgLastMessageText;
- (id)initWithJsonDictionary_privateMsg:(NSDictionary*)dic;
@end


/* 商圈列表 父级分类*/
@interface DomainInfoRecomment : LKModelBase

@property (assign,nonatomic) NSInteger	area_id;
@property (assign,nonatomic) NSInteger  type;
@property (assign,nonatomic) NSInteger  scene_total_num;
@property (assign,nonatomic) NSInteger	address_lat;
@property (assign,nonatomic) NSInteger	address_lng;
@property (strong,nonatomic) NSString	*area_name;
@property (strong,nonatomic) NSString	*description;
@property (strong,nonatomic) NSString	*photoUrl;
-(id)initWithJSONObject:(NSDictionary*)data;
@end

/*推荐的现场列表*/
@interface RecommentChildScenes : LKModelBase

@property (assign,nonatomic) NSInteger	area_paretID;     //商圈ID
@property (assign,nonatomic) NSInteger	sceneID;		  //推荐现场ID
@property (assign,nonatomic) NSInteger	address_lat;
@property (assign,nonatomic) NSInteger	address_lng;
@property (strong,nonatomic) NSString	*scene_name;
@property (strong,nonatomic) NSString	*scene_description;
@property (strong,nonatomic) NSString	*showcase_image;
@property (assign,nonatomic) NSInteger	hasread;
@property (strong,nonatomic) NSString	*scense_json;
@property (strong,nonatomic) NSString	*recommentDate;
-(id)initWithJSONObject:(NSDictionary*)data;

@end

// 收藏现场
@interface UserFaviScenes : LKModelBase

@property (assign,nonatomic) NSInteger	sceneID;		  //收藏现场ID
@property (assign,nonatomic) NSInteger	address_lat;
@property (assign,nonatomic) NSInteger	address_lng;
@property (strong,nonatomic) NSString	*scene_name;
@property (strong,nonatomic) NSString	*scene_description;
@property (strong,nonatomic) NSString	*showcase_image;
@property (strong,nonatomic) NSString	*scense_json;
@property (strong,nonatomic) NSString	*add_timeDate;
-(id)initWithJSONObject:(NSDictionary*)data;

@end

// 推荐好友
@interface Recomment_Friend : LKModelBase
@property (assign,nonatomic) int user_id;
@property (assign,nonatomic) int user_hasread;  //0:unread  1: read
@property (assign,nonatomic) int user_hasBeingAdd;  //0:unadd 1:added
@property (strong,nonatomic) NSString *user_update_time;
@property (strong,nonatomic) NSString *user_json;
@end

