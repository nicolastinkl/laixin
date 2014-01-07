//
//  UIView+Indicator.h
//  XianchangjiaAlbum
//
//  Created by JIJIA &&&&& ljh on 12-12-17.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Indicator)

- (void)showIndicatorView;

- (void)showIndicatorViewAtpoint:(CGPoint)point;

- (void)showIndicatorViewWithStyle:(UIActivityIndicatorViewStyle)style;

- (void)showIndicatorViewAtpoint:(CGPoint)point indicatorStyle:(UIActivityIndicatorViewStyle)style;

- (void)hideIndicatorView;


- (void)showIndicatorViewGary;
- (void)showIndicatorViewBlue;
- (void)showIndicatorViewLargeBlue;
- (BOOL)isIndicatorViewLargeBlueRunning;
- (void)hideIndicatorViewBlueOrGary;

@end
