//
//  Conversation.m
//  laixin
//
//  Created by apple on 14-1-1.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "Conversation.h"
#import "FCAccount.h"
#import "FCMessage.h"


@implementation Conversation

@dynamic badgeNumber;
@dynamic facebookId;
@dynamic facebookName;
@dynamic lastMessage;
@dynamic lastMessageDate;
@dynamic messageId;
@dynamic messageStutes;
@dynamic messageType;
@dynamic account;
@dynamic messages;

- (void)addMessagesObject:(FCMessage *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"messages"] addObject:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeMessagesObject:(FCMessage *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"messages"] removeObject:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addMessages:(NSSet *)value {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"messages"] unionSet:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMessages:(NSSet *)value {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"messages"] minusSet:value];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
