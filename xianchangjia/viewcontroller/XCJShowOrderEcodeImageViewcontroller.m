//
//  XCJShowOrderEcodeImageViewcontroller.m
//  laixin
//
//  Created by tinkl on 24/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJShowOrderEcodeImageViewcontroller.h"
#import "XCAlbumAdditions.h"
#import "NSString+Addition.h"
#import "NSData+SRB64Additions.h"
#import "QRCodeGenerator.h"


@interface XCJShowOrderEcodeImageViewcontroller ()

@end

@implementation XCJShowOrderEcodeImageViewcontroller

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
    
    self.title = @"订单二维码";
    //NSString * stringkey = [NSString stringWithFormat:@"%@%@",self.orderID,kAppkeyForWeChat];
    //NSData * data = [stringkey dataUsingEncoding:NSUTF8StringEncoding];
//    SLog(@"base64 : %@", [data newStringInBase64FromData]);
    UIImage * image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@",self.orderID] imageSize:216.0f];
    [((UIImageView*)[self.view subviewWithTag:1]) setImage:image];
    
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
