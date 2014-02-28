//
//  XCJGroupPost_list.h
//  laixin
//
//  Created by apple on 14-1-2.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

/**
 *  动态model
 */
@interface XCJGroupPost_list : Model
@property (strong, nonatomic) NSString *postid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *imageURL;
@property (assign, nonatomic) NSInteger like;
@property (assign, nonatomic) NSInteger replycount;
@property (strong, nonatomic) NSString  *content;
@property (assign, nonatomic) BOOL ilike;
@property (assign, nonatomic) NSTimeInterval time;
@property (strong, nonatomic) NSString * timeText;
@property (assign, nonatomic) NSInteger excount;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) NSInteger width;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableArray * likeUsers;
@property (nonatomic,strong) NSMutableArray * excountImages;

//@property (strong, nonatomic) NSString *video;
//@property (strong, nonatomic) NSString *voice;
//@property (assign, nonatomic) NSInteger width;
//@property (assign, nonatomic) NSInteger height;
//@property (assign, nonatomic) NSInteger length;
@end

/**
 *  群info
 */
@interface XCJGroup_list : Model
@property (strong, nonatomic) NSString *gid;
@property (strong, nonatomic) NSString *creator;
@property (strong, nonatomic) NSString *group_name;
@property (strong, nonatomic) NSString *group_board;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) NSTimeInterval time;
@property (strong, nonatomic) NSString * timeText;
@property (strong, nonatomic) NSString * position;
@end









/**
 *  抢你妹推荐数据
 */
@interface XCJFindMM_list : Model
/*
 "uid":14,
 "sex":1,
 "message_count":0,
 "like_count":0,
 "sex_want":1,
 "recommend_uid":1,
 "city":"四川 成都",
 "media_count":0,
 "age":"少有韵味",
 "buy_count":0,
 "contact":"[phone]13067575126",
 "create_time":1392711681,
 "recommend_word"
 */
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) NSInteger sex;
@property (assign, nonatomic) NSInteger message_count;
@property (assign, nonatomic) NSInteger like_count;
@property (assign, nonatomic) NSInteger sex_want;
@property (assign, nonatomic) NSInteger media_count;
@property (assign, nonatomic) NSInteger buy_count;
@property (strong, nonatomic) NSString  *contact;
@property (strong, nonatomic) NSString  *recommend_word;
@property (strong, nonatomic) NSString  *recommend_uid;
@property (strong, nonatomic) NSString  *age;
@property (assign, nonatomic) NSTimeInterval time;
@property (strong, nonatomic) NSString * timeText;

@property (nonatomic,strong) NSMutableArray * medias;
@property (nonatomic,strong) NSMutableArray * labels;
@end







