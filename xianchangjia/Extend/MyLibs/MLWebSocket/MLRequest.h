//
//  MLRequest.h
//  WebSocket
//
//  Created by Molon on 13-11-27.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLRequest;

typedef void(^MLNetworkingSuccessBlcok)(MLRequest *request, id responseObject);
typedef void(^MLNetworkingFailureBlcok)(MLRequest *request, NSError *error);

@interface MLRequest : NSObject

@property (nonatomic,copy) NSString *requestKey;
@property (nonatomic,copy) NSString *action;
@property (nonatomic,copy) NSString *cdata;
@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,copy) MLNetworkingSuccessBlcok successBlock;
@property (nonatomic,copy) MLNetworkingFailureBlcok failureBlock;

@end
