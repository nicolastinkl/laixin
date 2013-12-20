//
//  XCJAppDelegate.h
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SinaWeibo;
@interface XCJAppDelegate : UIResponder <UIApplicationDelegate>
{
    SinaWeibo *sinaweiboMain;
}
@property (strong, nonatomic) UIWindow                  *window;
@property (readonly, nonatomic) SinaWeibo				*sinaweiboMain;
@property (nonatomic, strong) IBOutlet UINavigationController *mainNavigateController;

-(void) initWeiboView;
@end

