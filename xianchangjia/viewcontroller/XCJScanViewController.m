//
//  XCJScanViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJScanViewController.h"
#import "XCAlbumAdditions.h"
#import "UIAlertViewAddition.h"
#import "MLNetworkingManager.h"
#import "XCJAddUserTableViewController.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "LXRequestFacebookManager.h"
#import "XCJAppDelegate.h"

@interface XCJScanViewController ()<UIAlertViewDelegate>
{
    NSString *stringValue;
    NSString *stringValueNew;
}
@property (weak, nonatomic) IBOutlet UIImageView *line;

@end

@implementation XCJScanViewController

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
    upOrdown = NO;
    num =0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
     [self setupCamera];
	// Do any additional setup after loading the view.
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.top =  120+2*num;
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.top = 120+2*num;
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_session && !_session.isRunning) {
        [_session startRunning];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_session stopRunning];
    [timer invalidate];
    timer = nil;
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
    UIView * childview =  [self.view subviewWithTag:2];
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
        stringValue = metadataObject.stringValue;
    }
    
    if (![stringValue isNilOrEmpty] && stringValue.length > 0) {
        SLLog(@"%@",stringValue);
        if(stringValueNew && stringValueNew.length > 0){
            return;
        }
            
        stringValueNew  = [NSString stringWithFormat:@"%@",stringValue];
        stringValue = @"";
        [_session stopRunning];
//        [timer invalidate];
        if (![stringValueNew isNilOrEmpty]) {
            if ([stringValueNew isHttpUrl]) {
                [self.navigationController popViewControllerAnimated:NO];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValueNew]];
            }else{
                [self findUser];
//                switch (self.scanTypeIndex) {
//                    case findUser:
//                    {
//                        [self findUser];
//                    }
//                        break;
//                    case findGroup:
//                    {
//                        
//                    }
//                        break;
//                    case findAll:
//                    {
//                        [self findUser];
//                    }
//                        break;
//                    default:
//                        break;
//                }
            }
            
        }
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:stringValueNew delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
//        [alert show];
       
    }
}

- (void) findUser
{
    [SVProgressHUD showWithStatus:@"正在查找"];
    NSDictionary * paramess = @{@"nick":stringValueNew};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.search"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
        NSDictionary * groupsss = responseObjects[@"result"];
        NSArray * array = groupsss[@"users"];
        if(array.count  <= 0)
        {
            //                            [UIAlertView showAlertViewWithTitle:@"该用户不存在" message:@"无法找到该用户,请检查您填写的昵称是否正常"];
            [SVProgressHUD showErrorWithStatus:@"无法找到该用户,请检查您填写的昵称是否正常"];
            [_session startRunning];
            return ;
        }
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
                if (response) {
                    NSArray * array =self.navigationController.viewControllers ;
                    UIViewController * viewCon =  [array firstObject];
                    [self.navigationController popViewControllerAnimated:NO];
                    double delayInSeconds = .3;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [SVProgressHUD dismiss];
                        stringValueNew = nil;
                        //FCUserDescription
                        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
                        addUser.UserInfo = response;
                        //                    addUser.UserInfoJson = currentUser;
                        addUser.title = @"详细资料";
                        if (self.preController) {
                            
                            [self.preController.navigationController pushViewController:addUser animated:YES];
                        }else{
//                            XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
//                            UIViewController * viewCon = delegate.tabBarController.selectedViewController;
//                            if([viewCon isMemberOfClass:[UINavigationController class]])
//                            {
//                                UINavigationController * navi = (UINavigationController*)viewCon;
//                                [navi pushViewController:addUser animated:YES];
//                            }
                            
                           [viewCon.navigationController pushViewController:addUser animated:YES];
                        }
                    });
                }
            }];
        }];
        
    } failure:^(MLRequest *request, NSError *error) {
        stringValueNew = nil;
        [_session startRunning];
        [SVProgressHUD showErrorWithStatus:@"请求失败,请检查网络"];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [_session startRunning];
    }else{
        [_session stopRunning];
        if (![stringValueNew isNilOrEmpty]) {
            if ([stringValueNew isHttpUrl]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
                return;
            }
            switch (buttonIndex) {
                case findUser:
                {
                    [SVProgressHUD showWithStatus:@"正在查找"];
                    NSDictionary * paramess = @{@"nick":stringValueNew};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"user.search"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                        NSDictionary * groupsss = responseObjects[@"result"];
                        NSArray * array = groupsss[@"users"];
                        if(array.count  <= 0)
                        {
//                            [UIAlertView showAlertViewWithTitle:@"该用户不存在" message:@"无法找到该用户,请检查您填写的昵称是否正常"];
                            [SVProgressHUD showErrorWithStatus:@"无法找到该用户,请检查您填写的昵称是否正常"];
                            [_session startRunning];
                            return ;
                        }
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
                                if (response) {
                                    //FCUserDescription
                                    XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
                                    addUser.UserInfo = response;
//                                    addUser.UserInfoJson = currentUser;
                                    [self.navigationController pushViewController:addUser animated:YES];
                                    [SVProgressHUD dismiss];
                                }
                            }];
                        }];
                        
                    } failure:^(MLRequest *request, NSError *error) {
                        [SVProgressHUD showErrorWithStatus:@"请求失败,请检查网络"];
                        [_session startRunning];
                    }];
                }
                    break;
                case findGroup:
                {
                    
                }
                    break;
                case findAll:
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                default:
                    break;
            }
            
            if ([stringValue isNumber]) {
                // find user or group
                
            }
        }
        // and  target to other viewcontroller
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
