//
//  InviteInfo.m
//  try
//
//  Created by JIJIA &&&&& amen on 11-7-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "InviteInfo.h"
#import "GlobalData.h"
#import "tools.h"
#import "UserInfo.h"

@implementation InviteInfoData
@synthesize endtime;
@synthesize certification;
@synthesize active;
@synthesize coupon_count;
@synthesize recent_talk;
@synthesize subinvites;
@synthesize subinvitecount;
@synthesize join_count;
@synthesize hasdevice;
@synthesize star;
@synthesize credit;
@synthesize time_proposal;
@synthesize members;
@synthesize isfavorite,area_name;
@synthesize index;
@synthesize scene_cover_image;
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	/*"scene_id":18048,
	 "parent":18047,
	 "scene_picture":null,
	 "time":null,
	 "address":"绿茶餐厅(世茂工三店)",
	 "address_lat":39932337,
	 "address_lng":116442165,
	 "distance":1875.1542088,
	 "creator_word":"nihao你好好好！",
	 "endtime":null,
	 "area_name":"世茂百货",
	 "hasdevice":false,
	 index
	 "members":[],
	 "recent_talk":[],
	 "star":[]
	 
	 "scene_cover_image"  现场图片*/
    self=[super initWithJSONObject:oneinvite];
	
	@try {
		NSString *tempstr=[oneinvite valueForKeyPath:@"endtime"];
		if([tempstr isKindOfClass:[NSString class]])
			self.endtime=[[tools serverDateFormat] dateFromString:tempstr];
		self.certification=[[oneinvite valueForKeyPath:@"certification"] boolValue];
		self.active=[[oneinvite valueForKeyPath:@"active"] boolValue];
		self.coupon_count=[[oneinvite valueForKeyPath:@"coupon_count"] integerValue];
		self.join_count = [[oneinvite valueForKeyPath:@"join_count"] integerValue];
		self.hasdevice = [[oneinvite valueForKeyPath:@"hasdevice"] boolValue];
		self.credit = [[oneinvite valueForKeyPath:@"credit"] integerValue];   //...
		self.time_proposal = [[oneinvite valueForKeyPath:@"time_proposal"] integerValue];   //...
		self.index = [oneinvite valueForKeyPath:@"index"];   //...
		self.isfavorite = [[oneinvite valueForKeyPath:@"isfavorite"] boolValue];
		self.area_name = [oneinvite valueForKeyPath:@"area_name"];
		
		if (![[oneinvite valueForKeyPath:@"scene_cover_image"] isKindOfClass:[NSNull class]]) {
			self.scene_cover_image = [oneinvite valueForKeyPath:@"scene_cover_image"];

//			self.scene_cover_image=[tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"scene_cover_image"] lengDp:960 status:@"b"];
//			NSLog(@"%@",self.scene_cover_image);
		}
		 
		self.subinvitecount=[[oneinvite valueForKeyPath:@"subinvitecount"] intValue];
		
		if (![[oneinvite valueForKeyPath:@"subinvites"] isKindOfClass:[NSNull class]]) {
			NSArray *subinvitelist=[oneinvite valueForKeyPath:@"subinvites"];
			if([subinvitelist count]>0)
			{
				NSMutableArray *templist=[NSMutableArray array];
				for(NSDictionary *oneinvite in subinvitelist)
				{
					SubInviteInfo *subinfo=[[SubInviteInfo alloc] initWithJSONObject:oneinvite];
					[templist addObject:subinfo];
				}
				self.subinvites=templist;
			}
		}
		
		if (![[oneinvite valueForKeyPath:@"star"] isKindOfClass:[NSNull class]]) {
			
			NSArray* star_list=[oneinvite valueForKeyPath:@"star"];
			NSMutableArray *temparray=[NSMutableArray array];
			for (NSDictionary *data in star_list) {
				if ([data isKindOfClass:[NSDictionary class]]) {
					UserInfo *info=[[UserInfo alloc] initWithJSONObject:data];
					[temparray addObject:info];
				}
			}
			self.star=temparray;
		}
		
		/*获取当前现场的人员*/
		if (![[oneinvite valueForKeyPath:@"members"] isKindOfClass:[NSNull class]]) {
			NSArray* members_list=[oneinvite valueForKeyPath:@"members"];
			NSMutableArray *memberArray=[NSMutableArray array];
			for (NSDictionary *data in members_list) {
				if ([data isKindOfClass:[NSDictionary class]]) {
					InviteMemberInfo *info=[[InviteMemberInfo alloc] initWithJSONObject:data];
					if (info.user_id != [[[NSUserDefaults standardUserDefaults] valueForKeyPath:GlobalData_user_id] integerValue]) {
						[memberArray addObject:info];
					}
					
				}
			}
			self.members=memberArray;
		}
	}
	@catch (NSException *exception) {
		NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
	}
	@finally {
		
	}
	
    return self;
}

