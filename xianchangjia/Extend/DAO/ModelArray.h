//
//  ModelArray.h
//  MolonFrame
//
//  Created by Molon on 13-10-25.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>

//因为NSMutableArray不适宜继承，所以不能用其作为父类
@interface ModelArray : NSObject<NSFastEnumeration>

@property (nonatomic,assign,readonly) NSUInteger count;
//实际存储对象的Array
@property (nonatomic,strong) NSMutableArray *array;
//当前ModelArray里所保存的对象的Model类型
@property (nonatomic,weak) Class modelClass;

+ (instancetype)turnObject:(NSArray*)dict;

+ (instancetype)turnObjectCore:(NSArray*)dict;

- (void)turnObject:(NSArray*)dict;
- (void)turnObjectCore:(NSArray*)dict;
//模拟NSArray的一些常用方法
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);//使得可以使用[index]语法
- (NSUInteger)indexOfObject:(id)anObject;

//模拟NSMutableArray的一些常用方法
- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeAllObjects;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);//使得可以使用[index]=??语法


//其他方法
- (BOOL)isObjectValid:(id)anObject; //是否是设置的类对象

@end
