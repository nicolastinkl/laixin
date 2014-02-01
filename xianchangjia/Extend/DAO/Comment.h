//
//  Comment.h
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"


/*
 “replyid”:
 “postid”:
 “uid”:
 “content”:
 “time”:
 */
@interface Comment : Model

@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) NSString *postid;
@property (nonatomic,strong) NSString *replyid;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,assign) NSTimeInterval time;
@property (strong, nonatomic) NSString * timeText;

@end



@interface postlikes : Model

@property (nonatomic,strong) NSString *uid;
@end

