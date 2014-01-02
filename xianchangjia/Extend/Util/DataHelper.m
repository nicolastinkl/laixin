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


/** 将数据转换成boolean
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return BOOL 转换后的值
 */
+ (BOOL)getBoolValue:(id)object
        defaultValue:(BOOL)defaultValue
                flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object boolValue];
        }
    }
    //    DLOG(@"%@ return defaultValue:%d", flag, defaultValue);
    return defaultValue;
}


/** 将数据转换成浮点数
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return CGFloat 转换后的值
 */
+ (CGFloat)getFloatValue:(id)object
            defaultValue:(CGFloat)defaultValue
                    flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object floatValue];
        }
    }
    //    DLOG(@"%@ return defaultValue:%f", flag, defaultValue);
    return defaultValue;
}

+ (double)getDoubleValue:(id)object
            defaultValue:(double)defaultValue
                    flag:(NSString *)flag {
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object doubleValue];
        }
    }
    return defaultValue;
}

/** 将数据转换成整数
 * @param   object          原数据对象
 * @param   defaultValue    默认值
 * @param   flag            标识(debug时显示)
 * @return NSInteger 转换后的值
 */
+ (NSInteger)getIntegerValue:(id)object
                defaultValue:(NSInteger)defaultValue
                        flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
            return [object integerValue];
        }
    }
    //    DLOG(@"%@ return defaultValue:%d", flag, defaultValue);
    return defaultValue;
}

/** 将数据转换成数值对象
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSNumber 转换后的值
 */
+ (NSNumber *)getNumberValue:(id)object
                defaultValue:(NSNumber *)defaultValue
                        flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSNumber class]]) {
            return object;
        } else if ([object isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithFloat:[object floatValue]];
        }
    }
    //    DLOG(@"%@ return defaultValue:%@", flag, defaultValue);
    return defaultValue;
}

/** 将数据转换成字符串（数字将被转换成字符串）
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSString 转换后的值
 */
+ (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue
                        flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]]) {
            return object;//[NSString htmlDecode:object];
        } else if ([object isKindOfClass:[NSNumber class]]) {
            return [object stringValue];
        }
    }
    //    DLOG(@"%@ return defaultValue:%@", flag, defaultValue);
    return defaultValue;
}

/** 将数据转换成数组
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSMutableArray 转换后的值
 */
+ (NSMutableArray *)getArrayValue:(id)object
                     defaultValue:(NSMutableArray *)defaultValue
                             flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSMutableArray class]]) {
            return object;
        }
    }
    //    DLOG(@"%@ return defaultValue:%@", flag, defaultValue);
    return defaultValue;
}

/** 将数据转换成 hashmap对象（key-value）
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSMutableDictionary 转换后的值
 */
+ (NSMutableDictionary *)getDictionaryValue:(id)object
                               defaultValue:(NSMutableDictionary *)defaultValue
                                       flag:(NSString *)flag {
    //    DLOG(@"%@ class:%@", flag, [object class]);
    //    DLOG(@"%@ value:%@", flag, object);
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSMutableDictionary class]]) {
            return object;
        }
    }
    //    DLOG(@"%@ return defaultValue:%@", flag, defaultValue);
    return defaultValue;
}





@end
