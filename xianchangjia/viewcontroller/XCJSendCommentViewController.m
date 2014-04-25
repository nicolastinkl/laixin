//
//  XCJSendCommentViewController.m
//  xianchangjia
//
//  Created by apple on 13-12-17.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJSendCommentViewController.h"
#import "XCAlbumAdditions.h"

@interface XCJSendCommentViewController ()

@end

@implementation XCJSendCommentViewController
@synthesize talk_id,scene_id,touserid;
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
    self.title = @"写评论";
    
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(CancelComentClick:)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(SendComentClick:)];
    self.navigationItem.rightBarButtonItem = right;
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UITextView * textview = [self.view subviewWithTag:1];
        [textview becomeFirstResponder];
    });
}

-(IBAction)CancelComentClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(IBAction) SendComentClick:(id) sender
{
    UITextView * textview = [self.view subviewWithTag:1];
    NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
	[postdata setObject:[NSNumber numberWithLongLong:self.talk_id] forKey:@"post_id"];
	[postdata setObject:[NSNumber numberWithInt:self.touserid] forKey:@"to_user"];
	[postdata setObject:[NSNumber numberWithInt:self.scene_id] forKey:@"scene_id"];
    [postdata setObject:[NSNumber numberWithInt:0] forKey:@"stopsync"];
	[postdata setObject:textview.text forKey:@"content"];
	[[GlobalData sharedGlobalData] addCommentCommandInfo:postdata];
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"post_comment" Action:@"add_comment" success:^(id obj) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } error:^(NSInteger index) {
        SLLog(@" comment error ");
    } failure:^(NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