-(BOOL) isMemberLeave:(MemberInfo*) member
{
    return 0;//[tools getMemberState:self.time endtime:self.endtime jointime:member.add_time]==memberstete_leave;
}
-(BOOL) updateDistanse
{
	[super updateDistanse];
	if([self.subinvites count]>0)
	{
		for (SubInviteInfo *info in self.subinvites) {
			[info updateDistanse];
		}
	}
    return YES;
}
-(NSComparisonResult) compare:(InviteInfoData*) other
{
	if(self.certification && !other.certification)
		return -1;
	else if(!self.certification && other.certification)
		return 1;
	if(self.invite_id>other.invite_id)
		return -1;
	if(self.invite_id<other.invite_id)
		return 1;
	return 0;
	if(self.distanse>other.distanse)
        return 1;
    else if(self.distanse<other.distanse)
        return -1;
    else
        return 0;
}
-(NSComparisonResult) compareDesc:(InviteInfoData*) other
{
	return -[self compare:other];
}
@end
@implementation InviteLog
@synthesize user_id;
@synthesize user_name;
@synthesize user_pic;
@synthesize user_pic_small;
@synthesize message;
@synthesize time;
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if(self==nil)
		return nil;
	
	@try {
		 
	self.user_id=[[oneinvite valueForKeyPath:@"user_id"]intValue];
	self.user_name=[oneinvite valueForKeyPath:@"user_name"];
//	self.user_pic=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic"]];
//	self.user_pic_small=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic_small"]];
	
	
	if (![[oneinvite valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
		self.user_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"m" ]];
		self.user_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"s" ]];
	}
	
	self.message=[oneinvite valueForKeyPath:@"message"];
	NSString *tempstr =[oneinvite valueForKeyPath:@"time"];
    if([tempstr isKindOfClass:[NSString class]])
        self.time=[[tools serverDateFormat] dateFromString:tempstr];
		
	}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	return self;
}
@end

@implementation SubInviteInfo
@synthesize invite_id;
@synthesize parent;
@synthesize creator_id;
@synthesize user_name;
@synthesize time;
@synthesize user_pic;
@synthesize user_pic_small;
@synthesize address;
@synthesize address_lat;
@synthesize address_lng;
@synthesize creator_word;
//@synthesize members;
@synthesize distanse;
@synthesize isfollowcreator;
@synthesize follow_count;
@synthesize invite_picture;
@synthesize runingdata=_runingdata;

