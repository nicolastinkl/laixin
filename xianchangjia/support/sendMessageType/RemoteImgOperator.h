//
//  RemoteImgOperator.h
//  RemoteImgListOperatorDemo
//
//  Created by tinkl on 14-1-7.
//  Copyright (c) 2014年 tinkl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RemoteImgOperatorDelegate;
@interface RemoteImgOperator : NSObject

@property (unsafe_unretained) id<RemoteImgOperatorDelegate>delegate;

- (BOOL)sendMessage:(NSString *)strGUID withDict:(NSMutableDictionary * ) dict;
- (BOOL)sendMessage:(NSString *)strGUID withDict:(NSMutableDictionary * ) dict progressDelegate:(id)progress;

- (void)cancelRequest;

- (void)setProgressDelegate:(id)progress;

- (id)getProgressDelegate;

@end

@protocol RemoteImgOperatorDelegate <NSObject>

- (void)sendMessage:(RemoteImgOperator *)oper sendMsgSuccess:(NSMutableDictionary *) dict fromGuid:(NSString *)guid;
- (void)sendMessage:(RemoteImgOperator *)oper sendMsgFailed:(NSMutableDictionary *) dict fromGuid:(NSString *)guid;

@end