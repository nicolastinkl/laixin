//
//  XCJPayInfo.m
//  laixin
//
//  Created by apple on 3/7/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJPayInfo.h"
#import "DataHelper.h"

@implementation XCJPayInfo



@end


@implementation LocationInfo

-(id) initWithJSONObject:(NSDictionary*) jsonDict
{
    self=[super init];
	if(self)
	{
		self.groupname = [DataHelper getStringValue:jsonDict[@"groupname"] defaultValue:@""];
        self.gid = [DataHelper getStringValue:jsonDict[@"gid"] defaultValue:@""];
        
        NSDictionary * show_infoDict = jsonDict[@"show_info"];
        self.ktvName = [DataHelper getStringValue:show_infoDict[@"ktvName"] defaultValue:@""];
        self.location = [DataHelper getStringValue:show_infoDict[@"location"] defaultValue:@""];
        self.addressName = [DataHelper getStringValue:show_infoDict[@"addressName"] defaultValue:@""];
        self.phone = [DataHelper getArrayValue:show_infoDict[@"phone"] defaultValue:nil];
        self.log = [DataHelper getNumberValue:show_infoDict[@"log" ] defaultValue:@0];
        self.lng = [DataHelper getNumberValue:show_infoDict[@"lng" ] defaultValue:@0];
    }
    return self;
}


@end

@implementation roomInfo


-(id) initWithJSONObject:(NSDictionary*) jsonDict
{
    self=[super init];
	if(self)
	{
        self.productdesc = [DataHelper getStringValue:jsonDict[@"productdesc"] defaultValue:@""];
        self.productname = [DataHelper getStringValue:jsonDict[@"productname"] defaultValue:@""];
        self.amount = [DataHelper getIntegerValue:jsonDict[@"amount"] defaultValue:0];
        self.group_id = [DataHelper getIntegerValue:jsonDict[@"group_id"] defaultValue:0];
        self.mid = [DataHelper getIntegerValue:jsonDict[@"mid"] defaultValue:0];
        self.ex_people_amount = [DataHelper getIntegerValue:jsonDict[@"ex_people_amount"] defaultValue:0];
        self.time = [DataHelper getDoubleValue:jsonDict[@"time"] defaultValue:0];
        
        NSDictionary * show_infoDict = jsonDict[@"show_info"];
        self.type = [DataHelper getStringValue:show_infoDict[@"type"] defaultValue:@""];
        self.name = [DataHelper getStringValue:show_infoDict[@"name"] defaultValue:@""];
        self.parensNumber = [DataHelper getStringValue:show_infoDict[@"parensNumber"] defaultValue:@""];
        self.lowprice = [DataHelper getStringValue:show_infoDict[@"lowprice"] defaultValue:@""];
        
        
        
    }
    return self;
}

@end
