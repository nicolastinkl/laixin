//
//  XCJMessageReplylistController.h
//  laixin
//
//  Created by apple on 14-1-11.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConverReply.h"
@interface XCJMessageReplylistController : UITableViewController
@property (readwrite, nonatomic, strong) ConverReply *conversation;
@end
