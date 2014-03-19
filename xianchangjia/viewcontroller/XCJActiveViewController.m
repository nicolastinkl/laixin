//
//  XCJActiveViewController.m
//  laixin
//
//  Created by apple on 14-1-22.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJActiveViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "UIAlertViewAddition.h"

#import "UIAlertViewAddition.h"
#import <AVFoundation/AVFoundation.h>
#import "LXUser.h"

@interface XCJActiveViewController ()<UINavigationControllerDelegate, UIPopoverControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
    UIBarButtonItem * rightBar ;
}

@property (weak, nonatomic) IBOutlet UIButton *button_info;
@property (weak, nonatomic) IBOutlet UIButton *button_closeavcapture;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end

@implementation XCJActiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)showInfoClick:(id)sender {
    [UIAlertView showAlertViewWithTitle:@"激活介绍" message:@"找到级别比自己高的激活码或找到已经进入该圈子的好友激活自己即可提高自己等级  \n\n  激活后可以看到好友私密相册 ^_^ !!!"];
}

-(IBAction)hiddenKeyboard:(id)sender
{
    UITextField * text =     ((UITextField *) [self.view subviewWithTag:1]);
    if ([text isFirstResponder]) {
        [text resignFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_4_INCH) {
        [self.button_info setTop:465.0f + 50];
        [self.button_closeavcapture setTop:465.0f + 50];
    }else{
        [self.button_info setTop:365.0f + 50];
        [self.button_closeavcapture setTop:365.0f + 50];
    }
	// Do any additional setup after loading the view.
    UIButton * button = ((UIButton *) [self.view subviewWithTag:2]);
    [button setHeight:40.0f];
    [button infoStyle];
    [button addTarget:self action:@selector(activeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField * text = ((UITextField *) [self.view subviewWithTag:1]) ;
    
    text.text = self.code;
//    text.text = @"ItDCMJnB3TeuW09";
    
    rightBar = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStyleBordered target:self action:@selector(scanClick:)];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    
    UIButton * closebutton = (UIButton*)  [((UIView *) [self.view subviewWithTag:9]) subviewWithTag:1];
    [closebutton addTarget:self action:@selector(closeView:)
          forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)closeView:(id)sender
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
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


-(IBAction)scanClick:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UITextView * text = (UITextView *) [self.view subviewWithTag:1];
    [text resignFirstResponder];
    
    UIButton * button =  (UIButton * )sender;
    button.enabled = NO;
    // start find
    ((UIView *) [self.view subviewWithTag:9]).hidden = NO;
    
    [self setupCamera];
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
                
                UITextView * text = (UITextView *) [self.view subviewWithTag:1];
                text.text = stringValueNew;
                ((UIView *) [self.view subviewWithTag:9]).hidden = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        };
    }
}


-(IBAction)activeClick:(id)sender
{
    UITextField * text =     ((UITextField *) [self.view subviewWithTag:1]);
    [text resignFirstResponder];
    NSString * CurrentCode = text.text;
    if (CurrentCode && CurrentCode.length > 0) {
        [SVProgressHUD show];
        [[MLNetworkingManager sharedManager] sendWithAction:@"active.do" parameters:@{@"active_code":CurrentCode} success:^(MLRequest *request, id responseObject) {
            //	Result={"active_level":1,"active_by":1}
            if (responseObject) {
                int errnovv = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
                if (errnovv != 0) {
                    [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
                    return ;
                }
                NSDictionary * result = responseObject[@"result"];
                if(result && result.allKeys.count > 0)
                {
                    //返回激活等级和激活者的id
                    NSInteger level = [DataHelper getIntegerValue:result[@"active_level"] defaultValue:0];
                    if (level > 0) {
                        //upload myself level
                        int activeCode = [LXAPIController sharedLXAPIController ].currentUser.actor_level;
                        if (level > activeCode) {
                            [LXAPIController sharedLXAPIController ].currentUser.active_level = level;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadMyLevel" object:nil];
                        }
                    }
                    [SVProgressHUD dismiss];
                    NSString * activeByUID =  [DataHelper getStringValue:result[@"active_by"]  defaultValue:@""];
                    if (activeByUID.length > 0) {
                        // check this uid is my friends???
                        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesByNetCompletion:^(id response, NSError *error) {
                            [[[LXAPIController sharedLXAPIController]  chatDataStoreManager] setFriendsUserDescription:response];
                        } withuid:activeByUID];
                        
                        [UIAlertView showAlertViewWithMessage:@"激活成功"];
                    }else{
                        [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
                    }
                }
                else{
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"激活失败,激活码已被使用"];
                }
                
            }
            
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"激活失败,请检查激活码是否正确"];
        }];
    }else{
        [UIAlertView showAlertViewWithMessage:@"请输入正确激活码"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
