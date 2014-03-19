//
//  MLNetworkingManager.h
//  WebSocket
//
//  Created by Molon on 13-11-27.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLRequest.h"
#import "SRWebSocket.h"

extern NSString * const MLNetworkingManagerDidReceivePushMessageNotification;
extern NSString * const MLNetworkingManagerDidReceiveForcegroundMessageNotification;


@interface MLNetworkingManager : NSObject

//对于requests的操作必须放在主线程，以免不安全
@property (nonatomic,strong,readonly) NSArray *requests;
//准备发送
@property (nonatomic,strong) NSMutableArray *preparedRequests;
//已经发送
@property (nonatomic,strong) NSMutableArray *sentRequests;

@property (nonatomic,strong) SRWebSocket *webSocket;

@property (nonatomic,strong) NSURL *baseURL;

@property (nonatomic,copy) NSString *sessionID;

+ (instancetype)sharedManager;

- (void)sendWithAction:(NSString*)action
            parameters:(NSDictionary *)parameters
                   success:(MLNetworkingSuccessBlcok)success
                   failure:(MLNetworkingFailureBlcok)failure;

- (void)sendWithAction:(NSString*)action
                 Cdata:(NSString*)cdata
            parameters:(NSDictionary *)parameters
               success:(MLNetworkingSuccessBlcok)success
               failure:(MLNetworkingFailureBlcok)failure;

@end
