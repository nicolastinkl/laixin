//
//  ZAActivityBar.h
//
//  Created by Zac Altman on 24/11/12.
//  Copyright (c) 2012 Zac Altman. All rights reserved.
//
//  Heavily influenced by SVProgressHUD by Sam Vermette
//  Pieces of code may have been directly copied.
//  Sam is a legend!
//  https://github.com/samvermette/SVProgressHUD
//

#import <UIKit/UIKit.h>

#define ios7BlueColor               [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

// Visual Properties
#define BAR_COLOR  [UIColor colorWithRed:0.157 green:0.607 blue:1.000 alpha:0.830]// [[UIColor blackColor] colorWithAlphaComponent:0.5f]
#define HEIGHT 40.0f
#define PADDING 10.0f

// Best not to change these
#define SPINNER_SIZE 24.0f
#define ICON_OFFSET (HEIGHT - SPINNER_SIZE) / 2.0f
#define DEFAULT_ACTION @"defaultAction"

@interface ZAActivityBar : UIView

///////////////////////////////////////////////////////////////////////

// Properties

+ (void) setLocationBottom;
+ (void) setLocationTabBar;
+ (void) setLocationNavBar;

///////////////////////////////////////////////////////////////////////

// Basic use

+ (void) show;
+ (void) dismiss;

+ (void) showWithStatus:(NSString *)status;
+ (void) showSuccessWithStatus:(NSString *)status;
+ (void) showErrorWithStatus:(NSString *)status;
+ (void) showImage:(UIImage *)image status:(NSString *)status;

///////////////////////////////////////////////////////////////////////

// Advanced Use

+ (void) showForAction:(NSString *)action;
+ (void) dismissForAction:(NSString *)action;

+ (void) showWithStatus:(NSString *)status forAction:(NSString *)action;
+ (void) showSuccessWithStatus:(NSString *)status forAction:(NSString *)action;
+ (void) showErrorWithStatus:(NSString *)status forAction:(NSString *)action;
+ (void) showImage:(UIImage *)image status:(NSString *)status forAction:(NSString *)action;

///////////////////////////////////////////////////////////////////////

@end
