//
//  XCJFindMMView.h
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCJGroupPost_list.h"

@interface XCJFindMMView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label_des;
-(void) setupThisData:(XCJFindMM_list*) findmmData;
@property (weak, nonatomic) IBOutlet UILabel *label_age;
@property (weak, nonatomic) IBOutlet UIView *view_bg;
@property (weak, nonatomic) IBOutlet UILabel *label_like;
@property (weak, nonatomic) IBOutlet UIView *view_label;
@property ( nonatomic,assign) Boolean  isrequestMedia;
@end
