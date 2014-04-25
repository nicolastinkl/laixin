//
//  XCJReskitModel.h
//  xianchangjia
//
//  Created by apple on 13-11-15.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCJReskitModel : NSObject

@end

@interface XCJPostInfo : NSObject
@property (nonatomic, strong) NSArray            *posts;
@property (nonatomic, copy) NSNumber             *response_code;
@end

///
/// 现场评论结构数据model
///
@class XCJUserInfo,XCJImageInfo;
@interface XCJScenePosts : NSObject
@property (nonatomic, copy) NSDate              *time;
@property (nonatomic, copy) NSString            *content;
@property (nonatomic, copy) NSNumber            *scene_id;
@property (nonatomic, assign) NSNumber          *comments_count;

@property (nonatomic, strong) XCJUserInfo       *user;
@property (nonatomic, strong) XCJImageInfo      *image;
@end

///图片详情
@interface XCJImageInfo : NSObject
@property (nonatomic, copy) NSString *url;  // 这里需要处理不同分辨率
@end

///用户详情
@interface XCJUserInfo : NSObject
@property (nonatomic, copy) NSNumber            *User_id;  //mapping id
@property (nonatomic, copy) NSString            *avatar;
@property (nonatomic, copy) NSString            *name;
@property (nonatomic, copy) NSNumber            *gender;
@property (nonatomic, copy) NSNumber            *age;
@end


