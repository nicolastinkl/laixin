//
//  FCUserDescription.h
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface FCUserDescription : NSManagedObject
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *headpic;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *background_image;
@property (nonatomic, strong) NSString *marriage;
@property (nonatomic, strong) NSNumber* sex;
@property (nonatomic, strong) NSNumber* height;
@property (nonatomic, strong) NSNumber* create_time;

@end
