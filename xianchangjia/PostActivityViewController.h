//
//  PostActivityViewController.h
//  Kidswant
//
//  Created by Molon on 13-11-19.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseDetailViewController;

@interface PostActivityViewController : UIViewController

@property (nonatomic,strong) UIImage *postImage;
@property (nonatomic,strong) NSURL * filePath;
@property (nonatomic,strong) NSString * gID;
@property (nonatomic,weak) BaseDetailViewController *needRefreshViewController;

@end
