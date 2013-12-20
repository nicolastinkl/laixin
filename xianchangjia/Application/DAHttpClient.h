//
//  DAHttpClient.h
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "blocktypedef.h"

@interface DAHttpClient :    AFHTTPSessionManager
{
	NSString        *_apiBaseUrlString;
}

+ (DAHttpClient *)sharedDAHttpClient;


- (NSURLSessionDataTask *)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error;


- (NSURLSessionDataTask*)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure;
@end
