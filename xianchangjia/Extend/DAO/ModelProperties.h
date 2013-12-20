//
//  ModelProperties.h
//  xianchangjia
//
//  Created by Molon on 13-12-10.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelProperties : NSObject

+ (instancetype)shareInstance;
- (NSDictionary *)getPropertiesOfClass:(Class)cls;

@end
