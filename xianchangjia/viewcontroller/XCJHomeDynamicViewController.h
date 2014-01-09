//
//  XCJHomeDynamicViewController.h
//  laixin
//
//  Created by apple on 14-1-2.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseDetailViewController.h"
#import "FCHomeGroupMsg.h"

@interface XCJHomeDynamicViewController : BaseDetailViewController

@property (nonatomic,strong) NSString * Currentgid;

@property (readwrite, nonatomic, strong) FCHomeGroupMsg * groupInfo;

@end
