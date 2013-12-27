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

@end
