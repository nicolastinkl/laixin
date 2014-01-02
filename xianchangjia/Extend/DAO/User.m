//
//  User.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "User.h"
#import "DataHelper.h"

@implementation User

+ (instancetype)turnObject:(NSDictionary*)dict
{
    User *result = [[self alloc]init];
    
    result.avatarURL = [DataHelper getStringValue:dict[@"avatar"] defaultValue:nil flag:@"avatar"];
    result.name = [DataHelper getStringValue:dict[@"name"] defaultValue:nil flag:@"name"];
    result.uid = [DataHelper getIntegerValue:dict[@"id"] defaultValue:0 flag:@"id"];
    result.backgroundImageURL = [DataHelper getStringValue:dict[@"background_image"] defaultValue:nil flag:@"background_image"];
    return result;
}


@end
