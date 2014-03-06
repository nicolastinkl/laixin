//
//  XCJFindRoomViewControl.h
//  laixin
//
//  Created by apple on 3/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface roomInfo : Model

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *lowprice;
@property (copy, nonatomic) NSString *parensNumber;

@end

@interface LocationInfo : Model

@property (copy, nonatomic) NSString *ktvName;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *addressName;
@property (copy, nonatomic) NSArray *phone;
@property (copy, nonatomic) NSNumber *lng;
@property (copy, nonatomic) NSNumber *log;
@end

@interface XCJFindRoomViewControl : UITableViewController

@end
