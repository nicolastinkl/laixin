//
//  FCBeInviteGroup.h
//  laixin
//
//  Created by apple on 14-1-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCUserDescription;

@interface FCBeInviteGroup : NSManagedObject

@property (nonatomic, retain) NSString * groupID;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * groupJson;
@property (nonatomic, retain) NSDate * beaddTime;
@property (nonatomic, retain) FCUserDescription *fcBeinviteGroupShips;

@end
