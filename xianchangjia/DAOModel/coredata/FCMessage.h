//
//  FCMessage.h
//  laixin
//
//  Created by apple on 13-12-31.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, FCUserDescription;

enum messageTypeEnum {
    messageType_text = 1,
    messageType_image = 2,
    messageType_map = 3,
    };

@interface FCMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * messageStatus;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSDate * sentDate;
@property (nonatomic, retain) NSString * text;
/**
 *  type  1: text
          2: image
          3: map
 */
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) FCUserDescription *messageUser;

@end
