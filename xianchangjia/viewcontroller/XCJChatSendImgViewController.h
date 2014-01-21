//
//  XCJChatSendImgViewController.h
//  laixin
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol   XCJChatSendImgViewControllerdelegate <NSObject>
- (void) SendImageURL:(NSString * ) url  withKey:(NSString *) key;
@end

@class XCJChatSendImgViewControllerdelegate;
@interface XCJChatSendImgViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) NSString *imageviewURL;
@property (strong, nonatomic) NSString *key;
@property (weak, nonatomic) id<XCJChatSendImgViewControllerdelegate>  delegate;
@end
