//
//  ConverReply.h
//  laixin
//
//  Created by apple on 14-1-11.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCReplyMessage;

@interface ConverReply : NSManagedObject

@property (nonatomic, retain) NSNumber * badgeNumber;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * postid;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSSet *fcreplymesgships;
@end

@interface ConverReply (CoreDataGeneratedAccessors)

- (void)addFcreplymesgshipsObject:(FCReplyMessage *)value;
- (void)removeFcreplymesgshipsObject:(FCReplyMessage *)value;
- (void)addFcreplymesgships:(NSSet *)values;
- (void)removeFcreplymesgships:(NSSet *)values;

@end
