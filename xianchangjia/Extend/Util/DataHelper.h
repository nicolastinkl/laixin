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

@end