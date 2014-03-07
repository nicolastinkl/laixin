//
//  UITableViewCell+TKCategory.m
//  laixin
//
//  Created by apple on 3/7/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "UITableViewCell+TKCategory.h"

#import <objc/runtime.h>

NSString * const TkNewAttachmentKey = @"TkNewAttachmentKey";
@implementation UITableViewCell (TKCategory)
@dynamic userInfo;
- (void)setUserInfo:(NSMutableDictionary *)userInfo {
    objc_setAssociatedObject(self, (__bridge const void *)(TkNewAttachmentKey),userInfo,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)userInfo {
    return objc_getAssociatedObject(self, (__bridge const void *)(TkNewAttachmentKey));
}
@end

