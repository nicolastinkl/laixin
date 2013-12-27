//
//  LXAPIController.h
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFCMessageDidComeNotification @"kFCMessageDidComeNotification"

@class LXRequestFacebookManager;

@interface LXAPIController : NSObject
+ (LXAPIController *)sharedLXAPIController;
@property (readonly , nonatomic, strong) LXRequestFacebookManager *requestLaixinManager;

@end
