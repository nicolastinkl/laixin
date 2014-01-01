//
//  LXRequestFacebookManager.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXRequestFacebookManager.h"
#import "IQSocialRequestBaseClient.h"
#import "MLNetworkingManager.h"
#import "LXUser.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "FCAccount.h"


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


-(NSArray * ) fetchAlAccountsByArray:(NSArray * ) uids
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSDictionary * parames = @{@"uid":uids};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
        // "users":[....]
        NSDictionary * userinfo = responseObject[@"result"];
        NSArray * userArray = userinfo[@"users"];
        [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FCAccount * fccount = [[FCAccount alloc] init];
            LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
            fccount.facebookId = currentUser.uid;
            
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError *error) {
                fccount.fcindefault = response;
                [array addObject:fccount];
            }];
        }];
    } failure:^(MLRequest *request, NSError *error) {
        
    }];
    return array;
}


-(void) getUserDesPtionCompletion:(CompletionBlock)completion withuid:(NSString * ) uid
{
    if (!uid) {
        return;
    }
    //MARK Base fbid to find userdesp object,, if userdesp is nil, will select from networking
    FCUserDescription * localdespObject  =[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:uid];
    if (localdespObject) {
        completion( localdespObject,nil);
    }else{
        //from networking by ID
        
        NSDictionary * parames = @{@"uid":@[uid]};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
            if (userArray && userArray.count > 0) {
                NSDictionary * dict = userArray[0];
                LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
                    completion(response,nil);
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
    
}

@end
