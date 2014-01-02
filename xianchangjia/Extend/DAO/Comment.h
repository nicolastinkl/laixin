//
//  Comment.h
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@class User;

@interface Comment : Model

@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) User *user;
@property (nonatomic,assign) NSTimeInterval time;

@end
