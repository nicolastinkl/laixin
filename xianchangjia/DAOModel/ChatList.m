//
//  ChatList.m
//  ISClone
//
//  Created by Molon on 13-12-2.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ChatList.h"
#import "Chat.h"
#import "MessageManager.h"

NSString * const ChatListNeedUpdateToalUnreadCountNotification = @"com.molon.notification.ChatListNeedUpdateToalUnreadCountNotification";

@implementation ChatList

- (void)initModelClass
{
    self.modelClass = [Chat class];
}

+ (instancetype)shareInstance {
    static ChatList *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc]init];
    });
    return _shareInstance;
}

#pragma mark 从本地存储获取最近联系人列表
- (void)getDataFromLocalDB
{
    //获取聊天列表
    NSArray *data =
    @[
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/1600725215/180/5628483622/1",
          @"name":@"天若有情天亦老天若有情天亦老天若有情天亦老天若有情天亦老",
          @"latestTime":@1386039357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          @"unreadCount":@0
          },
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/3217545835/50/40012531405/0",
          @"name":@"司空滢渟9945",
          @"latestTime":@1386039358,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@1,
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3136245353/50/40019576599/1",
          @"name":@"细月飞翔",
          @"latestTime":@1386039257,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@0
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1",
          @"name":@"炒股--达人",
          @"latestTime":@1386029357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@3
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/2635512141/50/5670775907/1",
          @"name":@"都是大胖子9545",
          @"latestTime":@1386019357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@0
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3785688681/50/40034786628/0",
          @"name":@"天若有情天亦老天若有情天亦老天若有情天亦老天若有情天亦老",
          @"latestTime":@1386019356,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          @"unreadCount":@0
          },
      @{
          @"avatarURL":@"http://tp1.sinaimg.cn/2797047240/50/5631339507/1",
          @"name":@"司空滢渟9945",
          @"latestTime":@1386009357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@1
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/2635856693/50/22860186707/1",
          @"name":@"细月飞翔",
          @"latestTime":@1385039357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@0
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/2931674105/50/5680520407/0",
          @"name":@"炒股--达人",
          @"latestTime":@1384039357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@3
          },
      @{
          @"avatarURL":@"http://tp1.sinaimg.cn/2687987360/50/40030144204/1",
          @"name":@"都是大胖子9545",
          @"latestTime":@1383039357,
          @"latestMessage":@"昨天你睡觉的时候在干什么。。",
          @"unreadCount":@0
          },
      ];
    [self turnObject:data];
}

#pragma mark 添加或者删除需要执行的
- (void)afterInsertObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    [self addObserverOfChat:object];
    //通知需要更新总的unreadCount，一般是用于tabBar
    [[NSNotificationCenter defaultCenter] postNotificationName:ChatListNeedUpdateToalUnreadCountNotification object:nil userInfo:nil];
}

- (void)afterRemoveObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    [self removeObserverOfChat:object];
    //通知需要更新总的unreadCount，一般是用于tabBar
    [[NSNotificationCenter defaultCenter] postNotificationName:ChatListNeedUpdateToalUnreadCountNotification object:nil userInfo:nil];
}

#pragma mark Add Or Remove Observer
- (void)addObserverOfChat:(Chat*)chat
{
	[chat addObserver:self forKeyPath:@"latestTime" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	[chat addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserverOfChat:(Chat*)chat
{
	@try {
		[chat removeObserver:self forKeyPath:@"latestTime"];
		[chat removeObserver:self forKeyPath:@"unreadCount"];
	}
	@catch (NSException *exception) {
		NSLog(@"Unregister observer: %@", chat);
	}
	@finally {
		
	}
}


#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	Chat *chat=(Chat*)object;
    
    BOOL isNeedUpdateDB = NO;
	
    if ([keyPath isEqualToString:@"latestTime"]) {
        isNeedUpdateDB = YES;
	}else if ([keyPath isEqualToString:@"unreadCount"]) {
        //通知需要更新总的unreadCount，一般是用于tabBar
        [[NSNotificationCenter defaultCenter] postNotificationName:ChatListNeedUpdateToalUnreadCountNotification object:nil userInfo:nil];
        
        //只有0才更新，因为其他情况latestTime也会更新，防止这边重复写入数据库。
		if (chat.unreadCount <= 0) {
			NSNumber *oldCount = [change objectForKey:NSKeyValueChangeOldKey];
			if (chat.unreadCount != [oldCount unsignedIntegerValue]) {
                isNeedUpdateDB = YES;
			}
		}
	}
    
    if (isNeedUpdateDB) {
        [[MessageManager sharedMessageManager] updateChat:chat];
    }
}

#pragma mark - other common
- (void)sortWithAscending:(BOOL)asc
{
    //根据最后时间排序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"latestTime" ascending:asc];
    [self.array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

//根据latestTime来判断其若加入到列表中应当处于的index
- (NSUInteger)indexShouldBeSetInListWithChat:(Chat*)chat ascending:(BOOL)asc
{
    //降序排数组
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"latestTime" ascending:asc];
    //一个临时副本
    NSMutableArray *array = [self.array mutableCopy];
    if (![array containsObject:chat]) {
        [array addObject:chat];
    }
    
    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return [array indexOfObject:chat];
}

- (void)addChat:(Chat*)chat ascending:(BOOL)asc
{
    NSUInteger index = [self indexShouldBeSetInListWithChat:chat ascending:asc];
    [self insertObject:chat atIndex:index];
}

@end
