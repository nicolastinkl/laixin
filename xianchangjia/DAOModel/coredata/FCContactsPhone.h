//
//  FCContactsPhone.h
//  laixin
//
//  Created by apple on 14-1-13.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FCUserDescription;

@interface FCContactsPhone : NSManagedObject

@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * phoneName;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * hasLaixin;
@property (nonatomic, retain) FCUserDescription *phoneFCuserDesships;

@end
