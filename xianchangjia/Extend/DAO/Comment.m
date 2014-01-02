//
//  Comment.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Comment.h"
#import "DataHelper.h"
#import "tools.h"

@implementation Comment

+ (instancetype)turnObject:(NSDictionary*)dict
{
    Comment *result = [[self alloc]init];
    
    NSTimeInterval timeinter = [DataHelper getDoubleValue:dict[@"time"] defaultValue:[[NSDate date]timeIntervalSince1970]];
    result.time = timeinter;
    result.timeText = [tools timeLabelTextOfTime:timeinter];
    result.uid = [DataHelper getStringValue:dict[@"uid"] defaultValue:@""];
    result.replyid = [DataHelper getStringValue:dict[@"replyid"] defaultValue:@""];
    result.postid = [DataHelper getStringValue:dict[@"postid"] defaultValue:@""];
    result.content = [DataHelper getStringValue:dict[@"content"] defaultValue:@""];
    
    return result;
}

@end
