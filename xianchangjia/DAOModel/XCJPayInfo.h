//
//  XCJPayInfo.h
//  laixin
//
//  Created by apple on 3/7/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"


@interface XCJPayInfo : NSObject

@end


@interface roomInfo : NSObject

@property (copy, nonatomic  ) NSString     *name;
@property (copy, nonatomic  ) NSString     *type;
@property (copy, nonatomic  ) NSString     *lowprice;
@property (copy, nonatomic  ) NSString     *parensNumber;
@property (nonatomic,assign ) int          amount;
@property (nonatomic,assign ) int          group_id;
@property (nonatomic,assign ) int          mid;
@property (nonatomic,assign ) int          ex_people_amount;
@property (copy, nonatomic  ) NSString     *productdesc;
@property (copy, nonatomic  ) NSString     *productname;
@property (assign, nonatomic) double       time;

-(id) initWithJSONObject:(NSDictionary*) jsonDict;

@end

@interface LocationInfo : NSObject

@property (copy, nonatomic) NSString *groupname;
@property (copy, nonatomic) NSString *gid;
@property (copy, nonatomic) NSString *ktvName;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *addressName;
@property (copy, nonatomic) NSArray *phone;
@property (copy, nonatomic) NSNumber *lng;
@property (copy, nonatomic) NSNumber *log;
-(id) initWithJSONObject:(NSDictionary*) jsonDict;
@end