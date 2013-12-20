//
//  AFAppAPIClient.h
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import <Foundation/Foundation.h>

@interface AFAppAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
