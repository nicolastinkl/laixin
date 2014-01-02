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


/**
 *  “postid”:
 “uid”:
 “group_id”:
 “content”:
 “picture”:
 “video”:
 “voice”:
 “width”:200
 “height”:100
 “length”:344555
 “like”:12,
 “time”:
 “ilike”:true
 */

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
    return result;
}
@end
