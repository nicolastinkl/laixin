//
//  FCFriends.h
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCUserDescription;

@interface FCFriends : NSManagedObject

@property (nonatomic, retain) NSString * friendID;
@property (nonatomic, retain) FCUserDescription *friendRelation;

@end
