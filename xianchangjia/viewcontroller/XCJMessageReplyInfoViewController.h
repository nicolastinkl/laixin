//
//  XCJMessageReplyInfoViewController.h
//  laixin
//
//  Created by apple on 14-1-17.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCReplyMessage,XCJGroupPost_list;
@interface XCJMessageReplyInfoViewController : UIViewController

@property (nonatomic,weak) FCReplyMessage * message;
@property (nonatomic,weak) XCJGroupPost_list * post;
@end
