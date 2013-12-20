//
//  MLNetworkingManager.h
//  WebSocket
//
//  Created by Molon on 13-11-27.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRequest.h"

extern NSString * const MLNetworkingManagerDidReceivePushMessageNotification;

@interface MLNetworkingManager : NSObject

+ (instancetype)sharedManager;

- (void)sendWithAction:(NSString*)action
            parameters:(NSDictionary *)parameters
                   success:(MLNetworkingSuccessBlcok)success
                   failure:(MLNetworkingFailureBlcok)failure;

@end
