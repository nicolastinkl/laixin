//
//  UserInfo.m
//  try
//
//  Created by JIJIA &&&&& apple on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"
#import "tools.h"
#import "TalkData.h"

@implementation UserInfo
@synthesize user_id;
@synthesize user_name;
@synthesize user_pic;
@synthesize user_pic_small;
@synthesize sex;
@synthesize birthday;
@synthesize marriage;

-(id)initWithJSONObject:(NSDictionary*)one
{
	/*"user_id":"3197",
	 "user_name":"杰红",
	 "sex":1,
	 "marriage":"50",
	 "birthday":"1990-12-12",
	 "user_pic":"http://livep-piccache.stor.sinaapp.com/7adf34ddd400dd29f6f7924a906cdf25",
	 "user_pic_small":"http://livep-piccache.stor.sinaapp.com/9083acecbacb1362ac1b4c95d217f68d",
	 "user_pic_src":"http://livep-piccache.stor.sinaapp.com/b5a21ceedb018a64476f467bc042fb51",
	 "follow_num":69,
	 "followby_num":46,
	 "profile":"i fuck"*/ 
	self=[super init];
	if(self)
	{
		@try {
		if (![[one valueForKeyPath:@"user_id"] isKindOfClass:[NSNull class]]) {
			self.user_id=[[one valueForKeyPath:@"user_id"] intValue];
		}
		
		if (![[one valueForKeyPath:@"user_name"] isKindOfClass:[NSNull class]]) {
			self.user_name=[one valueForKeyPath:@"user_name"];
		} 
		
		/* 
		 "user_pic_src" = "http://livep-photobarn.stor.sinaapp.com/3be3cf0ebfb6ab266dba1905a2c040719ac84944";
		 */
		if (![[one valueForKeyPath:@"user_pic_external"] isKindOfClass:[NSNull class]]) {  //是否外链图片
			if ([[one  valueForKeyPath:@"user_pic_external"] boolValue]) {  //如果外链
				if ([one valueForKeyPath:@"user_pic"]) {
					self.user_pic=[tools UrlFromString:[one valueForKeyPath:@"user_pic"]];
				}
				if ([one valueForKeyPath:@"user_pic_small"]) {
					self.user_pic_small=[tools UrlFromString:[one valueForKeyPath:@"user_pic_small"]];
				}
			}else{
				if (![[one valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
					self.user_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[one valueForKeyPath:@"user_pic_src"] lengDp:180 status:@"m" ]];
					self.user_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[one valueForKeyPath:@"user_pic_src"] lengDp:180 status:@"s" ]];
				}
			}
		}
		
		if (![[one valueForKeyPath:@"sex"] isKindOfClass:[NSNull class]]) {
			self.sex=[[one valueForKeyPath:@"sex"] intValue];
		}
		if (![[one valueForKeyPath:@"marriage"] isKindOfClass:[NSNull class]]) {
				self.marriage=[[one valueForKeyPath:@"marriage"] intValue];
		}
		
		if(![[one valueForKeyPath:@"birthday"] isKindOfClass:[NSNull class]])
			self.birthday=[[tools serverShortDateFormat] dateFromString:[one valueForKeyPath:@"birthday"]];
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return self;
}
@end

