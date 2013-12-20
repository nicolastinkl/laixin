//
//  ChatList.h
//  ISClone
//
//  Created by Molon on 13-12-2.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ModelArray.h"

extern NSString * const ChatListNeedUpdateToalUnreadCountNotification;

@class Chat;
@interface ChatList : ModelArray

+ (instancetype)shareInstance;
//从本地存储获取数据
- (void)getDataFromLocalDB;
//排序
- (void)sortWithAscending:(BOOL)asc;
//得到其根据排序应该会被放置的位置
- (NSUInteger)indexShouldBeSetInListWithChat:(Chat*)chat ascending:(BOOL)asc;
//添加Chat,内部会根据排序标识，放置到相应位置(不会重排以前的。)
- (void)addChat:(Chat*)chat ascending:(BOOL)asc;

@end
