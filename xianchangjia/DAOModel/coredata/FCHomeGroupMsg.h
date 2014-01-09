//
//  FCHomeGroupMsg.h
//  laixin
//
//  Created by apple on 14-1-9.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FCHomeGroupMsg : NSManagedObject

@property (nonatomic, retain) NSString * gid;
@property (nonatomic, retain) NSString * gName;
@property (nonatomic, retain) NSString * gCreatorUid;
@property (nonatomic, retain) NSString * gBoard;
@property (nonatomic, retain) NSString * gType;
@property (nonatomic, retain) NSDate * gDate;
@property (nonatomic, retain) NSNumber * gbadgeNumber;

@end