@implementation User_Piclog
@synthesize comments,address,likes,reply_count,rowindex,small_url,time,url,small_url_Most,sender_id,talkdataMain;
-(id)initWithJSONObject:(NSDictionary*)data
{
	self=[super init];
	if(self)
	{
		@try {
			{
				//名称
				NSDictionary * sceneDic = [data valueForKeyPath:@"scene"];
				if (![[sceneDic valueForKeyPath:@"name"] isKindOfClass:[NSNull class]]) {
					self.address=[sceneDic valueForKeyPath:@"name"];
				}
				self.sender_id = [[sceneDic valueForKeyPath:@"id"] intValue];
			}
			
			{
				//图片信息
				NSDictionary * postDic = [data valueForKeyPath:@"post"];
				if (postDic) {
					TalkData * datasss = [[TalkData alloc] init];
					[datasss setData:postDic];
					self.talkdataMain = datasss;
					
					
					if (![[postDic valueForKeyPath:@"id"] isKindOfClass:[NSNull class]]) {
						self.rowindex=[[tools numberFromObject:[postDic valueForKeyPath:@"id"]] unsignedLongLongValue];
					}
					
					if (![[postDic valueForKeyPath:@"time"] isKindOfClass:[NSNull class]]) {
						
						NSString * tempstr = [postDic valueForKeyPath:@"time"];
						if([tempstr isKindOfClass:[NSString class]])
							self.time=[[tools serverDateFormat] dateFromString:tempstr];
					}
					
					
					NSDictionary * imageDic = [postDic valueForKeyPath:@"image"];
					if (imageDic) {
						if (![[imageDic valueForKeyPath:@"url_external"] isKindOfClass:[NSNull class]]) {  //是否外链图片
							BOOL url_external = [[imageDic valueForKeyPath:@"url_external"]  boolValue];
							if (url_external) {
								if (![[imageDic valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
									//self.url=[data valueForKeyPath:@"url"];
									self.url=[imageDic valueForKeyPath:@"url"];
									self.small_url=[imageDic valueForKeyPath:@"url"];
									self.small_url_Most=[imageDic valueForKeyPath:@"url"];
								}
							}else{
								if (![[imageDic valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
									//self.url=[data valueForKeyPath:@"url"];
									self.url=[tools ReturnNewURLBySize:[imageDic valueForKeyPath:@"url"] lengDp:720 status:@"b" ];
									self.small_url=[tools ReturnNewURLBySize:[imageDic valueForKeyPath:@"url"] lengDp:180 status:@"m"];
									self.small_url_Most=[tools ReturnNewURLBySize:[imageDic valueForKeyPath:@"url"] lengDp:180 status:@"s"];
								}
							}
						}
					}
					
				}
			}
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
		
	return self;
}

@end


@implementation FollowUserInfo
+(FollowUserInfo*) infoWithDictionary:(NSDictionary*)obj
{
	return [[FollowUserInfo alloc] initWithDictionary:obj];
}
@synthesize isFollowed;
@synthesize profile;
@synthesize isgoodFriend;
-(id)initWithDictionary:(NSDictionary*)obj
{
	self=[super initWithJSONObject:obj];
	if(self)
	{
		@try {
		if (![[obj valueForKeyPath:@"user_id"] isKindOfClass:[NSNull class]]) {
			self.user_id=[[obj valueForKeyPath:@"user_id"] unsignedIntegerValue];
		}
		
		
		if (![[obj valueForKeyPath:@"user_name"] isKindOfClass:[NSNull class]]) {
			self.user_name=[obj valueForKeyPath:@"user_name"];
		}
		
		//		if (![[obj valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
		//			self.user_pic=[tools UrlFromString:[obj valueForKeyPath:@"user_pic"]];
		//		}
		//
		//		if (![[obj valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
		//			self.user_pic_small=[tools UrlFromString:[obj valueForKeyPath:@"user_pic_small"]];
		//		}
		
		
		if (![[obj valueForKeyPath:@"profile"] isKindOfClass:[NSNull class]]) {
			self.profile=[obj valueForKeyPath:@"profile"];
		}
		if (![[obj valueForKeyPath:@"myfollow"] isKindOfClass:[NSNull class]]) {
			self.isFollowed=[[obj valueForKeyPath:@"myfollow"] boolValue];
		}
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}

		
	}
	return self;
}
@end


@implementation DirectMessageInfo
@synthesize rowid,sender_id,sender_screen_name,created_at,messagetext,recipient_id,sender_profile_image_url;

-(NSComparisonResult) compare:(DirectMessageInfo*)other
{
	return -1;
}


@end

@implementation UserInfo_default

@synthesize avatar_external_BOL,background_external_BOL,birthday,is_follower,user_active,user_avatar_image,user_background_image,user_followers_num,user_friends_num,user_gender,user_id,user_marriage,user_name,user_profile,background_image,user_age,user_astro,user_height,user_desInfo,user_avatar_image_big,auth_type,auth_id,can_invite;


-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {

			self.auth_id=[[oneinvite valueForKeyPath:@"auth_id"] unsignedLongLongValue];
			self.can_invite=[[oneinvite valueForKeyPath:@"can_invite"] boolValue];
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"auth_type"]]) {
				self.auth_type=[oneinvite valueForKeyPath:@"auth_type"];
			}

			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"id"]]) {
				self.user_id=[[oneinvite valueForKeyPath:@"id"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"followers_count"]]) {
				self.user_followers_num=[[oneinvite valueForKeyPath:@"followers_count"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"friends_count"]]) {
				self.user_friends_num=[[oneinvite valueForKeyPath:@"friends_count"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"gender"]]) {
				self.user_gender=[[oneinvite valueForKeyPath:@"gender"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"marriage"]]) {
				self.user_marriage=[[oneinvite valueForKeyPath:@"marriage"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"avatar_external"]]) {
				self.avatar_external_BOL=[[oneinvite valueForKeyPath:@"avatar_external"] boolValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"background_external"]]) {
				self.background_external_BOL=[[oneinvite valueForKeyPath:@"background_external"] boolValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"is_follower"]]) {
				self.is_follower=[[oneinvite valueForKeyPath:@"is_follower"] boolValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"active"]]) {
				self.user_active=[[oneinvite valueForKeyPath:@"active"] boolValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"birthday"]]) {
				self.birthday=[[tools serverShortDateFormat] dateFromString:[oneinvite valueForKeyPath:@"birthday"]];
			}
			self.user_avatar_image_big = [oneinvite valueForKeyPath:@"avatar"];
			self.user_avatar_image = [oneinvite valueForKeyPath:@"avatar"];
			if (!self.avatar_external_BOL)
			{
				if (self.user_avatar_image) {
					self.user_avatar_image = [tools ReturnNewURLBySize:self.user_avatar_image lengDp:320 status:@"m"];
				}
			}
			self.background_image = [oneinvite valueForKeyPath:@"background_image"];
			self.background_image = [tools ReturnNewURLBySize:self.background_image lengDp:480 status:@"m"];
			if (self.user_id == 1000001) {
				//生活圈小助手
				self.user_avatar_image = [oneinvite valueForKeyPath:@"avatar"];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"background"]]) {
				self.user_background_image = [oneinvite valueForKeyPath:@"background"];
			}
			if (![self isKindOfClassOfJson:[oneinvite objectForKey:@"name"]]) {
				self.user_name = [oneinvite valueForKeyPath:@"name"];
			}
			if (!self.user_name) {
				self.user_name = [oneinvite valueForKeyPath:@"screen_name"];	
			}
            
            
            if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"signature"]]) {
				self.user_profile = [oneinvite valueForKeyPath:@"signature"];
                if (self.user_profile == nil) {
                    self.user_profile = @"";
                }
			}else{
                self.user_profile = @"";
            }
			
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"astro"]]) {
				self.user_astro=[oneinvite valueForKeyPath:@"astro"];
			}
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"height"]]) {
				self.user_height=[[oneinvite valueForKeyPath:@"height"] intValue];
			}
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"age"]]) {
				self.user_age=[oneinvite valueForKeyPath:@"age"];
			}
			int i = arc4random() % 10+20;
			if ([self.user_age isKindOfClass:[NSNull class]] || self.user_age == nil) {
				self.user_age = [NSString stringWithFormat:@"%d",i];
			}
			if (self.user_age) {
				if ([self.user_age intValue] < 20) {
					self.user_age = [NSString stringWithFormat:@"%d",i];
				}
			}
			if (self.user_height < 170) {
				if (self.user_gender == 1) {
					self.user_height = arc4random() % 25 + 165;
				}else{
					self.user_height = arc4random() % 18 + 160;
				}
			}
			if ([self.user_astro isKindOfClass:[NSNull class]] || self.user_astro == nil) {
				self.user_astro = @"处女座";
			}
			
			self.user_desInfo = [NSString  stringWithFormat:@" %@ %@ %@ %dcm",self.user_gender == 1?@"男":@"女",self.user_age,self.user_astro,self.user_height];
		}
		@catch (NSException *exception) {
			
		}
		@finally {
			
		}
	}
	return self;
}

