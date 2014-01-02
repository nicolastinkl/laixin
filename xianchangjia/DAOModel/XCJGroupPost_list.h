//
//  XCJGroupPost_list.h
//  laixin
//
//  Created by apple on 14-1-2.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "Model.h"


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
@interface XCJGroupPost_list : Model
@property (strong, nonatomic) NSString *postid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *picture;
@property (strong, nonatomic) NSString *video;
@property (strong, nonatomic) NSString *voice;

@property (assign, nonatomic) NSInteger width;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) NSInteger length;
@property (assign, nonatomic) NSInteger like;
@property (assign, nonatomic) BOOL ilike;
@property (strong, nonatomic) NSDate * time;
//@property (strong, nonatomic) NSURL *avatarURL;
@end
