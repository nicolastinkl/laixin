//
//  XCJAddUserTableViewController.h
//  laixin
//
//  Created by apple on 14-1-4.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCUserDescription.h"
#import "LXUser.h"
@interface XCJAddUserTableViewController : UITableViewController
@property (readwrite, nonatomic, strong) FCUserDescription *UserInfo;
//@property (readwrite, nonatomic, strong) LXUser *UserInfoJson;
@end
