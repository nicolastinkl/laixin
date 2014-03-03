//
//  XCJAppDelegate.h
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomWindow.h"
#import "WXApi.h"
@class SinaWeibo,XCJLoginNaviController;
@interface XCJAppDelegate : UIResponder <UIApplicationDelegate>
{
    SinaWeibo *sinaweiboMain;
    enum WXScene _scene;
}

@property (strong, nonatomic) CustomWindow                  *window;
@property (readonly, nonatomic) SinaWeibo				*sinaweiboMain;
@property (nonatomic,strong) NSDictionary				*launchingWithAps;
@property (nonatomic, strong) IBOutlet XCJLoginNaviController *mainNavigateController;
@property (nonatomic,strong) UITabBarController *tabBarController;

-(void) initWeiboView;
+(BOOL) hasLogin;
- (void) sendImageContent:(int ) type withImageData:(NSData * ) imagedata;
@end


