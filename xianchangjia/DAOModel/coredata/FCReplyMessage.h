//
//  FCReplyMessage.h
//  laixin
//
//  Created by apple on 14-1-11.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ConverReply;

@interface FCReplyMessage : NSManagedObject

@property (nonatomic, retain) NSString * postid;
@property (nonatomic, retain) NSString * replyid;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * typeReply;
@property (nonatomic, retain) id jsonStr;
@property (nonatomic, retain) ConverReply *newRelationship;

@end
