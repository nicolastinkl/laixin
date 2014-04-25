//
//  ModelArray.m
//  MolonFrame
//
//  Created by Molon on 13-10-25.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ModelArray.h"
#import "Model.h"

@interface ModelArray()

- (void)initModelClass;

@end

@implementation ModelArray

- (id)init
{
    self = [super init];
    if (self) {
        self.array = [NSMutableArray arrayWithCapacity:1];
        [self initModelClass];
    }
    return self;
}

- (void)initModelClass
{
    self.modelClass = nil;
}

- (void)dealloc
{
    [self removeAllObjects];
}

+ (instancetype)turnObject:(NSArray*)dict
{
    ModelArray *modelArray = [[self alloc]init];
    
    //遍历并且根据modelClass来处理内部数据
    for (id aModel in dict) {
        if ([aModel isKindOfClass:[NSDictionary class]]) {
            [modelArray addObject:[modelArray.modelClass turnObject:aModel]];
        }else{
            NSLog(@"数据非DICT:%@",aModel);
        }
    }
    
    return modelArray;
}

+ (instancetype)turnObjectCore:(NSArray*)dict
{
    ModelArray *modelArray = [[self alloc]init];
    
    //遍历并且根据modelClass来处理内部数据
    for (id aModel in dict) {
        [modelArray addObject:aModel];
    }
    return modelArray;
    
}
//重新定义
- (void)turnObject:(NSArray*)dict
{
    [self removeAllObjects];
    //遍历并且根据modelClass来处理内部数据
    for (id aModel in dict) {
        if ([aModel isKindOfClass:[NSDictionary class]]) {
            [self addObject:[self.modelClass turnObject:aModel]];
        }else{
            NSLog(@"数据非DICT:%@",aModel);
        }
    }
}

- (void)turnObjectCore:(NSArray*)dict
{
    //遍历并且根据modelClass来处理内部数据
    for (id aModel in dict) {
        [self addObject:aModel];
    }
}

#pragma -
#pragma mark 一些NSArray的常用方法,里面调用了KVO的Array Accessors
- (NSUInteger)count
{
    return [self countOfArray];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self objectInArrayAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    return [self.array indexOfObject:anObject];
}
//使得可以使用[index]语法
- (id)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0)
{
	return [self.array objectAtIndexedSubscript:idx];
}

- (NSString*)description
{
    return [self.array description];
}

#pragma -
#pragma mark 一些NSMutableArray的常用方法,里面调用了KVO的Array Accessors

- (BOOL)isObjectValid:(id)anObject
{
    if ([anObject isMemberOfClass:self.modelClass]) {
        if ([anObject isKindOfClass:[Model class]]) { //根本设定的就不是Model的子类，重置modelClass为nil
            return YES;
        }else{
            NSLog(@"modelClass不是Model的子类:%@",self.modelClass);
            return NO;
        }
    }
    return NO;
}

- (void)addObject:(id)anObject
{
    [self insertObject:anObject atIndex:self.array.count];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if ([self isObjectValid:anObject]&&[self isContinueInsertObjectAtIndex:index withObject:anObject]){
        [self insertObject:anObject inArrayAtIndex:index];
        [self afterInsertObjectAtIndex:index withObject:anObject];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if ((NSInteger)index>((NSInteger)self.count)-1) {
        return;
    }
    id object = self.array[index];
    if ([self isContinueRemoveObjectAtIndex:index withObject:object]) {
        [self removeObjectFromArrayAtIndex:index];
        [self afterRemoveObjectAtIndex:index withObject:object];
    }
}

- (void)removeLastObject
{
    [self removeObjectAtIndex:self.array.count-1];
}

- (void)removeAllObjects
{
    for (NSUInteger i=0; i<self.array.count; i++) {
        [self removeObjectAtIndex:i];
    }
}

//一般不用这个
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self removeObjectAtIndex:index];
    [self insertObject:anObject atIndex:index];
}

//使得可以使用[index]=??语法
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0)
{
    [self insertObject:obj atIndex:idx];
}

#pragma mark - 方便自定在对象被添加和删除之后执行的操作,且可根据返回值定义是否继续操作

- (void)afterInsertObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    
}

- (void)afterRemoveObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    
}

- (BOOL)isContinueInsertObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    return YES;
}

- (BOOL)isContinueRemoveObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    return YES;
}

#pragma mark KVO Array Accessors

//get 必须存在
- (NSUInteger)countOfArray
{
    return [self.array count];
}

- (id)objectInArrayAtIndex:(NSUInteger)idx
{
    return [self.array objectAtIndex:idx];
}

//set
- (void)insertObject:(id)anObject inArrayAtIndex:(NSUInteger)idx
{
    [self.array insertObject:anObject atIndex:idx];
}

- (void)removeObjectFromArrayAtIndex:(NSUInteger)idx
{
    [self.array removeObjectAtIndex:idx];
}

- (void)replaceObjectInArrayAtIndex:(NSUInteger)index
                         withObject:(id)anObject {
    [self.array replaceObjectAtIndex:index withObject:anObject];
}

//下面俩不用
//- (void)insertArray:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
//    [self.array insertObjects:array atIndexes:indexes];
//}

//- (void)removeArrayAtIndexes:(NSIndexSet *)indexes {
//    [self.array removeObjectsAtIndexes:indexes];
//}

#pragma -
#pragma mark Fast Enumeration implementation
//此特性可让此类被for in
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	NSUInteger count = 0;
	
	if(state->state == 0)
	{
		state->mutationsPtr = &state->extra[0];
	}
	
	NSUInteger listCount = [self count];
	if(state->state < listCount)
	{
		state->itemsPtr = buffer;
		while((state->state < listCount) && (count < len))
		{
			buffer[count] = [self objectAtIndex:state->state];
			state->state++;
			count++;
		}
	}
	else
	{
		count = 0;
	}
	
	return count;
}


@end
