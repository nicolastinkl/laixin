//
//  DataHelper.m
//  MolonFrame
//
//  Created by Molon on 13-10-1.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "DataHelper.h"
@implementation DataHelper

+ (BOOL)getBoolValue:(id)object 
        defaultValue:(BOOL)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object boolValue];
        }
    }
    return defaultValue;
}

+ (CGFloat)getFloatValue:(id)object 
            defaultValue:(CGFloat)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object floatValue];
        }
    }
    return defaultValue;
}

+ (double)getDoubleValue:(id)object
            defaultValue:(double)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object doubleValue];
        }
    }
    return defaultValue;
}

+ (NSInteger)getIntegerValue:(id)object 
                defaultValue:(NSInteger)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object integerValue];
        }
    }
    return defaultValue;
}

+ (NSNumber *)getNumberValue:(id)object
                defaultValue:(NSNumber *)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSNumber class]]) {
            return object;
        } else if ([object isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithFloat:[object floatValue]];
        }
    }
    return defaultValue;
}

+ (NSString *)getStringValue:(id)object 
                defaultValue:(NSString *)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]]) {
            return object;
        } else if ([object isKindOfClass:[NSNumber class]]) {
            return [object stringValue];
        }
    }
    return defaultValue;
}

+ (NSURL *)getURLValue:(id)object
                defaultValue:(NSURL *)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:object];
        } else if ([object isKindOfClass:[NSURL class]]) {
            return object;
        }
    }
    return defaultValue;
}

+ (NSMutableArray *)getArrayValue:(id)object 
                     defaultValue:(NSMutableArray *)defaultValue
{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSArray class]]) {
            return [object mutableCopy];
        }
    }
    return defaultValue;
}

+ (NSMutableDictionary *)getDictionaryValue:(id)object 
                               defaultValue:(NSMutableDictionary *)defaultValue{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            return [object mutableCopy];
        }
    }
    return defaultValue;
}


@end
