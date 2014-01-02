//
//  Comment.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Comment.h"
#import "User.h"
#import "DataHelper.h"

@implementation Comment


+ (instancetype)turnObject:(NSDictionary*)dict
{
    Comment *result = [[self alloc]init];
    
    if (dict[@"user"]&& [dict[@"user"] isKindOfClass:[NSDictionary class]]) {
        result.user = [User turnObject:[DataHelper getDictionaryValue:dict[@"user"] defaultValue:nil flag:@"user"]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    result.time = [[formatter dateFromString:[DataHelper getStringValue:dict[@"time"] defaultValue:nil flag:@"time"]] timeIntervalSince1970];
    
    result.content = [DataHelper getStringValue:dict[@"content"] defaultValue:nil flag:@"content"];
    return result;
}

@end
