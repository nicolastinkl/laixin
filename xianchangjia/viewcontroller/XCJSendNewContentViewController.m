//
//  XCJSendNewContentViewController.m
//  xianchangjia
//
//  Created by apple on 13-12-11.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJSendNewContentViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "XCAlbumAdditions.h"

@interface XCJSendNewContentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
	UIImagePickerController * picker;
}
//@property (weak, nonatomic) IBOutlet UITextView *TextContent;
@property (weak, nonatomic) IBOutlet UIButton *ImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UITextField *textviewcontent;
@property (weak, nonatomic) IBOutlet UILabel *labelBgtop;
@property (weak, nonatomic) IBOutlet UILabel *labeldown;

@end

@implementation XCJSendNewContentViewController
@synthesize scene_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)SendClick:(id)sender {
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    [returnDict setObject:[NSNumber numberWithInt:self.scene_id] forKey:@"scene_id"];
    [returnDict setObject:self.textviewcontent.text forKey:@"content"];
    [returnDict setObject:[NSNumber numberWithInt:0] forKey:@"stopsync"];
    [returnDict setObject:[USER_DEFAULT objectForKey:GlobalData_user_session] forKey:@"sessionid"];
    NSNumber * lng = [USER_DEFAULT valueForKey:GlobalData_lng];
    NSNumber * lat = [USER_DEFAULT valueForKey:GlobalData_lat];
    [returnDict setObject:lat forKey:@"latitude"];
    [returnDict setObject:lng forKey:@"longitude"];
    SLog(@"%@",returnDict);
    
    if (self.imageview.image) {
        
        NSData *imageData=UIImageJPEGRepresentation(self.imageview.image, 0.5f);
        AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager];
        [sessionManager POST:@"http://api.xianchangjia.com/post/add_post" parameters:returnDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (formData) {
                [formData appendPartWithFileData:imageData name:@"image" fileName:@"nothing.jpg" mimeType:@"image/jpeg"];
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error : %@" ,[error userInfo]);
        }];
    }else{
        [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:returnDict controller:@"post" Action:@"add_post" success:^(id obj) {
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSInteger index) {
            NSLog(@"error : %d" ,index);
        } failure:^(NSError *error) {
            NSLog(@"error : %@" ,[error userInfo]);
        }];
    }
    /*
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * newURL = @"http://api.xianchangjia.com/";
    [manager POST:[NSString stringWithFormat:@"%@post/add_post",newURL] parameters:returnDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"nothing.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error : %@" ,[error userInfo]);
    }];
     */
}

- (IBAction)UploadImageClick:(id)sender {
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    actionsheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionsheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
	picker.allowsEditing=YES;
    switch (buttonIndex) {
        case 0://Take picture
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
            }
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            break;
            
        case 1://From album
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            break;
            
        default:
            
            break;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picke didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *resultimage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self.imageview setImage:resultimage];
    [picke dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [tools setOBHeadRotary:self.labelBgtop];
    [tools setOBHeadRotary:self.labeldown];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textviewcontent becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
