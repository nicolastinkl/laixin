//
//  ChatViewController.h
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation,FCUserDescription;
@interface ChatViewController : UIViewController

@property (readwrite, nonatomic, strong) Conversation *conversation;

@property (readwrite, nonatomic, strong) FCUserDescription *userinfo;


@end
