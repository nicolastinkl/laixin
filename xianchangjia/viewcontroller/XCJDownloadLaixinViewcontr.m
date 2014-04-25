//
//  XCJDownloadLaixinViewcontr.m
//  laixin
//
//  Created by tinkl on 16/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDownloadLaixinViewcontr.h"
#import "XCAlbumAdditions.h"
#import "QRCodeGenerator.h"

@interface XCJDownloadLaixinViewcontr ()<UIActionSheetDelegate>

@end

@implementation XCJDownloadLaixinViewcontr

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

    /*!
     *  download url
     *
     *   http://laixinle.com/download
     *
     */
    self.title = @"分享地址";

     ((UIImageView *)[self.view subviewWithTag:1]).image =  [QRCodeGenerator qrImageForString:@"http://laixinle.com/download" imageSize:216.0f];
    
    
}

-(IBAction)sharewithURL:(id)sender
{
    UIActionSheet * sheetview = [[UIActionSheet alloc] initWithTitle:@"复制链接地址，分享给朋友" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制" otherButtonTitles:nil, nil];
    [sheetview showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:@"http://laixinle.com/download"];
        [UIAlertView showAlertViewWithMessage:@"成功复制到剪切板"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
