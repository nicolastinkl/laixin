//
//  XCJChangeUserInfoController.m
//  laixin
//
//  Created by apple on 13-12-31.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJChangeUserInfoController.h"
#import "XCAlbumAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LXAPIController.h"
#import "LXRequestFacebookManager.h"
#import "XCAlbumAdditions.h"
#import "tools.h"
#import "MLNetworkingManager.h"
#import "XCJErWeiCodeViewController.h"
#import "XCJChangeNickNaviController.h"
#import "XCJChangeSignNaviController.h"
#import "HZAreaPickerView.h"
#import "UIImage+WebP.h"

@interface XCJChangeUserInfoController ()< UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,HZAreaPickerDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
} 
@property (weak, nonatomic) IBOutlet UIImageView *Image_userIcon;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UILabel *label_sign;
@property (weak, nonatomic) IBOutlet UILabel *Label_address;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue;
@end

@implementation XCJChangeUserInfoController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.Label_nick.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
//    self.Label_nick.textColor = [tools colorWithIndex:[LXAPIController sharedLXAPIController].currentUser.actor_level];
    self.label_sign.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];
    if ([USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_position]) {
        
        self.Label_address.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_position];
    }else{
        self.Label_address.text = @"四川 成都";
    }
    [self.Image_userIcon setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.Label_nick.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    self.label_sign.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];
    self.Label_address.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_position];
    [self.Image_userIcon setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                // change image
                [self openGallery:nil];
                break;
            case 1:
                // change nick
            {
                XCJChangeNickNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChangeNickNaviController"];
                [self presentViewController:conss animated:YES completion:^{
                    
                }];
            }
                break;
            case 2:
            {
                // go to erwei code
                XCJErWeiCodeViewController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJErWeiCodeViewController"];
                [self.navigationController pushViewController:conss animated:YES];
            }
                break;
                
                
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                // change address
            {
                self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
                [self.locatePicker showInView:self.view];
            }
                break;
            case 1:
                // change signture
            {
                XCJChangeSignNaviController *conss = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChangeSignNaviController"];
                [self presentViewController:conss animated:YES completion:^{
                    
                }];
            }
                break;
                
            default:
                break;
        }
    }
    
}


- (void) cancel
{
     [self cancelLocatePicker];
}

- (void) complate
{
    [self cancelLocatePicker];
    [SVProgressHUD show];
    // upload networking
    NSDictionary * parames = @{@"position":self.Label_address.text};
    //nick, signature,sex, birthday, marriage, height
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
        [USER_DEFAULT setObject:self.Label_address.text forKey:KeyChain_Laixin_account_user_position];
        [USER_DEFAULT synchronize];
        [SVProgressHUD dismiss];
    } failure:^(MLRequest *request, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    if (picker.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        self.areaValue = [NSString stringWithFormat:@"%@ %@ %@", picker.locate.state, picker.locate.city, picker.locate.district];
    } else{
        self.cityValue = [NSString stringWithFormat:@"%@ %@", picker.locate.state, picker.locate.city];
    }
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}


-(IBAction)openGallery:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing  = YES;
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


-(void)setAreaValue:(NSString *)areaValue
{
    if (![_areaValue isEqualToString:areaValue]) {
        self.Label_address.text = areaValue;
    }
}

-(void)setCityValue:(NSString *)cityValue
{
    if (![_cityValue isEqualToString:cityValue]) {
        self.Label_address.text = cityValue;
    }
}

- (void)uploadContent:(NSDictionary *)theInfo {
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
//    //Optionally for time zone conversions
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
//    
////    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerEditedImage];
//    NSString * namefile =  [self getMd5_32Bit_String:timeDesc];
//    NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
//    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
//    SLLog(@"Upload Path: %@", filePath);
//    NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerEditedImage], 1);
//    [webData writeToFile:filePath atomically:YES];
    UIImage * image =  theInfo[UIImagePickerControllerOriginalImage];
    [self uploadFile:image];
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

- (void)uploadFile:(UIImage *)filePath {
    
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

-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
    [SVProgressHUD showWithStatus:@"正在上传头像..."];
    [self.Image_userIcon setImage:filePath];
    [self.Image_userIcon showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    NSData * formDataddd = [UIImage imageToWebP:filePath quality:75];
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        [formData appendPartWithFileData:formDataddd name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSString * stringURL =  [tools getStringValue:[responseObject objectForKey:@"url"] defaultValue:@""];
            
            [USER_DEFAULT setObject:stringURL forKey:KeyChain_Laixin_account_user_headpic];
            [USER_DEFAULT synchronize];
          
            
            [UIView animateWithDuration:0.3 animations:^{
                UIImageView * successImg = (UIImageView *) [self.view subviewWithTag:3];
                [successImg setHidden:NO];
            }];
            [SVProgressHUD dismiss];
            [self.Image_userIcon hideIndicatorViewBlueOrGary];
            //nick, signature,sex, birthday, marriage, height
//            NSDictionary * parames = @{@"headpic":stringURL};
//            [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
//                
//            } failure:^(MLRequest *request, NSError *error) {
//            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.Image_userIcon hideIndicatorViewBlueOrGary];
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

 
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
