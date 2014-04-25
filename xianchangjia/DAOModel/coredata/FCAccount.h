//
//  FCAccount.h
//  laixin
//
//  Created by apple on 14-1-14.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, FCUserDescription;

@interface FCAccount : NSManagedObject

@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * sessionid;
@property (nonatomic, retain) NSString * websocketURL;
@property (nonatomic, retain) id userJson;
@property (nonatomic, retain) NSSet *conversation;
@property (nonatomic, retain) FCUserDescription *fcindefault;
@end

@interface FCAccount (CoreDataGeneratedAccessors)

- (void)addConversationObject:(Conversation *)value;
- (void)removeConversationObject:(Conversation *)value;
- (void)addConversation:(NSSet *)values;
- (void)removeConversation:(NSSet *)values;

@end
