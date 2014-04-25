//
//  XCJAboutViewController.m
//  laixin
//
//  Created by apple on 14-1-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAboutViewController.h"
#import "XCAlbumAdditions.h"

@interface XCJAboutViewController ()

@end

@implementation XCJAboutViewController

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
    /* serviceview = 1,
     privateview = 2,
     aboutview = 3,*/
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
//    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

	// Do any additional setup after loading the view.
    UIWebView * webview = (UIWebView *) [self.view subviewWithTag:1];
    switch (self.viewTypeIndex) {
        case serviceview:
        {
            NSString * str =  [dictionary valueForKey:@"services"];
            [webview loadHTMLString:str baseURL:nil];
        }
            break;
        case privateview:
            
        {
            NSString * str =  [dictionary valueForKey:@"private"];
            [webview loadHTMLString:str baseURL:nil];
        }
            break;
        case aboutview:
            
        {
            NSString * str =  [dictionary valueForKey:@"about"];
            [webview loadHTMLString:str baseURL:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