-(NSMutableDictionary *)runingdata
{
	if(_runingdata==nil)
		_runingdata=[NSMutableDictionary new];
	return _runingdata;
}
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if(self==nil)
		return nil;
	
	@try {
		
		if (![[oneinvite valueForKeyPath:@"scene_id"] isKindOfClass:[NSNull class]]) {
			self.invite_id=[[oneinvite valueForKeyPath:@"scene_id"] intValue]; //new
		}else{
			if (![[oneinvite valueForKeyPath:@"invite_id"] isKindOfClass:[NSNull class]]) {
				self.invite_id=[[oneinvite valueForKeyPath:@"invite_id"] intValue]; // old
			}
		}
		
		self.parent=[[oneinvite valueForKeyPath:@"parent"] intValue];
		//	self.creator_id=[[oneinvite valueForKeyPath:@"creator_id"] intValue];
		self.user_name=[oneinvite valueForKeyPath:@"user_name"];
		NSString *tempstr =[oneinvite valueForKeyPath:@"time"];
		if (tempstr) {
			if([tempstr isKindOfClass:[NSString class]])
				self.time=[[tools serverDateFormat] dateFromString:tempstr];
		}
		
//		if (![[oneinvite valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
//			self.user_pic=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic"]];
//		}
//		
//		if (![[oneinvite valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
//			self.user_pic_small=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic_small"]];
//		}
		
		
		if (![[oneinvite valueForKeyPath:@"user_pic_external"] isKindOfClass:[NSNull class]]) {  //是否外链图片
			if ([[oneinvite  valueForKeyPath:@"user_pic_external"] boolValue]) {  //如果外链
				if (![[oneinvite valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
					self.user_pic=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic"]];
				}
				if (![[oneinvite valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
					self.user_pic_small=[tools UrlFromString:[oneinvite valueForKeyPath:@"user_pic_small"]];
				}
			}else{
				if (![[oneinvite valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
					self.user_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"m" ]];
					self.user_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"s" ]];
				}
			}
		}
		 
		if (![[oneinvite valueForKeyPath:@"address"] isKindOfClass:[NSNull class]]) {
			self.address=[oneinvite valueForKeyPath:@"address"];
		}
		if (![[oneinvite valueForKeyPath:@"address_lat"] isKindOfClass:[NSNull class]]) {
			self.address_lat=[[oneinvite valueForKeyPath:@"address_lat"] integerValue];
		}
		if (![[oneinvite valueForKeyPath:@"address_lng"] isKindOfClass:[NSNull class]]) {
			self.address_lng=[[oneinvite valueForKeyPath:@"address_lng"] integerValue];
		}
		if (![[oneinvite valueForKeyPath:@"creator_word"] isKindOfClass:[NSNull class]]) {
			self.creator_word=[oneinvite valueForKeyPath:@"creator_word"];
		}
		 
		self.isfollowcreator=[[oneinvite valueForKeyPath:@"follow_creator"] boolValue];
		self.follow_count=[[oneinvite valueForKeyPath:@"follow_count"] integerValue];
		if (![[oneinvite valueForKeyPath:@"invite_picture"] isKindOfClass:[NSNull class]]) {
			self.invite_picture=[tools UrlFromString:[oneinvite valueForKeyPath:@"invite_picture"]];
			
		}
	}
	@catch (NSException *exception) {
		NSLog(@"exception:%@",exception.reason);
	}
	@finally {
		
	}

//	NSArray *membersinfo=[oneinvite valueForKeyPath:@"members"];
//    if(membersinfo.count>0)
//    {
//        NSMutableArray *templist=[NSMutableArray array];
//        for(NSDictionary *onemember in membersinfo)
//        {
//			MemberInfo *info=[[MemberInfo alloc] initWithJSONObject:onemember];
//            [templist addObject:info];
//        }
//		self.members=templist;
//    }
	//InviteMemberInfo
	
	return self;
}
-(BOOL) updateDistanse
{
//    distanse=-1;
//    if(address_lat==0 || address_lng==0)
//        return NO;
//    CLLocation* nowlocation=[GlobalData getInstanse].nowlocation;
//    if(nowlocation==nil)
//        return NO;
//    CLLocation *inviteloc=[[CLLocation alloc] initWithLatitude:((double)address_lat/1e6) longitude:((double)address_lng/1e6)];
//    distanse=[inviteloc distanceFromLocation:nowlocation];
    return YES;
}

-(CLLocation*) getLocation
{
	return [[CLLocation alloc] initWithLatitude:(((double)self.address_lat)/1e6) longitude:(((double)self.address_lng)/1e6) ];
}
@end

@implementation MemberInfo
@synthesize user_id;
@synthesize user_name;
@synthesize add_time;
@synthesize user_pic;
@synthesize user_pic_small;
@synthesize isFollow;
-(id) initWithJSONObject:(NSDictionary*) onemember
{
	self=[super init];
	if(self)
	{
		@try {
		self.user_id=[[onemember valueForKeyPath:@"user_id"] integerValue];
		self.user_name=[onemember valueForKeyPath:@"user_name"];
		if (![[onemember valueForKeyPath:@"addtime"] isKindOfClass:[NSNull class]]) {
			self.add_time=[[tools serverDateFormat] dateFromString:[onemember valueForKeyPath:@"addtime"]];
		} 
		
//		if (![[onemember valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
//			self.user_pic=[tools UrlFromString:[onemember valueForKeyPath:@"user_pic"]];
//		}
//		
//		if (![[onemember valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
//			self.user_pic_small=[tools UrlFromString:[onemember valueForKeyPath:@"user_pic_small"]];
//		}
		
		
		
		if (![[onemember valueForKeyPath:@"user_pic_external"] isKindOfClass:[NSNull class]]) {  //是否外链图片
			if ([[onemember  valueForKeyPath:@"user_pic_external"] boolValue]) {  //如果外链
				if (![[onemember valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
					self.user_pic=[tools UrlFromString:[onemember valueForKeyPath:@"user_pic"]];
					
				}
				if (![[onemember valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
					self.user_pic_small=[tools UrlFromString:[onemember valueForKeyPath:@"user_pic_small"]];
					
				}
			}else{
				if (![[onemember valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
					self.user_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[onemember valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"m" ]];
					self.user_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[onemember valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"s" ]];
				}
			}
		}
		
		
		
		
		self.isFollow=[[onemember valueForKeyPath:@"isfollow"] boolValue];
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}

	}
	return self;
}
@end
 
@implementation JoinInviteInfoData
@synthesize invite_id;
@synthesize joined;
@synthesize jointime;
@synthesize location;
@synthesize address;
@synthesize certification;
@synthesize jointype;
@synthesize SoundWaveData;

-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
    self=[super init];
    if(self)
    {
		@try {
		self.invite_id=[[oneinvite valueForKeyPath:@"invite_id"] integerValue];
        self.joined=[[oneinvite valueForKeyPath:@"joined"] boolValue];
		self.jointime=[NSDate date];
		int lat=[[oneinvite valueForKeyPath:@"lat"] intValue];
		int lng=[[oneinvite valueForKeyPath:@"lng"] intValue];
		self.location=[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)lat/1e6 longitude:(CLLocationDegrees)lng/1e6];
		self.address=[oneinvite valueForKeyPath:@"address"];
		self.certification=[[oneinvite valueForKeyPath:@"certification"] intValue];
		self.jointype=[[oneinvite valueForKeyPath:@"jointype"]intValue];
	
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}

    }
    return self;
}
-(id) initWithWaitConfirmJoinData:(WaitConfirmJoinData*)data
{
	self=[super init];
    if(self)
	{
		self.invite_id=data.invite_id;
		self.joined=YES;
		self.jointime=[NSDate date];
		self.location=data.location;
	}
	return self;
}
@end


@implementation WaitConfirmJoinData
@synthesize invite_id;
@synthesize user_name;
@synthesize address;
@synthesize location;
@synthesize creator_word;
@synthesize distanse;
-(id) initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			
		self.invite_id=[[oneinvite valueForKeyPath:@"invite_id"] integerValue];
		self.user_name=[oneinvite valueForKeyPath:@"user_name"];
		self.address=[oneinvite valueForKeyPath:@"address"];
		NSInteger address_lat=[[oneinvite valueForKeyPath:@"address_lat"] integerValue];
		NSInteger address_lng=[[oneinvite valueForKeyPath:@"address_lng"] integerValue];
		self.location=[[CLLocation alloc] initWithLatitude:((double)address_lat/1e6) longitude:((double)address_lng/1e6)];
		self.creator_word=[oneinvite valueForKeyPath:@"creator_word"];
		
		self.distanse=-1;
//		CLLocation* nowlocation=[GlobalData getInstanse].nowlocation;
//		if(nowlocation)
//		{
//			self.distanse=[self.location distanceFromLocation:nowlocation];
//		}
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}

	}
	return self;
}
@end

