//
//  LXRequestFacebookManager.h
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "blocktypedef.h"

@interface LXRequestFacebookManager : NSObject

- (void)requestGetURLWithCompletion:(CompletionBlock)completion withParems:(NSString * ) parems;

/**
 *  根据IDs 数组获取批量用户
 *
 *  @param uids <#uids description#>
 *
 *  @return <#return value description#>
 */
-(void) fetchAlAccountsByArray:(NSArray * ) uids;

/**
 *  获取单个user
 *
 *  @param uid <#uid description#>
 *
 *  @return <#return value description#>
 */
-(void) getUserDesPtionCompletion:(CompletionBlock)completion withuid:(NSString * ) uid;

/**
 *  限制请求用户数据
 *
 *  @param completion <#completion description#>
 *  @param uid        <#uid description#>
 */
-(void) getUserDesByNetCompletion:(CompletionBlock)completion withuid:(NSString * ) uid;

@end
