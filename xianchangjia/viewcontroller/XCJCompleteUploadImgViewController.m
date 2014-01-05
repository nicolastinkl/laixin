//
//  XCJCompleteUploadImgViewController.m
//  laixin
//
//  Created by apple on 13-12-30.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJCompleteUploadImgViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LXAPIController.h"
#import "LXRequestFacebookManager.h"
#import "XCAlbumAdditions.h"
#import "tools.h"
#import "MLNetworkingManager.h"

@interface XCJCompleteUploadImgViewController ()< UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    NSString * ImageFile;
}
@end

@implementation XCJCompleteUploadImgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)completeOperationClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        // connection of websocket server
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(IBAction)openGallery:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.allowsEditing  = YES;
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self performSelectorInBackground:@selector(uploadContent:) withObject:theInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)uploadContent:(NSDictionary *)theInfo {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
    
    NSString * namefile =  [self getMd5_32Bit_String:timeDesc];
    NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSLog(@"Upload Path: %@", filePath);
    NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerEditedImage], 1);
    [webData writeToFile:filePath atomically:YES];
    [self uploadFile:filePath  key:key];
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

- (void)uploadFile:(NSString *)filePath  key:(NSString *)key {
    // setup 1: frist get token
    //http://service.xianchangjia.com/upload/HeadImg?sessionid=5Wnp5qPWgpAhDRK
   
     [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
         if (response) {
             NSString * token =  [response objectForKey:@"token"];
             TokenAPP = token;
             ImageFile = filePath;
             [self uploadImage:filePath token:token];
         }
     } withParems:[NSString stringWithFormat:@"upload/HeadImg?sessionid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
}

-(void) uploadImage:(NSString *)filePath  token:(NSString *)token
{
    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
    [img setImage:[UIImage imageWithContentsOfFile:filePath]];
    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
//        [formData appendPartWithFileData:imageData name:@"user_avatar" fileName:@"me.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSString * stringURL =  [tools getStringValue:[responseObject objectForKey:@"url"] defaultValue:@""];
            NSDictionary * parames = @{@"headpic":stringURL};
            
            [UIView animateWithDuration:0.3 animations:^{
                UIImageView * successImg = (UIImageView *) [self.view subviewWithTag:3];
                [successImg setHidden:NO];
            }];
            [img hideIndicatorViewBlueOrGary];
            //nick, signature,sex, birthday, marriage, height
            [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
               
            } failure:^(MLRequest *request, NSError *error) {
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [img hideIndicatorViewBlueOrGary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self uploadImage:ImageFile token:TokenAPP];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
