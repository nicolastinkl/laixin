//
//  LXUser.h
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>


//  json text
@interface LXUser : NSObject

@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, strong, readonly) NSString *nick;
@property (nonatomic, strong, readonly) NSString *signature;
@property (nonatomic, strong, readonly) NSString *headpic;
@property (nonatomic, strong, readonly) NSString *birthday;
@property (nonatomic, strong, readonly) NSString *background_image;
@property (nonatomic, strong, readonly) NSString *marriage;
@property (nonatomic, strong, readonly) NSString *position;
@property (nonatomic, strong, readonly) NSString *phone;
@property (nonatomic, assign, readonly) int sex;
@property (nonatomic, assign, readonly) int height;
@property (nonatomic, assign, readonly) double create_time;
@property (nonatomic, assign) int active_by;
@property (nonatomic, assign) int active_level;
@property (nonatomic, assign, readonly) int actor;
@property (nonatomic, assign) int actor_level;
@property (nonatomic, assign) int like_me_count;
- (id)initWithDict:(NSDictionary *)dic;
@end