@implementation InviteDetailInfo
@synthesize join_state;
@synthesize address_lat;
@synthesize address_lng;
@synthesize creator_id;
@synthesize creator_name;
@synthesize crearor_word;
@synthesize address_str;
@synthesize creator_pic;
@synthesize creator_pic_small;
@synthesize src_phone;
@synthesize src_title;
@synthesize time;
@synthesize endtime;
@synthesize coupon_count;
@synthesize certification;
@synthesize active;
@synthesize join_count;
@synthesize isfavorite;
@synthesize credit;
-(id)initWithJSONObject:(NSDictionary*)info
{
	self=[super init];
	if(self)
	{
		
		@try {

		self.address_str=[info valueForKeyPath:@"address"];
		self.crearor_word=[info valueForKeyPath:@"creator_word"];
        
        NSNumber *state=[info valueForKeyPath:@"state"];
        if(state)
			self.join_state=[state intValue];
        else
			self.join_state=-2;
        self.address_lat=[[info valueForKeyPath:@"address_lat"] intValue];
		self.address_lng=[[info valueForKeyPath:@"address_lng"] intValue];
        self.creator_id=[[info valueForKeyPath:@"creator_id"] intValue];
        self.creator_name=[info valueForKeyPath:@"user_name"];
//        self.creator_pic=[tools UrlFromString:[info valueForKeyPath:@"user_pic"]];
//        self.creator_pic_small=[tools UrlFromString:[info valueForKeyPath:@"user_pic_small"]];

		if (![[info valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
			self.creator_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[info valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"m" ]];
			self.creator_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[info valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"s" ]];
		}
		
		self.certification=[[info valueForKeyPath:@"certification"] boolValue];
		self.active=[[info valueForKeyPath:@"active"] boolValue];
		self.coupon_count=[[info valueForKeyPath:@"coupon_count"] integerValue];
		self.join_count = [[info valueForKeyPath:@"join_count"] integerValue];
		self.isfavorite =[[info valueForKeyPath:@"isfavorite"] boolValue];
        	self.credit = [[info valueForKeyPath:@"credit"] integerValue];   //...
        NSDictionary *src_info=[info valueForKeyPath:@"src_info"];
        if(src_info)
        {
            self.src_phone=[src_info valueForKeyPath:@"src_phone"];
            self.src_title=[src_info valueForKeyPath:@"src_title"];
        }
        
        NSString *tempstr;
        tempstr=[info valueForKeyPath:@"time"];
        if([tempstr isKindOfClass:[NSString class]])
            self.time=[[tools serverDateFormat] dateFromString:tempstr];
        tempstr=[info valueForKeyPath:@"endtime"];
        if ([tempstr isKindOfClass:[NSString class]])
            self.endtime=[[tools serverDateFormat] dateFromString:tempstr];
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return self;
}
-(CLLocation*) getLocation
{
	return [[CLLocation alloc] initWithLatitude:(((double)self.address_lat)/1e6) longitude:(((double)self.address_lng)/1e6) ];
}
@end


@implementation MessageInfo
@synthesize creator_pic,creator_pic_small,id_message,index_message,name,time,type;
-(id)initWithJSONObject:(NSDictionary*)info;
{
	self=[super init];
	if(self)
	{
		@try {
		self.index_message = [[info valueForKeyPath:@"index"] intValue];
		self.id_message = [[info valueForKeyPath:@"id"] intValue];
		self.name = [info valueForKeyPath:@"name"];
		self.time=[[tools serverDateFormat] dateFromString:[info valueForKeyPath:@"time"]];
//		self.creator_pic=[tools UrlFromString:[info valueForKeyPath:@"user_pic"]];
//		self.creator_pic_small=[tools UrlFromString:[info valueForKeyPath:@"user_pic_small"]];
		
		
		if (![[info valueForKeyPath:@"user_pic_external"] isKindOfClass:[NSNull class]]) {  //是否外链图片
			if ([[info  valueForKeyPath:@"user_pic_external"] boolValue]) {  //如果外链
				if (![[info valueForKeyPath:@"user_pic"] isKindOfClass:[NSNull class]]) {
					self.creator_pic=[tools UrlFromString:[info valueForKeyPath:@"user_pic"]];
					
				}
				if (![[info valueForKeyPath:@"user_pic_small"] isKindOfClass:[NSNull class]]) {
					self.creator_pic_small=[tools UrlFromString:[info valueForKeyPath:@"user_pic_small"]];
					
				}
			}else{
				if (![[info valueForKeyPath:@"user_pic_src"] isKindOfClass:[NSNull class]]) {
					self.creator_pic=[NSURL URLWithString:[tools ReturnNewURLBySize:[info valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"m" ]];
					self.creator_pic_small=[NSURL URLWithString:[tools ReturnNewURLBySize:[info valueForKeyPath:@"user_pic_src"] lengDp:480 status:@"s" ]];
				}
				
			}
		}
		
		self.type = [[info valueForKeyPath:@"type"] intValue];
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}

@end



@implementation InviteMemberInfo
@synthesize time;
@synthesize state;
@synthesize isleave;
@synthesize reqphone_count;
@synthesize profile;
@synthesize join_count,member_credits,member_role,member_role_id,rank;
@synthesize followby_num,follow_num,isFollow,user_bk_pic;

-(NSComparisonResult)compare:(InviteMemberInfo*)other
{
	if(self.isleave && !other.isleave)
		return 1;
	if(!self.isleave && other.isleave)
		return -1;
	if(self.reqphone_count>other.reqphone_count)
		return -1;
	else if(self.reqphone_count<other.reqphone_count)
		return 1;
	return 0;
}
-(id)initWithJSONObject:(NSDictionary*)one
{
	/*"user_id":3197,
	 "time":"2012-10-23 14:38:57",
	 "join_count":1,
	 "member_role":"",
	 "member_role_id":0,
	 "rank":0,
	 "member_credits":0,
	 "user_name":"杰红",
	 "sex":1,
	 "marriage":"50",
	 "birthday":"1990-12-12",
	 "user_pic":"",
	 "user_pic_small":"",
	 "user_pic_src":"",
	 "follow_num":69,
	 "followby_num":48,
	 "profile":"i fuck"*/
	self=[super initWithJSONObject:one];
	if(self)
	{
		@try {
		if ([one valueForKeyPath:@"time"]) {
			self.time=[[tools serverDateFormat] dateFromString:[one valueForKeyPath:@"time"]];			
		}

		self.profile=[one valueForKeyPath:@"profile"];
		
		//time,join_count,member_credits,member_role,member_role_id,rank;
		
		if ([one valueForKeyPath:@"profile_bg"]) {
			self.user_bk_pic = [tools UrlFromString:[one valueForKeyPath:@"profile_bg"]];  //背景图片
		}
		
		self.join_count = [[one valueForKeyPath:@"join_count"] intValue];
		self.member_credits = [[one valueForKeyPath:@"member_credits"] intValue];
		self.member_role_id = [[one valueForKeyPath:@"member_role_id"] intValue];
		self.follow_num = [[one valueForKeyPath:@"follow_num"] intValue];
		self.followby_num = [[one valueForKeyPath:@"followby_num"] intValue];
		self.rank = [[one valueForKeyPath:@"rank"] intValue];
		self.member_role = [one valueForKeyPath:@"member_role"];
		if ([one valueForKeyPath:@"isfollow"]) {
			self.isFollow = [[one valueForKeyPath:@"isfollow"] boolValue];
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

@implementation InvitefavoriteInfo
@synthesize new_talk_count;

-(id)initWithJSONObject:(NSDictionary*)info
{
	self=[super initWithJSONObject:info];
	if(self)
	{
		self.new_talk_count=[[info valueForKeyPath:@"new_talk_count"] intValue];
	}
	return  self;
}
@end


@implementation Scene_bgImage_change_Info
@synthesize start_time,scene_id,duration,Message,url,type;
/*
 Result = Success;
 duration = 100;
 file = 493af6099f9efde90d060e5d6c4c9eee;
 rescode = 0;
 "scene_id" = 4485;
 "start_time" = "2012-10-20 11:11:11";
 type = 10;
 url = "http://livep-piccache.stor.sinaapp.com/493af6099f9efde90d060e5d6c4c9eee";*/

-(id)initWithJSONObject:(NSDictionary*)data
{
	self=[super init];
	if(self)
	{
		@try {

		self.scene_id = [[data valueForKeyPath:@"scene_id"] intValue];
		self.type = [[data valueForKeyPath:@"type"] intValue];
		self.duration = [[data valueForKeyPath:@"duration"] intValue];
		self.Message = [data valueForKeyPath:@"Message"];
		self.url = [data valueForKeyPath:@"url"];
		NSString * newstr = [[data valueForKeyPath:@"start_time"]  stringByReplacingOccurrencesOfString:@"+" withString:@" "];
		NSString * strTime =[newstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//		NSString * strnew = [tools URLencode:strTime stringEncoding:NSUTF8StringEncoding];
		self.start_time  = [tools datebyStr:strTime];
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}

@end


@implementation Nearest_areas_Info
@synthesize address_lat,address_lng,area_id,area_name,description,scene_total_num,type,user_num;
-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			
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
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"user_num"]]) {
				self.user_num=[[oneinvite valueForKeyPath:@"user_num"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"domain_scene"]]) {
				self.domain_scene=[oneinvite valueForKeyPath:@"domain_scene"];
			} 
		}
		@catch (NSException *exception) {
			
		}
		@finally {
			
		}
	}
	return  self;
}
@end

@implementation commentpostInfo
@synthesize userinfo,comment_audio_length,comment_audio_src,comment_audio_status,comment_content,comment_id,comment_image_url,comment_time,to_post_id;//,comment_user_avatar,comment_user_name,comment_user_userid;

-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			NSDictionary* to_post = [oneinvite valueForKeyPath:@"to_post"];
			if (to_post) {
				self.to_post_id = [[to_post valueForKeyPath:@"id"] unsignedLongLongValue];
				
				NSDictionary * imageDic = [to_post valueForKeyPath:@"image"];
				if(imageDic){
					self.comment_image_url = [imageDic valueForKeyPath:@"url"];
					if ([[imageDic valueForKeyPath:@"is_external"] intValue] == 0) {
						self.comment_image_url = [tools ReturnNewURLBySize:self.comment_image_url lengDp:180 status:@""];
					}
				}	
			}
			
			NSDictionary* comment = [oneinvite valueForKeyPath:@"comment"];
			if (comment) {
				self.comment_id = [[comment valueForKeyPath:@"id"] unsignedLongLongValue];
				NSDictionary * user = [comment valueForKeyPath:@"user"];
				UserInfo_default * userdes = [[UserInfo_default alloc] initWithJSONObject:user];
				self.userinfo = userdes;
				NSDictionary * audio = [comment valueForKeyPath:@"audio"];
				self.comment_time = [comment valueForKeyPath:@"time"];
				self.comment_content = [comment valueForKeyPath:@"content"];
				if (audio && ![audio isKindOfClass:[NSNull class]]) {
					self.comment_audio_src = [audio valueForKeyPath:@"url"];
					if (![[audio valueForKeyPath:@"length"] isKindOfClass:[NSNull class]]) {				
						self.comment_audio_length = [[audio valueForKeyPath:@"length"] intValue];
					}
				}
			}
		}
		@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return self;
}
@end

@implementation NewCommitPhoto_Message
@synthesize commit_content,commit_image_url,commit_nick,commit_picrowid,commit_userid,commit_userpic,created_at,have_audio,user_pic_external;

/*
 "comment_userpic":"http://livep-photobarn.stor.sinaapp.com/9a9e2ac18a8312d0934a587a85fe69f21dd0f0a3",
 "user_pic_external":false,
 "comment_pic":"http://livep-photobarn.stor.sinaapp.com/medium/e85389e079811d64de0e5435723c27140c2e9fb8",
 "comment_userid":"1592",
 "comment_content":"媳妇",
 "comment_addtime":"2013-01-09 14:27:34",
 "have_audio":0,
 "talkid":"1248"
 "user_name":"aaa"
 */

-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		/*
		 直接通过xmpp发送
		 self.commit_content = [oneinvite valueForKeyPath:@"commit_content"];
		 self.commit_image_url = [oneinvite valueForKeyPath:@"commit_image_url"];
		 self.commit_nick = [oneinvite valueForKeyPath:@"commit_nick"];
		 self.commit_userpic = [oneinvite valueForKeyPath:@"commit_userpic"];
		 self.created_at = [oneinvite valueForKeyPath:@"created_at"];
		 self.commit_userid = [[oneinvite valueForKeyPath:@"commit_userid"] intValue];
		 self.commit_picrowid = [[oneinvite valueForKeyPath:@"commit_picrowid"] unsignedLongLongValue];
		 */
		@try {
		self.commit_content = [oneinvite valueForKeyPath:@"comment_content"];
		self.commit_image_url = [oneinvite valueForKeyPath:@"comment_pic"];
		self.commit_nick = [oneinvite valueForKeyPath:@"user_name"];
		self.commit_userpic = [oneinvite valueForKeyPath:@"comment_userpic"];
		self.created_at = [oneinvite valueForKeyPath:@"comment_addtime"];
		if (![[oneinvite valueForKeyPath:@"comment_userid"]  isKindOfClass:[NSNull class]]) {
			self.commit_userid = [[oneinvite valueForKeyPath:@"comment_userid"] intValue];
		}
		if (![[oneinvite valueForKeyPath:@"talkid"]  isKindOfClass:[NSNull class]]) {
			self.commit_picrowid = [[oneinvite valueForKeyPath:@"talkid"] unsignedLongLongValue];
		}
		if (![[oneinvite valueForKeyPath:@"have_audio"]  isKindOfClass:[NSNull class]]) {
			self.have_audio = [[oneinvite valueForKeyPath:@"have_audio"] intValue];
		}
		if (![[oneinvite valueForKeyPath:@"user_pic_external"]  isKindOfClass:[NSNull class]]) {
			if ([[oneinvite valueForKeyPath:@"user_pic_external"] boolValue]) {
				self.user_pic_external = 1;
			}else{
				self.user_pic_external = 0;
			}
			
		}
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}
@end

@implementation Business_Message
@synthesize from,content,theme,timestamp,scene_id,imageUrl;
/*
 商家消息
 {"type":30,"from":"现场+","theme":"消息推送","content":"偶吧刚拿四大","timestamp":"2012-10-12 21-21-21"}
 */
-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
		if (![[oneinvite valueForKeyPath:@"scene_id"]  isKindOfClass:[NSNull class]]) {
			self.scene_id = [[oneinvite valueForKeyPath:@"scene_id"] intValue];
		}
		self.from = [oneinvite valueForKeyPath:@"from"];
		self.theme = [oneinvite valueForKeyPath:@"theme"];
		self.content =  [oneinvite valueForKeyPath:@"content"];
		self.timestamp =[oneinvite valueForKeyPath:@"timestamp"];
		if (![[oneinvite valueForKeyPath:@"sender_profile_image_url"] isKindOfClass:[NSNull class]]) {
			self.imageUrl = [oneinvite valueForKeyPath:@"sender_profile_image_url"];
		}
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}

@end


@implementation InviteJoined
@synthesize address,address_lat,address_lng,certification,jointype,scene_id,prompt,checkin_status,check_time,showcase_image,ignore_interval;
-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			NSDictionary * sceneDic = [oneinvite objectForKey:@"scene"];
			if (sceneDic) {
				self.address = [sceneDic valueForKeyPath:@"name"];
				self.scene_id = [[sceneDic valueForKeyPath:@"id"] intValue];
				if (![[sceneDic valueForKeyPath:@"showcase_image"] isKindOfClass:[NSNull class ]]) {
					self.showcase_image = [sceneDic valueForKeyPath:@"showcase_image"];
				}
				
				if (![self isKindOfClassOfJson:[sceneDic valueForKeyPath:@"latitude"]]) {
					self.address_lat=[[sceneDic valueForKeyPath:@"latitude"] integerValue];
				}
				if (![self isKindOfClassOfJson:[sceneDic valueForKeyPath:@"longitude"]]) {
					self.address_lng=[[sceneDic valueForKeyPath:@"longitude"] integerValue];
				}
			}
		
		if (![[oneinvite valueForKeyPath:@"prompt"] isKindOfClass:[NSNull class ]]) {
			self.prompt = [oneinvite valueForKeyPath:@"prompt"];
		}
		
		if (![[oneinvite valueForKeyPath:@"check_status"] isKindOfClass:[NSNull class ]]) {
			self.checkin_status = [[oneinvite valueForKeyPath:@"check_status"] intValue];
		}
			
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}

@end
@implementation InvitefavoriteInfoNew
/*"scene_id":18052,
 "add_time":"2012-11-12 14:39:43",
 "parent":18047,
 "address":"滇草香云南原生态火锅(工体店)",
 "address_lat":39932561,
 "address_lng":116443486,
 "creator_word":"其他火锅,keikkk hello!",*/
@synthesize scene_id,add_time,address,address_lat,address_lng,creator_word,parent,recent_talk,star;

-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
		if (![[oneinvite valueForKeyPath:@"scene_id"] isKindOfClass:[NSNull class ]]) {
			self.scene_id = [[oneinvite valueForKeyPath:@"scene_id"] intValue];
		}
		
		if (![[oneinvite valueForKeyPath:@"parent"] isKindOfClass:[NSNull class ]]) {
			self.parent = [[oneinvite valueForKeyPath:@"parent"] intValue];
		}
		
		if (![[oneinvite valueForKeyPath:@"address"] isKindOfClass:[NSNull class ]]) {
			self.address = [oneinvite valueForKeyPath:@"address"];
		}
		
		if (![[oneinvite valueForKeyPath:@"creator_word"] isKindOfClass:[NSNull class ]]) {
			self.creator_word =  [oneinvite valueForKeyPath:@"creator_word"];
		}
		
		if (![[oneinvite valueForKeyPath:@"add_time"] isKindOfClass:[NSNull class ]]) {
			NSString * tempstr =[oneinvite valueForKeyPath:@"add_time"];
			if([tempstr isKindOfClass:[NSString class]])
				self.add_time=[[tools serverDateFormat] dateFromString:tempstr];
		}
		if (![[oneinvite valueForKeyPath:@"address_lat"] isKindOfClass:[NSNull class ]]) {
			self.address_lat=[[oneinvite valueForKeyPath:@"address_lat"] intValue];
		}
		
		if (![[oneinvite valueForKeyPath:@"address_lng"] isKindOfClass:[NSNull class ]]) {
			self.address_lng=[[oneinvite valueForKeyPath:@"address_lng"] intValue];
		} 
		NSArray* star_list=[oneinvite valueForKeyPath:@"star"];
		NSMutableArray *temparray=[NSMutableArray array];
		for (NSDictionary *data in star_list) {
			if ([data isKindOfClass:[NSDictionary class]]) {
				UserInfo *info=[[UserInfo alloc] initWithJSONObject:data];
				[temparray addObject:info];
			}
		}
		self.star=temparray;
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
	}
	return  self;
}
@end

