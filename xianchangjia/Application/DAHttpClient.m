//
//  DAHttpClient.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "DAHttpClient.h"
#import "SINGLETONGCD.h"
#import "AFAppAPIClient.h"
#import "GlobalData.h"
#import "JSONKit.h"
#import "XCAlbumDefines.h"

@implementation DAHttpClient


SINGLETON_GCD(DAHttpClient);

/**
 *  孩子王所有网络请求接口
 *
 *  @param parames    json参数
 *  @param controller string
 *  @param action     string
 *  @param success    成功后处理
 *  @param error      失败后处理
 *
 *  @return URL TASK
 */
- (NSURLSessionDataTask *)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error
{
    //这里加入session id
    //parames[@"session"] = @"??????";
    [[GlobalData sharedGlobalData] addCommentCommandInfo:parames];
    SLog(@"json : %@",[parames JSONString]);
   return [[AFAppAPIClient sharedClient] POST:[NSString stringWithFormat:@"/%@/%@",controller,action] parameters:parames success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
       NSInteger r = [[JSON valueForKeyPath:@"response_code"] intValue];
        if(JSON && r == 1){
            success(JSON);
        }else{
			error(0);           //0  failure
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *err) {
        error(1);               //1 error
    }];
    
}


- (NSURLSessionDataTask *)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure
{
    return  [self defautlRequestWithParameters:parames controller:controller Action:action success:success error:error];
}

@end
