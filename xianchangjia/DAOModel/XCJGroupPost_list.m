//
//  XCJGroupPost_list.m
//  laixin
//
//  Created by apple on 14-1-2.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJGroupPost_list.h"
#import "DataHelper.h"
#import "tools.h"


@implementation XCJGroupPost_list

+ (instancetype)turnObject:(NSDictionary*)dict
{
    XCJGroupPost_list *result = [[self alloc]init];
    
    result.uid = [DataHelper getStringValue:dict[@"uid"] defaultValue:@""];
    result.group_id = [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
    result.postid = [DataHelper getStringValue:dict[@"postid"] defaultValue:@""];
    result.content = [DataHelper getStringValue:dict[@"content"] defaultValue:@""];
    result.imageURL = [DataHelper getStringValue:dict[@"picture"] defaultValue:@""];
    result.ilike = [DataHelper getBoolValue:dict[@"ilike"] defaultValue:NO];
    result.replycount = [DataHelper getIntegerValue:dict[@"replycount"] defaultValue:0];
    result.like = [DataHelper getIntegerValue:dict[@"like"] defaultValue:0];
    result.width = [DataHelper getIntegerValue:dict[@"width"] defaultValue:0];
    result.height = [DataHelper getIntegerValue:dict[@"height"] defaultValue:0];
    result.excount =[DataHelper getIntegerValue:dict[@"excount"] defaultValue:0];
    NSTimeInterval timeinter = [DataHelper getDoubleValue:dict[@"time"] defaultValue:[[NSDate date]timeIntervalSince1970]];
    result.time = timeinter;
    result.timeText = [tools timeLabelTextOfTime:timeinter];
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        result.comments = array;
    }
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        result.likeUsers = array;
    }
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        result.excountImages = array;
    }
    return result;
}
@end


/**
 *
 {“gid”:
 “creator”:
 “group_name”:
 “group_board”:
 “type”:
 “time”:
 },
 */
@implementation XCJGroup_list
+ (instancetype)turnObject:(NSDictionary*)dict
{
    XCJGroup_list *result = [[self alloc]init];
    
    result.gid = [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
    result.creator = [DataHelper getStringValue:dict[@"creator"] defaultValue:@""];
    result.group_board = [DataHelper getStringValue:dict[@"board"] defaultValue:@""];
    result.group_name = [DataHelper getStringValue:dict[@"name"] defaultValue:@""];
    result.type = [DataHelper getIntegerValue:dict[@"type"] defaultValue:0];
    NSTimeInterval timeinter = [DataHelper getDoubleValue:dict[@"time"] defaultValue:[[NSDate date]timeIntervalSince1970]];
    result.time = timeinter;
    result.timeText = [tools timeLabelTextOfTime:timeinter];
    
    return result;
}
@end



@implementation XCJFindMM_list

+ (instancetype)turnObject:(NSDictionary*)dict
{
    XCJFindMM_list *result = [[self alloc]init];
    result.uid = [DataHelper getStringValue:dict[@"uid"] defaultValue:@""];
    result.city = [DataHelper getStringValue:dict[@"city"] defaultValue:@""];
    result.age = [DataHelper getStringValue:dict[@"age"] defaultValue:@""];
    result.contact = [DataHelper getStringValue:dict[@"contact"] defaultValue:@""];
    result.recommend_uid = [DataHelper getStringValue:dict[@"recommend_uid"] defaultValue:@""];
    result.recommend_word = [DataHelper getStringValue:dict[@"recommend_word"] defaultValue:@""];
    
    result.sex = [DataHelper getIntegerValue:dict[@"sex"] defaultValue:0];
    result.message_count = [DataHelper getIntegerValue:dict[@"message_count"] defaultValue:0];
    result.like_count = [DataHelper getIntegerValue:dict[@"like_count"] defaultValue:0];
    result.sex_want = [DataHelper getIntegerValue:dict[@"sex_want"] defaultValue:0];
    result.media_count = [DataHelper getIntegerValue:dict[@"media_count"] defaultValue:0];
    result.buy_count = [DataHelper getIntegerValue:dict[@"buy_count"] defaultValue:0];
    NSTimeInterval timeinter = [DataHelper getDoubleValue:dict[@"create_time"] defaultValue:[[NSDate date]timeIntervalSince1970]];
    result.time = timeinter;
    result.timeText = [tools timeLabelTextOfTime:timeinter];
   
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
//        result.labels = array;
        result.labels= [DataHelper getArrayValue:dict[@"tags"] defaultValue:array];
    }
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        result.medias = array;

    }
    return result;
}

@end







