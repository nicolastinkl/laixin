//
//  Activity.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Activity.h"
#import "Comment.h"
#import "User.h"
#import "DataHelper.h"

@implementation Activity

+ (instancetype)turnObject:(NSDictionary*)dict
{
    Activity *result = [[self alloc]init];
    
    result.aid = [DataHelper getIntegerValue:dict[@"id"] defaultValue:0 flag:@"id"];
    
    if (dict[@"user"]&& [dict[@"user"] isKindOfClass:[NSDictionary class]]) {
        result.user = [User turnObject:[DataHelper getDictionaryValue:dict[@"user"] defaultValue:nil flag:@"user"]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    result.time = [[formatter dateFromString:[DataHelper getStringValue:dict[@"time"] defaultValue:nil flag:@"time"]] timeIntervalSince1970];
    
    result.content = [DataHelper getStringValue:dict[@"content"] defaultValue:nil flag:@"content"];
    result.imageURL = [DataHelper getStringValue:dict[@"image"][@"url"] defaultValue:nil flag:@"image.url"];
    result.likeCount = [DataHelper getIntegerValue:dict[@"likes"] defaultValue:0 flag:@"likes"];

    if (dict[@"comments"]&& [dict[@"comments"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *comments = [[NSMutableArray alloc]initWithCapacity:((NSArray*)dict[@"comments"]).count];
        for (NSDictionary *aComment in dict[@"comments"]) {
            [comments addObject:[Comment turnObject:aComment]];
        }
        result.comments = comments;
        //升序排序
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_time" ascending:YES];
        [result.comments sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    if (dict[@"marked"]&&[dict[@"marked"] boolValue]&&[dict[@"attitude"] integerValue]>0) {
        result.isLiked = YES;
    }
    
    //like_users
    if (dict[@"like_user"]&& [dict[@"like_user"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *like_users = [[NSMutableArray alloc]initWithCapacity:((NSArray*)dict[@"like_user"]).count];
        for (NSDictionary *aLikeUser in dict[@"like_user"]) {
            [like_users addObject:[User turnObject:aLikeUser]];
        }
        result.latestLikeUsers = like_users;
    }

    
    result.sceneID = [DataHelper getIntegerValue:dict[@"scene_id"] defaultValue:0 flag:@"scene_id"];
    
    return result;
}

@end
