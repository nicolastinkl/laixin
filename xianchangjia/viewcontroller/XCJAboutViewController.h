//
//  XCJAboutViewController.h
//  laixin
//
//  Created by apple on 14-1-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

enum viewtype {
    serviceview = 1,
    privateview = 2,
    aboutview = 3,
    };

@interface XCJAboutViewController : UIViewController

@property (nonatomic,strong) NSString * url;
@property (nonatomic,assign) NSInteger  viewTypeIndex;

@end
