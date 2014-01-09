//
//  FCBeAddFriend.h
//  laixin
//
//  Created by apple on 14-1-9.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCUserDescription;

@interface FCBeAddFriend : NSManagedObject

@property (nonatomic, retain) NSDate * addTime;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSNumber * hasAdd;
@property (nonatomic, retain) FCUserDescription *beAddFriendShips;

@end
