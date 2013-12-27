//
//  FCUserDescription.h
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCAccount, FCFriends;

@interface FCUserDescription : NSManagedObject

@property (nonatomic, retain) NSString * background_image;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSNumber * create_time;
@property (nonatomic, retain) NSString * headpic;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * marriage;
@property (nonatomic, retain) NSString * nick;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) FCAccount *userDesp;
@property (nonatomic, retain) FCFriends *userDespFriends;

@end
