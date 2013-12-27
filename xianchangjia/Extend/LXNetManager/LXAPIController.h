//
//  LXAPIController.h
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXUser.h"
#define kFCMessageDidComeNotification @"kFCMessageDidComeNotification"

@class LXRequestFacebookManager;
//,LXChatDataStoreManager;

@interface LXAPIController : NSObject

+ (LXAPIController *)sharedLXAPIController;

@property (nonatomic, strong) LXUser *currentUser;

@property (readonly , nonatomic, strong) LXRequestFacebookManager *requestLaixinManager;
//@property (readonly , nonatomic, strong) LXChatDataStoreManager *chatDataStoreManager;

@end