@implementation Friends_Nearest_areas_Info
@synthesize image,scene_address,small_img,userinfo;
-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if (self) {
		@try {
		NSDictionary *userinfoDic = [oneinvite valueForKeyPath:@"post"];
			if (userinfoDic) {
				NSDictionary* userdic = [userinfoDic valueForKeyPath:@"user"];
				UserInfo_default * user = [[UserInfo_default alloc] initWithJSONObject:userdic];
				self.userinfo = user;
				
				NSDictionary * imgDic = [userinfoDic valueForKeyPath:@"image"];
				if (imgDic) {
					if ([[imgDic valueForKeyPath:@"url_external"] boolValue]) {
						self.image = [imgDic valueForKeyPath:@"url"] ;
						self.small_img = [imgDic valueForKeyPath:@"url"];
					}else{
						self.image = [tools ReturnNewURLBySize:[imgDic valueForKeyPath:@"url"] lengDp:480 status:@"m" ] ;
						self.small_img = [tools ReturnNewURLBySize:[imgDic valueForKeyPath:@"url"] lengDp:240 status:@"b" ] ;
					}
				}
			}
		//talk img
		NSDictionary * sceneInfo = [oneinvite valueForKeyPath:@"scene"];
		if (sceneInfo) {
			self.scene_address =[sceneInfo valueForKeyPath:@"name"];
		}
		}@catch (NSException *exception) {
			NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
		}
		@finally {
			
		}
		 
	}
	return self;
}


