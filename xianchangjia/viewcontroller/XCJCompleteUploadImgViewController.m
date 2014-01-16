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
#import "UIAlertViewAddition.h"


@interface XCJCompleteUploadImgViewController ()< UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    NSString * ImageFile;
}

@property (weak, nonatomic) IBOutlet UIButton * takeButton;

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
    [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_account_HasLogin];
    [USER_DEFAULT synchronize];
    NSString * strheadpic = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic];
    if (strheadpic.length < 5) {
        [UIAlertView showAlertViewWithMessage:@"请设置头像"];
        return;
    }
    // connection of websocket server
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateData" object:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
  
    }];
    
    //  xx:十五号
    //  xx: 发来一张图
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
    
    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
    img.layer.cornerRadius = img.width/2;
    [img.layer setMasksToBounds:YES];
    
    double delayInSeconds = .3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self openGallery:nil];
    });
}

-(IBAction)openGallery:(id)sender
{
    
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:@"选择头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    action.tag = 3;
    [action showInView:self.view];
    
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        imagePicker.allowsEditing  = YES;
//        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
//        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//        [self presentViewController:imagePicker animated:YES completion:^{
//        }];
//    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{   //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                camera.delegate = self;
                camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                camera.allowsEditing = YES;
                [self presentViewController:camera animated:YES completion:nil];
            }
        }
            break;
        case 1:{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
                photoLibrary.delegate = self;
                photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                photoLibrary.allowsEditing = YES;
                [self presentViewController:photoLibrary animated:YES completion:nil];
            }
        }
            break;
        default:
            break;
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
    
    [self.takeButton setBackgroundImage:nil forState:UIControlStateNormal];
  
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
    [SVProgressHUD showWithStatus:@"正在上传头像..."];
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
            
            
            
            [USER_DEFAULT setValue:stringURL forKey:KeyChain_Laixin_account_user_headpic];
            [UIView animateWithDuration:0.3 animations:^{
                UIImageView * successImg = (UIImageView *) [self.view subviewWithTag:3];
                [successImg setHidden:NO];
            }];
            [img hideIndicatorViewBlueOrGary];
            [self.takeButton setBackgroundImage:nil forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
            NSDictionary * parames = @{@"headpic":stringURL};
            //nick, signature,sex, birthday, marriage, height
//            [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
//            } failure:^(MLRequest *request, NSError *error) {
//            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [img hideIndicatorViewBlueOrGary];
        [SVProgressHUD dismiss];
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
