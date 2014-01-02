//
//  Activity.h
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@class User;
@interface Activity : Model

@property (nonatomic,assign) NSInteger aid;

@property (nonatomic,strong) User *user;
@property (nonatomic,assign) NSTimeInterval time;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *imageURL;
@property (nonatomic,assign) NSInteger likeCount;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableArray *latestLikeUsers;
@property (nonatomic,assign) NSInteger sceneID;

@property (nonatomic,assign) BOOL isLiked;

@end
