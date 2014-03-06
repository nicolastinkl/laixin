//
//  XCJBuySurityViewController.m
//  laixin
//
//  Created by apple on 3/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJBuySurityViewController.h"
#import "XCAlbumAdditions.h"
#import "UIViewController+Indicator.h"
#import "UINavigationController+SGProgress.h"

@interface XCJBuySurityViewController ()<UIWebViewDelegate>

@end

@implementation XCJBuySurityViewController

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
    self.title = @"支付";
    UIWebView * webview = (UIWebView *) [self.view subviewWithTag:1];
    [webview loadRequest:[[NSURLRequest alloc] initWithURL:self.BuyUrl]];
    [self.navigationController showSGProgressWithDuration:10.0f andTintColor:[UIColor whiteColor]];
//    [self.view showIndicatorViewLargeBlue];
    //    - (void)loadRequest:(NSURLRequest *)request;
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self.navigationController finishSGProgress];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationController finishSGProgress];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showErrorText:@"加载失败"];
    [self.navigationController finishSGProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
