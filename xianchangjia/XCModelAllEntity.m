//
//  XCModelAllEntity.m
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-9.
//
//

#import "XCModelAllEntity.h"
#import "tools.h"

@implementation XCModelAllEntity

@end


@implementation Message_private_user
@synthesize msgUUID,msgStutas,created_at,text,recipient_id,sender_id,sender_profile_image_url,sender_screen_name,msgType;
-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"msgUUID";
	}
	return  self;
}

- (id)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [self init];
	if (self) {
		self.recipient_id = [[dic valueForKey:@"recipient_id"] intValue];
		self.sender_id = [[dic valueForKey:@"sender_id"] intValue];
		self.sender_profile_image_url = [dic valueForKey:@"sender_profile_image_url"];
		self.text = [dic valueForKey:@"text"];
		self.sender_screen_name = [dic valueForKey:@"sender_screen_name"];
		self.created_at = [dic valueForKey:@"created_at"];
		self.msgUUID = [dic valueForKey:@"msgUUID"];
		if (![[dic valueForKey:@"msgStutas"] isKindOfClass:[NSNull class]]) {
			self.msgStutas = [[dic valueForKey:@"msgStutas"] intValue];
		}else{
			self.msgStutas = 0;
		}
		if (![[dic valueForKey:@"msgType"] isKindOfClass:[NSNull class]]) {
			self.msgType = [[dic valueForKey:@"msgType"] intValue];
		}else{
			self.msgType = 0;
		}
		
		//[tools datebyStr:[dic valueForKey:@"created_at"]]
	}
	return self;
}

@end


@implementation Message_private_list
@synthesize created_at,sender_profile_image_url,childid,lastMessageText,message_screent_name,unreadMessages;
-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"childid";
	}
	return  self;
}

@end


@implementation Message_music_check
@synthesize address,check_time,scene_id;

-(id)init
{
self = [super init];
if(self)
{
	self.primaryKey = @"rowid";
}
return  self;
}

@end

@implementation Message_Comment_postInfo
@synthesize  comment_id,to_post_id,readStatus,comment_json;
-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"comment_id";
	}
	return  self;
}
@end

@implementation Message_Comment_unread
@synthesize comment_unread_id,comment_unread_number,comment_unread_sign,comment_unread_type;
-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"comment_unread_id";
	}
	return  self;
}

@end

@implementation Message_type_Music
@synthesize type,typeName,unreadNumber;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"rowid";
	}
	return  self;
}

@end

@implementation Friend_New_statuss_all
@synthesize user_hasread,user_id,user_json,user_unReadNumber,user_update_time,user_photo_ids,user_name,user_sign,user_url;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"user_id";
	}
	return  self;
}

@end

@implementation notify_new_fans

@synthesize user_id,user_json,user_new_time,user_hasBeingAdd;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"user_id";
	}
	return  self;
}
@end


@implementation Message_activity

@synthesize zdate,zmessagetype,zmessagetypeid,zother_json,zpayload_json,zphotourl,ztitle,zuser_json,zuserurl,privateMsgchildid,privateMsg_screent_name,privateMsgLastMessageText,privateMsgSendUrl,privateMsgunreadMessages,zContent,zPKID,zmessageHasread;
-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"zPKID";
	}
	return  self;
}

//- (id)copyWithZone:(NSZone *)zone
//{
//	Message_activity *copy = [[[self class] allocWithZone:zone] init];
//	copy->zPKID = [self.zPKID mutableCopy];
//	return copy;
//}


- (id)initWithJsonDictionary_privateMsg:(NSDictionary*)dic
{	
	self = [self init];
	if (self) {
		self.privateMsgchildid = [[dic valueForKey:@"sender_id"] intValue];
		self.privateMsgSendUrl = [dic valueForKey:@"sender_profile_image_url"];
		self.privateMsgLastMessageText = [dic valueForKey:@"text"];
		self.privateMsg_screent_name = [dic valueForKey:@"sender_screen_name"];
//		NSDate * date = [tools datebyStr:[dic valueForKey:@"created_at"]];
//		NSDate * utcdate = [tools convertToUTC:date];
//		self.zdate = [tools StringForDate:utcdate];
		self.zdate = [dic valueForKey:@"created_at"];
	}
	return self;
}

@end

@implementation DomainInfoRecomment

@synthesize address_lat,address_lng,area_id,area_name,description,scene_total_num,type,photoUrl;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"area_id";
	}
	return  self;
}

-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[self init];
	if(self)
	{
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"id"]]) {
			self.area_id=[[oneinvite valueForKeyPath:@"id"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"scene_total_num"]]) {
			self.scene_total_num=[[oneinvite valueForKeyPath:@"scene_total_num"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lng"]]) {
			self.address_lng=[[oneinvite valueForKeyPath:@"address_lng"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lat"]]) {
			self.address_lat=[[oneinvite valueForKeyPath:@"address_lat"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"name"]]) {
			self.area_name=[oneinvite valueForKeyPath:@"name"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"description"]]) {
			self.description=[oneinvite valueForKeyPath:@"description"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"type"]]) {
			self.type=[[oneinvite valueForKeyPath:@"type"] intValue];
		}		 
	}
	return  self;
} 

@end

@implementation RecommentChildScenes

@synthesize scense_json,hasread,area_paretID,address_lng,address_lat,scene_description,scene_name,sceneID,showcase_image,recommentDate;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"sceneID";
	}
	return  self;
}

-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[self init];
	if(self)
	{
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"id"]]) {
			self.sceneID=[[oneinvite valueForKeyPath:@"id"] intValue];
		} 
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lng"]]) {
			self.address_lng=[[oneinvite valueForKeyPath:@"address_lng"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lat"]]) {
			self.address_lat=[[oneinvite valueForKeyPath:@"address_lat"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"name"]]) {
			self.scene_name=[oneinvite valueForKeyPath:@"name"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"description"]]) {
			self.scene_description=[oneinvite valueForKeyPath:@"description"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"showcase_image"]]) {
			self.showcase_image = [tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"showcase_image"] lengDp:480 status:@""];
		}
		self.recommentDate = [tools fixStringForDate:[NSDate date]];
	}
	return  self;
}
@end

@implementation UserFaviScenes

@synthesize scense_json,address_lng,address_lat,scene_description,scene_name,sceneID,showcase_image,add_timeDate;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"sceneID";
	}
	return  self;
}

-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[self init];
	if(self)
	{
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"id"]]) {
			self.sceneID=[[oneinvite valueForKeyPath:@"id"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lng"]]) {
			self.address_lng=[[oneinvite valueForKeyPath:@"address_lng"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"address_lat"]]) {
			self.address_lat=[[oneinvite valueForKeyPath:@"address_lat"] intValue];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"name"]]) {
			self.scene_name=[oneinvite valueForKeyPath:@"name"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"description"]]) {
			self.scene_description=[oneinvite valueForKeyPath:@"description"];
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"showcase_image"]]) {
			self.showcase_image = [tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"showcase_image"] lengDp:480 status:@""];
		}
		 
	}
	return  self;
}

@end

@implementation Recomment_Friend

@synthesize user_hasread,user_id,user_json,user_update_time,user_hasBeingAdd;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.primaryKey = @"user_id";
	}
	return  self;
} 

@end