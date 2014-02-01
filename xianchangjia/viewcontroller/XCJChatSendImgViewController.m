//
//  XCJChatSendImgViewController.m
//  laixin
//
//  Created by apple on 14-1-21.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJChatSendImgViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"

@interface XCJChatSendImgViewController ()


@end

@implementation XCJChatSendImgViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)sureClick:(id)sender {
    [self cancelClick:nil];
    [self.delegate SendImageURL:self.imageviewSource withKey:self.key];
}
- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.imageview.image = [UIImage imageWithContentsOfFile:self.imageviewURL];
	// Do any additional setup after loading the view.
    [self.imageview setImage:_imageviewSource];
    
    UIView * view =  [self.view subviewWithTag:1];
    view.top = self.view.height - view.height;
    
    UIButton * cancelButton = (UIButton * )[view subviewWithTag:1];
    UIButton * Sendbutton = (UIButton * )[view subviewWithTag:2];
    [cancelButton bootstrapStyle];
    [Sendbutton infoStyle];
    
    cancelButton.left = 10;
    Sendbutton.left = self.view.width - Sendbutton.width - 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
