//
//  IQSocialRequestBaseClient.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "IQSocialRequestBaseClient.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString * const kAPIBaseURLString = @"http://192.168.1.10:8080";

@implementation IQSocialRequestBaseClient
+ (IQSocialRequestBaseClient *)sharedClient {
    static  IQSocialRequestBaseClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[IQSocialRequestBaseClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES]; 
    return _sharedClient;
}

@end
