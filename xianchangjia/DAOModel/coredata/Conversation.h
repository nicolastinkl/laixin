//
//  Conversation.h
//  laixin
//
//  Created by apple on 14-1-1.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


enum messageStutes_type {
    messageStutes_incoming = 1,
    messageStutes_outcoming = 2,
    messageStutes_error = 3,
};

@class FCAccount, FCMessage;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSNumber * badgeNumber;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * facebookName;
@property (nonatomic, retain) id lastMessage;
@property (nonatomic, retain) NSDate * lastMessageDate;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * messageStutes;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSNumber * isMute;
@property (nonatomic, retain) FCAccount *account;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(FCMessage *)value;
- (void)removeMessagesObject:(FCMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
