//
//  FCBeInviteGroup.h
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCHomeGroupMsg, FCUserDescription;

@interface FCBeInviteGroup : NSManagedObject

@property (nonatomic, retain) NSDate * beaddTime;
@property (nonatomic, retain) NSString * groupID;
@property (nonatomic, retain) NSString * groupJson;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) FCUserDescription *fcBeinviteGroupShips;
@property (nonatomic, retain) FCHomeGroupMsg *fcBeinviteGroupInfo;

@end
