//
//  Chat.h
//  ISClone
//
//  Created by Molon on 13-12-2.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Model.h"

@interface Chat : Model

@property (assign, nonatomic) NSUInteger uid;
@property (strong, nonatomic) NSURL *avatarURL;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *latestMessage;
@property (assign, nonatomic) NSTimeInterval latestTime;
@property (assign, nonatomic) NSUInteger unreadCount;

@end