//将对象编码(即:序列化)
-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.scene_address forKey:@"name"];
	[aCoder encodeObject:self.image forKey:@"url"];
	[aCoder encodeObject:self.small_img forKey:@"url_small"];
	[aCoder encodeObject:self.userinfo forKey:@"user"]; 
	
}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder
{
	if (self=[super init])
	{
		self.scene_address = [aDecoder decodeObjectForKey:@"name"];
		self.image = [aDecoder decodeObjectForKey:@"url"];
		self.small_img = [aDecoder decodeObjectForKey:@"url_small"];
		self.userinfo = [aDecoder decodeObjectForKey:@"user"];
	}
	return (self);
}


@end


@implementation SceneInfo
@synthesize address_lat,address_lng,distanse,SceneInfo_description,SceneInfo_id,SceneInfo_name,SceneInfo_showcase_image,user_num;
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if(self)
	{
		@try {
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"name"]]) {
				self.SceneInfo_name=[oneinvite valueForKeyPath:@"name"];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"latitude"]]) {
				self.address_lat=[[oneinvite valueForKeyPath:@"latitude"] integerValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"longitude"]]) {
				self.address_lng=[[oneinvite valueForKeyPath:@"longitude"] integerValue];
			}
			self.SceneInfo_description=[oneinvite valueForKeyPath:@"description"];
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"id"]]) {
				self.SceneInfo_id=[[oneinvite valueForKeyPath:@"id"] intValue];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"showcase_image"]]) {
				self.SceneInfo_showcase_image = [tools ReturnNewURLBySize:[oneinvite valueForKeyPath:@"showcase_image"] lengDp:480 status:@""];
			}
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"distance"]]) {
				self.distanse=[[oneinvite valueForKeyPath:@"distance"] doubleValue];
			}
			
			if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"user_num"]]) {
				self.user_num=[[oneinvite valueForKeyPath:@"user_num"] intValue];
			}
		}
		@catch (NSException *exception) {
			
		}
		@finally {
			
		}
	}
	return self;
}