@end

@implementation SenceUserinfo
@synthesize Scene_user_has_post,Scene_user_join_count,Scene_user_join_time,Scene_user_rank,Scene_user_role_id,Scene_user_role_name,userinfo;
-(id)initWithDictionary:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"join_count"]]) {
				self.Scene_user_join_count=[[oneinvite valueForKeyPath:@"join_count"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"role_id"]]) {
				self.Scene_user_role_id=[[oneinvite valueForKeyPath:@"role_id"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"has_post"]]) {
				self.Scene_user_has_post=[[oneinvite valueForKeyPath:@"has_post"] intValue];
			}
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"join_time"]]) {
				NSString * time = [oneinvite valueForKeyPath:@"join_time"];
				self.Scene_user_join_time = [tools datebyStr:time]; 
			}
			if (!self.Scene_user_join_time) {
				if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"time"]]) {
					NSString * time = [oneinvite valueForKeyPath:@"time"];
					self.Scene_user_join_time = [tools datebyStr:time];
				}
			}
			
			self.Scene_user_role_name = [oneinvite valueForKeyPath:@"role_name"];
			self.Scene_user_rank = [oneinvite valueForKeyPath:@"rank"];
			NSDictionary * userinfoDic =[oneinvite valueForKeyPath:@"user"];
			if (userinfoDic) {
				UserInfo_default * userinfo_now = [[UserInfo_default alloc] initWithJSONObject:userinfoDic];
				self.userinfo = userinfo_now;
			}
		}
		@catch (NSException *exception) {
							
		}
		@finally {
			
		}
	}
	return self;
}

@end



