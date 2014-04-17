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
    messageType_emj = 4,
    messageType_audio = 5,
    messageType_contacts = 6,
    messageType_video = 7,
    messageType_SystemAD = 100,//FIXME:  //系统公告 包括个人信息修改,开始聊天 然后====
    };

@interface FCMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * messageStatus;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSDate   * sentDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSNumber * audioLength;
@property (nonatomic, retain) NSString * videoUrl;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageguid;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * messageSendStatus;   //0 sended,1..sending..2 error

@property (nonatomic, retain) NSString * facebookID; // MessageUSERID
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) FCUserDescription *messageUser;

@end
