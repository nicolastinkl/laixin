//
//  XCJUserViewController.h
//  xianchangjia
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UserInfo_default,DAImageResizedImageView;
@interface XCJUserViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *Image_bg;
@property (weak, nonatomic) IBOutlet DAImageResizedImageView *Image_userIcon;
@property (weak, nonatomic) IBOutlet UILabel *Label_Userinfo;
@property (weak, nonatomic) IBOutlet UITableView *tableviewUser;
@property(nonatomic,strong) UserInfo_default * userinfo;
@end
