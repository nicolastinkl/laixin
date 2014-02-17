//
//  XCJFriendGroupViewController.h
//  laixin
//
//  Created by apple on 14-2-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDetailViewController.h"
#import "ConverReply.h"
@interface XCJFriendGroupViewController : BaseDetailViewController
@property (readwrite, nonatomic, strong) ConverReply *conversation;
-(void) hasNewPostInfo;
@end
