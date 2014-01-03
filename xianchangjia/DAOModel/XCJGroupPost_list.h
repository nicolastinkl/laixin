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

@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableArray * likeUsers;


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
@end













