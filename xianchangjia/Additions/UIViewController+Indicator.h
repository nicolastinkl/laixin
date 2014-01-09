//
//  UIViewController+UIViewController_Indicator.h
//  xianchangjia
//
//  Created by apple on 13-12-9.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "blocktypedef.h"

#define showErrorInfoWithRetryNotifition @"showErrorInfoWithRetryNotifition"

/**
 *  UIViewController  Cagrote
 */
@interface UIViewController (Indicator)

- (void)showIndicatorView;

- (void)showIndicatorViewAtpoint:(CGPoint)point;

- (void)showIndicatorViewWithStyle:(UIActivityIndicatorViewStyle)style;

- (void)hideIndicatorView:(NSString*)statusContent block:(SLBlockBlock) voidFun;

- (void)hideIndicatorView;

- (void) showErrorInfoWithRetry;

- (void) hiddeErrorInfoWithRetry;

- (void) showErrorText:(NSString * ) message;
- (void) hiddeErrorText;
@end
