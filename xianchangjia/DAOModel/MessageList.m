//
//  MessageList.m
//  ISClone
//
//  Created by Molon on 13-12-9.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MessageList.h"
#import "Message.h"

@implementation MessageList

- (void)initModelClass
{
    self.modelClass = [Message class];
}

#pragma mark - other common
- (void)sortWithAscending:(BOOL)asc
{
    //根据最后时间排序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:asc];
    [self.array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
