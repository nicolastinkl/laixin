//
//  LXAPIController.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXAPIController.h"
#import "XCAlbumAdditions.h"
#import "LXRequestFacebookManager.h"
//#import "LXChatDataStoreManager.h"

@interface LXAPIController()
@property (nonatomic, strong) LXRequestFacebookManager *requestLaixinManager;
//@property (nonatomic, strong) LXChatDataStoreManager *chatDataStoreManager;
@end

@implementation LXAPIController
SINGLETON_GCD(LXAPIController)

- (LXRequestFacebookManager *)requestLaixinManager {
    if (!_requestLaixinManager) {
        _requestLaixinManager = [[LXRequestFacebookManager alloc] init];
    }
    return _requestLaixinManager;
}



//- (LXChatDataStoreManager *)chatDataStoreManager {
//    if (!_chatDataStoreManager) {
//        _chatDataStoreManager = [LXChatDataStoreManager new];
//    }
//    return _chatDataStoreManager;
//}

@end
