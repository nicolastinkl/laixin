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
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WebP.h"

@interface XCJCompleteUploadImgViewController ()< UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
}


@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

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

-(IBAction)FindAndFindClick:(id)sender
{
    
    UITextView * text = (UITextView *) [self.view subviewWithTag:10];
    [text resignFirstResponder];
    
    UIButton * button =  (UIButton * )sender;
    button.enabled = NO;
    // start find
    ((UIView *) [self.view subviewWithTag:9]).hidden = NO;
    [self setupCamera];
}

-(IBAction)HiddenKeyboardClick:(id)sender
{
    UITextView * text = (UITextView *) [self.view subviewWithTag:10];
    [text resignFirstResponder];
}


-(IBAction)closeCamera:(id)sender
{
    if (_session) {
        [_session stopRunning];
        [self.preview removeFromSuperlayer];
        _preview = nil;
        _session = nil;
    }
    [UIView animateWithDuration:0.3 animations:^{
        ((UIView *) [self.view subviewWithTag:9]).hidden = YES;
        ((UIButton *) [self.view subviewWithTag:8]).enabled = YES;
    }];
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //_preview.frame =CGRectMake(48,114,225,225);
    _preview.frame =CGRectMake(0,0,320,self.view.height);
    UIView * childview =  [self.view subviewWithTag:9];
    [childview.layer insertSublayer:self.preview atIndex:0];
    // Start
    [_session startRunning];
    
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        if (metadataObject.stringValue.length > 0) {
           
            NSString * stringValueNew = metadataObject.stringValue;
            if([stringValueNew containString:@"[activecode]-"])
            {
                stringValueNew = [stringValueNew stringByReplacingOccurrencesOfString:@"[activecode]-" withString:@""];
                [_session stopRunning];
                [self.preview removeFromSuperlayer];
                _preview = nil;
                _session = nil;
                 
                UITextView * text = (UITextView *) [self.view subviewWithTag:10];
                text.text = stringValueNew;
                ((UIView *) [self.view subviewWithTag:9]).hidden = YES;
                ((UIButton *) [self.view subviewWithTag:8]).enabled = YES;
            }
        };
    }
}


-(IBAction)completeOperationClick:(id)sender
{
    UITextView * text = (UITextView *) [self.view subviewWithTag:10];
    if (text.text.length > 0) {
        if (_session) {            
            [_session stopRunning];
            [self.preview removeFromSuperlayer];
            _preview = nil;
            _session = nil;
        }
        //先激活
        [SVProgressHUD show];
        [[MLNetworkingManager sharedManager] sendWithAction:@"active.do" parameters:@{@"active_code":text.text} success:^(MLRequest *request, id responseObject) {
            //	Result={"active_level":1,"active_by":1}
            if (responseObject) {
                NSDictionary * result = responseObject[@"result"];
                //返回激活等级和激活者的id
                NSInteger level = [DataHelper getIntegerValue:result[@"active_level"] defaultValue:0];
                if (level > 0) {
                    
                }
                
                [SVProgressHUD dismiss];
                NSString * activeByUID =  [DataHelper getStringValue:result[@"active_by"]  defaultValue:@""];
                if (activeByUID.length > 0) {
                    // check this uid is my friends???
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesByNetCompletion:^(id response, NSError *error) {
                        [[[LXAPIController sharedLXAPIController]  chatDataStoreManager] setFriendsUserDescription:response];
                    } withuid:activeByUID];
                    
                    //                    [UIAlertView showAlertViewWithMessage:@"激活成功"];
                    [self closethisView];
                }else{
                    [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
                }
            }
            
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
        }];
    }else{
        [self closethisView];
    }
    
}
-(void) closethisView
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
    
//    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
//    img.layer.cornerRadius = img.width/2;
//    [img.layer setMasksToBounds:YES];
    
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
    UIImage * image = [theInfo objectForKey:UIImagePickerControllerEditedImage];
    [self uploadFile:image ];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
//    //Optionally for time zone conversions
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
//    
//    NSString * namefile =  [self getMd5_32Bit_String:timeDesc];
//    NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
//    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
//    SLLog(@"Upload Path: %@", filePath);
//    NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerEditedImage], 1);
//    [webData writeToFile:filePath atomically:YES];
 
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

- (void)uploadFile:(UIImage *)filePath  {
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

-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
    [SVProgressHUD showWithStatus:@"正在上传头像..."];
    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
    [img setImage:filePath];
    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    
     NSData * imagedata = [UIImage imageToWebP:filePath quality:75];
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        [formData appendPartWithFileData:imagedata name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLLog(@"responseObject %@",responseObject);
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
//            NSDictionary * parames = @{@"headpic":stringURL};
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
