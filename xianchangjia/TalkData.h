//
//  TalkData.h
//  try
//
//  Created by JIJIA &&&&& amen on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@class SceneInfo;
@interface ReplyData : NSObject
@property (assign,nonatomic) unsigned long long rowindex;

@property (strong,nonatomic) NSDate *time;
@property (strong,nonatomic) NSString *user_word;
@property (strong,nonatomic) UserInfo_default * userinfo;
@property (strong,nonatomic) NSString* talk_img;
@property (strong,nonatomic) NSString* talk_img_small;
@property (assign,nonatomic) CGSize talk_img_size;
-(NSComparisonResult) compare:(ReplyData*)other;
-(void)setData:(NSDictionary*)data;
@end
@interface TalkData : ReplyData 
@property (assign,nonatomic) int replycount;
@property (strong,nonatomic) NSString* shareUrl;
@property (strong,nonatomic) NSMutableArray* CommitArray;
@property (strong,nonatomic) NSString* audio_src;
@property (assign,nonatomic) int  audio_length;
@property (assign,nonatomic) int  audio_status;
@property (assign,nonatomic) unsigned long long  talk_id;	//scene_id	Integer	24
@property (assign,nonatomic) int  scene_id;	//scene_id	Integer	24
@property (assign,nonatomic) int  dislikes;
@property (assign,nonatomic) int  likes;
@property (assign,nonatomic) BOOL  marked;
@property (assign,nonatomic) int  attitude;
@property (strong,nonatomic) SceneInfo * sInfo;

@end

@interface CommentData : ReplyData
@property (strong,nonatomic) ReplyData* replyto;
@end

@interface CommitInfo : NSObject
@property (assign,nonatomic) int uid;
@property (assign,nonatomic) int comment_id;
@property (strong,nonatomic) NSString* screen_name;
@property (strong,nonatomic) NSDate *timestamp;
@property (strong,nonatomic) NSString *words;
@property (strong,nonatomic) NSURL* avatar_small;
@property (strong,nonatomic) NSURL* avatar_src;
@property (strong,nonatomic) UserInfo_default * userinfo;
@property (strong,nonatomic) NSString* audio_src;
@property (assign,nonatomic) int  audio_length;
@property (assign,nonatomic) int  audio_status;
-(id) initWithJSONObject:(NSDictionary*) oneinvite;
@end


