//
//  XCJPostTextViewController.h
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaseDetailViewController;
@interface XCJPostTextViewController : UIViewController
@property (nonatomic,strong) NSString * gID;
@property (nonatomic,weak) BaseDetailViewController *needRefreshViewController;
@end
