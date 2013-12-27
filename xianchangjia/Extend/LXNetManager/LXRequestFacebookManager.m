//
//  LXRequestFacebookManager.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXRequestFacebookManager.h"
#import "IQSocialRequestBaseClient.h"

@implementation LXRequestFacebookManager

- (void)requestGetURLWithCompletion:(CompletionBlock)completion withParems:(NSString * ) parems
{
    /*[[IQSocialRequestBaseClient sharedClient] getPath:parems
                                           parameters:nil
                                              success:^(AFHTTPRequestOperation *opertaion, id response){
                                                  NSLog(@"%@",response);
                                                  if (completion) {
                                                      completion(response, nil);
                                                  }
                                              }
                                              failure:^(AFHTTPRequestOperation *opertaion, NSError *error){
                                                  NSLog(@"%@",error);
                                                  if (completion) {
                                                      completion(nil, error);
                                                  }
                                              }];*/
    
    [[IQSocialRequestBaseClient sharedClient] GET:parems parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
