//
//  XCJApplication.m
//  laixin
//
//  Created by apple on 14-2-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJApplication.h"

@implementation XCJApplication

- (void)sendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
    }
    [super sendEvent:event];
}

@end
