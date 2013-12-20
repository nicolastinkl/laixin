//
//  Message.h
//  ISClone
//
//  Created by Molon on 13-12-6.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Model.h"

@interface Message : Model

@property (strong, nonatomic) NSURL *avatarURL;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *content;
@property (assign, nonatomic) NSTimeInterval time;
@property (strong, nonatomic) UIImage *messageImage;

@end