-(BOOL) updateDistanse
{
    distanse=-1;
    if(address_lat==0 || address_lng==0)
        return NO;
//    CLLocation* nowlocation=[GlobalData getInstanse].nowlocation;
//    if(nowlocation==nil)
//        return NO;
//    CLLocation *inviteloc=[[CLLocation alloc] initWithLatitude:((double)address_lat/1e6) longitude:((double)address_lng/1e6)];
//    distanse=[inviteloc distanceFromLocation:nowlocation];
    return YES;
}

-(CLLocation*) getLocation
{
	return [[CLLocation alloc] initWithLatitude:(((double)self.address_lat)/1e6) longitude:(((double)self.address_lng)/1e6) ];
}
@end
@implementation recommendations_Scene

@synthesize reason,sceneinfo,stars,tag_image;

-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if (self) {
		
		NSDictionary * sceneInfo = [oneinvite valueForKeyPath:@"scene"];
		if (sceneInfo) {
			if (![self isKindOfClassOfJson:[sceneInfo valueForKeyPath:@"scene"]]) {
				NSDictionary * scenedic = [sceneInfo valueForKeyPath:@"scene"];
				SceneInfo *info = [[SceneInfo alloc] initWithJSONObject:scenedic];
				self.sceneinfo = info;
			}
			
			if (![self isKindOfClassOfJson:[sceneInfo valueForKeyPath:@"stars"]]) {
				NSArray* members_list=[sceneInfo valueForKeyPath:@"stars"];
				NSMutableArray *starsArray=[NSMutableArray array];
				for (NSDictionary *data in members_list) {
					if ([data isKindOfClass:[NSDictionary class]]) {
						UserInfo_default *info=[[UserInfo_default alloc] initWithJSONObject:data];
						[starsArray addObject:info];
					}
				}
				self.stars=starsArray;
			}
		} 
		
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"reason"]]) {
			self.reason = [oneinvite valueForKey:@"reason"];
		}
		
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"tag_image"]]) {
			self.tag_image = [oneinvite valueForKey:@"tag_image"];
		}
		
		
	}
	return self;
}
@end
@implementation Scene_Whole_info
@synthesize stars,sceneinfo,friends;
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if (self) {
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"scene"]]) {
			NSDictionary * scenedic = [oneinvite valueForKeyPath:@"scene"];
			SceneInfo *info = [[SceneInfo alloc] initWithJSONObject:scenedic];
			self.sceneinfo = info;
		}
		
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"stars"]]) {
			NSArray* members_list=[oneinvite valueForKeyPath:@"stars"];
			NSMutableArray *starsArray=[NSMutableArray array];
			for (NSDictionary *data in members_list) {
				if ([data isKindOfClass:[NSDictionary class]]) {
					UserInfo_default *info=[[UserInfo_default alloc] initWithJSONObject:data];
					[starsArray addObject:info];
				}
			}
			self.stars=starsArray;
		}
		if (![self isKindOfClassOfJson:[oneinvite valueForKeyPath:@"friends"]]) {
			NSArray* members_list=[oneinvite valueForKeyPath:@"friends"];
			NSMutableArray *starsArray=[NSMutableArray array];
			for (NSDictionary *data in members_list) {
				if ([data isKindOfClass:[NSDictionary class]]) {
					NSDictionary * userDic =  [data objectForKey:@"user"];
					UserInfo_default *info=[[UserInfo_default alloc] initWithJSONObject:userDic];
					[starsArray addObject:info];
				}
			}
			self.friends=starsArray;
		}
	}
	return self;
}

@end



@implementation MessageListInfo
@synthesize childid,created_at,lastMessageText,message_screent_name,sender_profile_image_url,unreadMessages;
-(id)initWithJSONObject:(NSDictionary*)oneinvite
{
	self=[super init];
	if(self)
	{
		self.childid = [[oneinvite objectForKey:@"childid"] intValue];
		self.created_at = [oneinvite objectForKey:@"created_at"];
		self.lastMessageText =  [oneinvite objectForKey:@"lastMessageText"];
		self.message_screent_name =[oneinvite objectForKey:@"message_screent_name"];
		self.sender_profile_image_url =[oneinvite objectForKey:@"sender_profile_image_url"];
		self.unreadMessages =[[oneinvite objectForKey:@"unreadMessages"] intValue];
		self.created_at =[oneinvite objectForKey:@"created_at"];
	}
	return  self;
}
@end

