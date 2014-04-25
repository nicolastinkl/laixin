//
//  Model.m
//  MolonFrame
//
//  Created by Molon on 13-10-25.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "Model.h"
#import "DataHelper.h"
#import "ModelArray.h"
#import "ModelProperties.h"

@interface Model()

@end

@implementation Model

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)turnObject:(NSDictionary*)dict
{
    Model *model = [[self alloc]init];
    
    //根据当前Model的元素名字和dict的key来对应赋值
    NSDictionary *properties = [[ModelProperties shareInstance]getPropertiesOfClass:[self class]];
    for (NSString *key in [properties allKeys]) {
        if (!dict[key]||[dict[key] isKindOfClass:[NSNull class]]) {
//            NSLog(@"属性%@给予的值为空",key);
            continue;
        }
        
        //检查是否是标量,是的话对其赋值
        NSString *type = properties[key];
        if (![type hasPrefix:@"T@\""]||![type hasSuffix:@"\""]) {
             //前缀和后缀，有其一都不可
            [model setValue:[DataHelper getNumberValue:dict[key] defaultValue:0] forKey:key];
            continue;
        }
        
        //到此type被认作是对象，NSObject，具有前缀和后缀
        type = [type substringWithRange:NSMakeRange(3, [type length]-4)];
        //检查是否是NSNumber
        if ([type isEqualToString:@"NSNumber"]) {
            //数据类型为NSNumber,简单赋值,由于NSNumber alloc init无意义，需要在此单独处理
            [model setValue:[DataHelper getNumberValue:dict[key] defaultValue:nil]
                    forKey:key];
            continue;
        }else if ([type isEqualToString:@"NSURL"]) {
            //原因同上
            [model setValue:[DataHelper getURLValue:dict[key] defaultValue:nil]
                     forKey:key];
            continue;
        }
        
        Class cls = NSClassFromString(type);
        id temp = [[cls alloc]init];
        //数据类型为NSString,NSDictionary,NSArray但非ModelArray的子类,NSURL则简单赋值
        if ([temp isKindOfClass:[NSString class]]){
            [model setValue:[DataHelper getStringValue:dict[key] defaultValue:nil]
                    forKey:key];
        }else if([temp isKindOfClass:[NSDictionary class]]) {
            [model setValue:[DataHelper getDictionaryValue:dict[key] defaultValue:nil]
                    forKey:key];
        }else if([temp isKindOfClass:[NSArray class]]){
            [model setValue:[DataHelper getArrayValue:dict[key] defaultValue:nil]
                    forKey:key];
        }else if ([temp isKindOfClass:[Model class]]){
            //是Model的子类就直接调用其turnObject方法
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                [model setValue:[cls turnObject:dict[key]] forKey:key];
            }
        }else if ([temp isKindOfClass:[ModelArray class]]){
            if ([dict[key] isKindOfClass:[NSArray class]]) {
                //ModelArray的turnObject里遍历并且调用对应的Model turnObject
                [model setValue:[cls turnObject:dict[key]] forKey:key];
            }
        }else{
            NSLog(@"属性%@的类型%@不在动态绑定处理范围内,只可处理标量以及NSString,NSDictionary,NSArray,NSURL,Model子类,ModelArray子类",key,type);
        }
    }
    
    return model;
}

@end
