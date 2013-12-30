//
//  XCJSuperViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJSuperViewController.h"

@interface XCJSuperViewController ()

@end

@implementation XCJSuperViewController

/**
 *  MARK : this  a  super viewcontroller to pop that childs views
 */
- (void) popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)popCurrentViewControllerSender:(id)sender
{
    [self popCurrentViewController];
}

@end
