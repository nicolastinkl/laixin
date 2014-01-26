//
//  XCJAppDelegate.h
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomWindow.h"

@class SinaWeibo,XCJLoginNaviController;
@interface XCJAppDelegate : UIResponder <UIApplicationDelegate>
{
    SinaWeibo *sinaweiboMain;
}

@property (strong, nonatomic) CustomWindow                  *window;
@property (readonly, nonatomic) SinaWeibo				*sinaweiboMain;
@property (nonatomic,strong) NSDictionary				*launchingWithAps;
@property (nonatomic, strong) IBOutlet XCJLoginNaviController *mainNavigateController;
@property (nonatomic,strong) UITabBarController *tabBarController;

-(void) initWeiboView;
+(BOOL) hasLogin;

@end

/* 张钦贵   工行   6222 0844 0200 7272 843*/


