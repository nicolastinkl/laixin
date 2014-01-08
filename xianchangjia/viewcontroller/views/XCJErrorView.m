//
//  XCJErrorView.m
//  laixin
//
//  Created by apple on 14-1-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJErrorView.h"
#import "UIViewController+Indicator.h"

@implementation XCJErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)TryClick:(id)sender {
     [[NSNotificationCenter defaultCenter] postNotificationName:showErrorInfoWithRetryNotifition object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
