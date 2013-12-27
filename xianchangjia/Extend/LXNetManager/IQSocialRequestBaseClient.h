//
//  IQSocialRequestBaseClient.h
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"

@interface IQSocialRequestBaseClient : AFHTTPSessionManager
+ (IQSocialRequestBaseClient *)sharedClient;
@end
