//
//  DataHelper.h
//  MolonFrame
//
//  Created by Molon on 13-10-1.
//  Copyright (c) 2013年 Molon. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DataHelper : NSObject

+ (BOOL)getBoolValue:(id)object
        defaultValue:(BOOL)defaultValue;

+ (CGFloat)getFloatValue:(id)object
            defaultValue:(CGFloat)defaultValue;

+ (double)getDoubleValue:(id)object
            defaultValue:(double)defaultValue;

+ (NSInteger)getIntegerValue:(id)object
                defaultValue:(NSInteger)defaultValue;

+ (NSNumber *)getNumberValue:(id)object
                defaultValue:(NSNumber *)defaultValue;

+ (NSURL *)getURLValue:(id)object
          defaultValue:(NSURL *)defaultValue;

+ (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue;

+ (NSMutableArray *)getArrayValue:(id)object
                     defaultValue:(NSMutableArray *)defaultValue;

+ (NSMutableDictionary *)getDictionaryValue:(id)object 
                               defaultValue:(NSMutableDictionary *)defaultValue;



/** 将数据转换成boolean
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return BOOL 转换后的值
 */
+ (BOOL)getBoolValue:(id)object
        defaultValue:(BOOL)defaultValue
                flag:(NSString *)flag;


/** 将数据转换成浮点数
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return CGFloat 转换后的值
 */
+ (CGFloat)getFloatValue:(id)objec
            defaultValue:(CGFloat)defaultValue
                    flag:(NSString *)flag;

/** 将数据转换成双精度浮点数
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return double 转换后的值
 */
+ (double)getDoubleValue:(id)object
            defaultValue:(double)defaultValue
                    flag:(NSString *)flag;

/** 将数据转换成整数
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSInteger    转换后的值
 */
+ (NSInteger)getIntegerValue:(id)object
                defaultValue:(NSInteger)defaultValue
                        flag:(NSString *)flag;

/** 将数据转换成数值对象
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSNumber     转换后的值
 */
+ (NSNumber *)getNumberValue:(id)object
                defaultValue:(NSNumber *)defaultValue
                        flag:(NSString *)flag;

/** 将数据转换成字符串（数字将被转换成字符串）
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSString     转换后的值
 */
+ (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue
                        flag:(NSString *)flag;

/** 将数据转换成数组
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSMutableArray 转换后的值
 */
+ (NSMutableArray *)getArrayValue:(id)object
                     defaultValue:(NSMutableArray *)defaultValue
                             flag:(NSString *)flag;

/** 将数据转换成 hashmap对象（key-value）
 * @param object        原数据对象
 * @param defaultValue  默认值
 * @param flag          标识(debug时显示)
 * @return NSMutableDictionary 转换后的值
 */
+ (NSMutableDictionary *)getDictionaryValue:(id)object
                               defaultValue:(NSMutableDictionary *)defaultValue
                                       flag:(NSString *)flag;

@end