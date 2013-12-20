//
//  ModelProperties.m
//  xianchangjia
//
//  Created by Molon on 13-12-10.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "ModelProperties.h"
#import "ObjcRuntime.h"

@interface ModelProperties()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation ModelProperties

+ (instancetype)shareInstance {
    static ModelProperties *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc]init];
    });
    return _shareInstance;
}

- (NSMutableDictionary*)dict
{
    if (!_dict) {
        _dict = [[NSMutableDictionary alloc]init];
    }
    return _dict;
}

- (NSDictionary *)getPropertiesOfClass:(Class)cls
{
    NSString *clsname = NSStringFromClass(cls);
    if (!self.dict[clsname]) {
        [self.dict setValue:GetPropertyListOfClass(cls) forKey:clsname];
    }
    return self.dict[clsname];
}

@end
