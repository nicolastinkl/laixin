//
//  XCJNearbyInfoViewContr.h
//  laixin
//
//  Created by apple on 2/28/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCJGroupPost_list.h"

@interface XCJNearbyInfoViewContr : UIViewController

@property (nonatomic,strong)  XCJGroup_list * groupinfo;
-(void) initallContr:( XCJGroup_list * ) groupinfo;
@end
