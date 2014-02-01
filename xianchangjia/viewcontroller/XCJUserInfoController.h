//
//  XCJUserInfoController.h
//  laixin
//
//  Created by apple on 13-12-31.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCFriends,FCUserDescription;
@interface XCJUserInfoController : UITableViewController
@property (readwrite, nonatomic, strong) FCFriends *frend;
@property (readwrite, nonatomic, strong) FCUserDescription *UserInfo;
@end
