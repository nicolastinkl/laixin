//
//  TalkData.m
//  try
//
//  Created by JIJIA &&&&& amen on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TalkData.h"
#import "tools.h"
#import "GlobalData.h"
#import "InviteInfo.h"

@implementation ReplyData
@synthesize rowindex; 
@synthesize time;
@synthesize user_word; 
@synthesize talk_img;
@synthesize talk_img_small;
@synthesize talk_img_size;
-(id)init
{
	self=[super init];
	if(self)
	{
		 
	}
	return self;
}

-(NSComparisonResult) compare:(ReplyData*)other
{
//	if ([self.time timeIntervalSinceDate:other.time]>0)
//		return -1;
//	else if([self.time timeIntervalSinceDate:other.time]<0)
//		return 1;
//	else
//		return 0;
	//根据rowid排序
	if(self.rowindex>other.rowindex)
		return -1;
	else if(self.rowindex<other.rowindex)
		return 1;
	else
		return 0;
}

-(void)setData:(NSDictionary*)data
{
	@try {
		self.user_word = [data valueForKeyPath:@"content"];
		self.rowindex=[[tools numberFromObject:[data valueForKeyPath:@"id"]] unsignedLongLongValue];
		
		NSString* tempstr=[data valueForKeyPath:@"time"];
		if([tempstr isKindOfClass:[NSString class]])
			self.time=[[tools serverDateFormat] dateFromString:tempstr];
		NSDictionary * userDic = [data valueForKeyPath:@"user"];
		if (userDic) {
			UserInfo_default * userinfonew = [[UserInfo_default alloc] initWithJSONObject:userDic];
			self.userinfo = userinfonew;
		}
		NSDictionary *imginfo=[data valueForKeyPath:@"image"];
		if(imginfo)
		{
			BOOL url_external;
			if (![[imginfo valueForKeyPath:@"url_external"] isKindOfClass:[NSNull class]]) {
				url_external=[[imginfo valueForKeyPath:@"url_external"] boolValue];
			}			
//			BOOL url_external = [[imginfo valueForKeyPath:@"url_external"]  boolValue];
			if (url_external) {  //是外链
				if (![[imginfo valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
					self.talk_img=[imginfo valueForKeyPath:@"url"];
				}
				if (![[imginfo valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
					self.talk_img_small=[imginfo valueForKeyPath:@"url"];  //small_url
				}
			}else{
				self.talk_img=[tools ReturnNewURLBySize:[imginfo valueForKeyPath:@"url"] lengDp:720 status:@"b" ];
				self.talk_img_small=[tools ReturnNewURLBySize:[imginfo valueForKeyPath:@"url"] lengDp:320 status:@"b"];
			}
		}
		
		
	}@catch (NSException *exception) {
		NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
	}
	@finally {
		
	}
}
@end

@implementation TalkData
@synthesize CommitArray;
@synthesize replycount; // 回复数
@synthesize audio_length,audio_src,audio_status,talk_id,shareUrl;
@synthesize dislikes,likes,marked;
-(void)setData:(NSDictionary *)data
{
    [super setData:data];
	@try {
		self.talk_id=[[data valueForKeyPath:@"id"] unsignedLongLongValue];
		self.scene_id=[[data valueForKeyPath:@"scene_id"] intValue];
		NSString * webUrl =[data valueForKeyPath:@"sid"];
		self.shareUrl = [NSString stringWithFormat:@"http://api.xianchangjia.com/s/%@",webUrl];
		//content		
		if (![[data valueForKeyPath:@"comments"] isKindOfClass:[NSNull class]]) {
			NSArray *commitArray=[data valueForKeyPath:@"comments"]; //评论列表
			NSMutableArray * arry =[[NSMutableArray alloc] init];
			self.CommitArray = arry;
			if (commitArray) {
				for (NSDictionary * item in commitArray) {
					CommitInfo * info = [[CommitInfo alloc] initWithJSONObject:item];
					[self.CommitArray addObject:info];
				}
			}
		}else{
			NSMutableArray * arry =[[NSMutableArray alloc] init];
			self.CommitArray = arry;
		}
		
		if (![[data valueForKeyPath:@"sub_scene"] isKindOfClass:[NSNull class]]) {
			NSDictionary * dic = [data valueForKeyPath:@"sub_scene"];
			if (dic) {
				NSDictionary * sceneDic = [dic valueForKeyPath:@"scene"];
				SceneInfo * sceneinfo = [[SceneInfo alloc] initWithJSONObject:sceneDic];
				self.sInfo = sceneinfo;
			}
			
		}
		//1：表示有 0：无
		NSDictionary *audioInfo=[data valueForKeyPath:@"audio"];
		if(audioInfo)
		{
			if (![[audioInfo valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
				self.audio_src=[audioInfo valueForKeyPath:@"url"];
			}
			if (![[audioInfo valueForKeyPath:@"status"] isKindOfClass:[NSNull class]]) {
				self.audio_status = [[audioInfo valueForKeyPath:@"status"] intValue];
			}
			if (![[audioInfo valueForKeyPath:@"length"] isKindOfClass:[NSNull class]]) {
				self.audio_length =[[audioInfo valueForKeyPath:@"length"] intValue];
			} 
		}
		self.replycount =[[data valueForKeyPath:@"comments_count"] intValue];
		self.dislikes =[[data valueForKeyPath:@"dislikes"] intValue];
		self.marked =[[data valueForKeyPath:@"marked"] boolValue];
		self.likes =[[data valueForKeyPath:@"likes"] intValue];
		if (![[data valueForKeyPath:@"attitude"] isKindOfClass:[NSNull class]]) {
			self.attitude =[[data valueForKeyPath:@"attitude"] intValue];
		}
	}@catch (NSException *exception) {
		NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
	}
	@finally {
		
	}

}
@end

@implementation CommentData
@synthesize replyto;
-(void)setData:(NSDictionary*)data
{
    [super setData:data];
    self.time=[[tools serverDateFormat] dateFromString:[data valueForKeyPath:@"add_time"]];
    NSDictionary *replyto_data=[data valueForKeyPath:@"replyto"];
    if(replyto_data)
    {
        ReplyData *replyData=[ReplyData new];
        [replyData setData:replyto_data];
        replyData.time=[[tools serverDateFormat] dateFromString:[replyto_data valueForKeyPath:@"add_time"]];
        self.replyto=replyData;
    }
}
@end



@implementation CommitInfo
@synthesize uid,screen_name,avatar_small,avatar_src,words,timestamp,audio_length,audio_src,audio_status,comment_id,userinfo;
-(id) initWithJSONObject:(NSDictionary*) oneinvite
{
	self=[super init];
	if(self==nil)
		return nil;
	@try {
		
		if (![[oneinvite valueForKeyPath:@"content"] isKindOfClass:[NSNull class]]) {
			self.words=[oneinvite valueForKeyPath:@"content"];
		}
		
		if (![[oneinvite valueForKeyPath:@"id"] isKindOfClass:[NSNull class]]) {
			self.comment_id = [[oneinvite valueForKeyPath:@"id"] intValue];
		}
		
		NSDictionary * userDic = [oneinvite valueForKeyPath:@"user"];
		if (userDic) {
			UserInfo_default * user = [[UserInfo_default alloc] initWithJSONObject:userDic];
			self.userinfo = user;
			self.uid = user.user_id;
			self.screen_name = user.user_name;
			if (user.user_avatar_image) {
				self.avatar_src=[tools UrlFromString:user.user_avatar_image];
				self.avatar_small=[tools UrlFromString:user.user_avatar_image];
			}
		}
		NSString *tempstr =[oneinvite valueForKeyPath:@"time"];
		if([tempstr isKindOfClass:[NSString class]])
			self.timestamp=[[tools serverDateFormat] dateFromString:tempstr];
		NSDictionary *audioInfo=[oneinvite valueForKeyPath:@"audio"];
		if(audioInfo)
		{
			if (![[audioInfo valueForKeyPath:@"url"] isKindOfClass:[NSNull class]]) {
				self.audio_src=[audioInfo valueForKeyPath:@"url"];
			}
			if (![[audioInfo valueForKeyPath:@"length"] isKindOfClass:[NSNull class]]) {
				self.audio_length =[[audioInfo valueForKeyPath:@"length"] intValue];
		} 
		
	}
	}@catch (NSException *exception) {
		NSLog(@"exceptionexception: %s  %@",__FUNCTION__,exception.reason);
	}
	@finally {
		
	}
	
	return self;
}



@end