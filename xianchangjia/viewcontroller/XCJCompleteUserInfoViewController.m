//
//  XCJCompleteUserInfoViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJCompleteUserInfoViewController.h"
#import "XCJSuperViewController.h"

@interface XCJCompleteUserInfoViewController ()<UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewAccessibilityDelegate>

@end

@implementation XCJCompleteUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


-(IBAction)popThisView:(id)sender
{
    [self popCurrentViewController];
}

-(IBAction)OpenGallery:(id)sender
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
