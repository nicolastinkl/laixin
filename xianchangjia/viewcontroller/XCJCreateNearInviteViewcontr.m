//
//  XCJCreateNearInviteViewcontr.m
//  laixin
//
//  Created by apple on 2/28/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJCreateNearInviteViewcontr.h"
#import "HZAreaPickerView.h"
#import "XCAlbumAdditions.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "FCUserDescription.h"
#import "HZAreaPickerView.h"
#import "CTAssetsPickerController.h"
#import "UIImage+Resize.h"
#import "SCJChooseSignOrDesViewControl.h"
#import "XCJSelectCroupTypeViewController.h"

#define BUTTONCOLL  5
#define DISTANCE_BETWEEN_ITEMS  5.0
#define LEFT_PADDING            5.0
#define ITEM_WIDTH              65.0
#define TITLE_HEIGHT            40.0

@interface XCJCreateNearInviteViewcontr ()<HZAreaPickerDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    UIImageView * removeImageview;
    NSString * TokenAPP;
    UIImage *ImageFile;
    NSArray * tagsArray;
    NSString * postIDCurrent;
    
    NSString * copyText;
}
@property (weak, nonatomic) IBOutlet UILabel *text_nick;
@property (weak, nonatomic) IBOutlet UILabel *text_age;
@property (weak, nonatomic) IBOutlet UILabel *text_address;
@property (weak, nonatomic) IBOutlet UILabel *text_laixinID;
@property (weak, nonatomic) IBOutlet UILabel *text_phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *laixinView;
@property (weak, nonatomic) IBOutlet UIView *view_label;
@property (weak, nonatomic) IBOutlet UILabel *label_sign;
@property (weak, nonatomic) IBOutlet UITableViewCell *desCell;
@property (weak, nonatomic) IBOutlet UILabel *label_des;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue,*CurrentUserid;
@property (strong, nonatomic) NSMutableArray *Photoarray;

@end

@implementation XCJCreateNearInviteViewcontr

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
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    self.Photoarray = array;
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"创建活动" style:UIBarButtonItemStyleDone target:self action:@selector(SureSendPutMMClick:)];
    self.navigationItem.rightBarButtonItem = item;
    [self.button setHeight:44];
    [self.button infoStyle];
    
    self.label_sign.textAlignment = NSTextAlignmentRight;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XCJSelectCroupTypeViewControllerNotiy:) name:@"XCJSelectCroupTypeViewController" object:nil];
    
     UIBarButtonItem * backitem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backtoviewClick:)];
    self.navigationItem.backBarButtonItem =backitem;
}


-(void) XCJSelectCroupTypeViewControllerNotiy:(NSNotification *) noty
{
    if(noty.object)
    {
        self.text_phoneNumber.text = [NSString stringWithFormat:@"%@",noty.object];
        self.text_phoneNumber.textColor = [tools colorWithIndex:0];
    }
}

-(IBAction)backtoviewClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)SureSendPutMMClick:(id)sender
{
    if (self.Photoarray.count <= 0) {
        [UIAlertView showAlertViewWithMessage:@"一张照片也不上传,你在玩我么?"];
        return;
    }
    if ([self.text_nick.text  isEqualToString:@"(必填)"]) {
        [UIAlertView showAlertViewWithMessage:@"必须填写标题"];
        return;
    }
    if ([self.text_age.text  isEqualToString:@"(必填)"]) {
        [UIAlertView showAlertViewWithMessage:@"必须选择时间"];
        return;
    }
    if ([self.text_address.text  isEqualToString:@"(必填)"]) {
        [UIAlertView showAlertViewWithMessage:@"必须选择地址"];
        return;
    }
    
    if ([self.text_phoneNumber.text  isEqualToString:@"(可选)"]) {
        [UIAlertView showAlertViewWithMessage:@"类型还是要选择的"];
        return;
    }
    
    if (self.textview.text.length <= 0) {
        [UIAlertView showAlertViewWithMessage:@"你不看提示的么,说明?"];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"正在创建活动..."];        
    NSDictionary * parames = @{@"name":self.text_nick.text ,@"position":self.text_address.text,@"board":self.text_phoneNumber.text,@"type":@(groupsGroupNearbyInvite)};
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.create"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //Result={“gid”:1}
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"result"];
            NSString * gid =  [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
            if (gid.length > 0) {
                NSDictionary * parames = @{@"gid":gid,@"content":self.textview.text};
                //nick, signature,sex, birthday, marriage, height
                [[MLNetworkingManager sharedManager] sendWithAction:@"post.add"  parameters:parames success:^(MLRequest *request, id responseObject) {
                    if (responseObject) {
                        NSDictionary * result = responseObject[@"result"];

                        NSString *postID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                        [tools SetMaxPostID:postID];
                        postIDCurrent = postID;
                        [SVProgressHUD dismiss];
                        [self startuploaduserimages];
                    }
                } failure:^(MLRequest *request, NSError *error) {
                    [self uploadError];
                }];
                //start upload image
                
                
            }else{
                [self uploadError];
            }
        }
    
    } failure:^(MLRequest *request, NSError *error) {
        [self uploadError];
    }];
    
}

-(void) startuploaduserimages
{
    [SVProgressHUD showWithStatus:@"正在上传图片..."];
    
    // get token
    // http://service.xianchangjia.com/recommend/upload/Media?sessionid=DD2wWxKLmcyhUS3&uid=11&recommend_uid=1
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
        if (response) {
            NSString * token =  [response objectForKey:@"token"];
            TokenAPP = token;
            
            ALAsset *asset = [self.Photoarray firstObject];
            if (asset) {
                ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                CGImageRef imgRef = [assetRep fullResolutionImage];
                UIImage *image = [UIImage imageWithCGImage:imgRef
                                                     scale:assetRep.scale
                                               orientation:(UIImageOrientation)assetRep.orientation];
                ImageFile = image;
                [self uploadImage:ImageFile token:TokenAPP];
            }
            
        }else{
            [self uploadError];
        }
    } withParems:[NSString stringWithFormat:@"upload/PostEx?sessionid=%@&postid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid],postIDCurrent]];
}

-(void) uploadImage:(UIImage *)image  token:(NSString *)token
{
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"1" forKey:@"x:filetype"];
    [parameters setValue:@"1" forKey:@"x:length"];
    [parameters setValue:token forKey:@"token"];
    
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         
        float quality;
        if (image.size.height > image.size.width) {
            quality = image.size.height/image.size.width;
        }else{
            quality = image.size.width/image.size.height;
        }
        quality = quality/2;
        if (quality > 1) {
            quality = .5;
        }
        UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width * quality, image.size.height * quality) interpolationQuality:kCGInterpolationDefault];
        NSData * FileData = UIImageJPEGRepresentation(newimage, 0.5);
        if (!FileData) {
            FileData  = UIImageJPEGRepresentation(image, 0.5);
        }
        
        [formData appendPartWithFileData:FileData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            [self.Photoarray removeObjectAtIndex:0];
            ALAsset *asset = [self.Photoarray firstObject];
            if (asset) {
                ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                CGImageRef imgRef = [assetRep fullResolutionImage];
                UIImage *image = [UIImage imageWithCGImage:imgRef
                                                     scale:assetRep.scale
                                               orientation:(UIImageOrientation)assetRep.orientation];
                ImageFile = image;
                [self uploadImage:ImageFile token:TokenAPP];
            }else{
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNearbyInvite" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        alert.tag = 4;
        [alert show];
    }];
}
-(void) uploadError
{
        [SVProgressHUD dismiss];
    [UIAlertView showAlertViewWithMessage:@"网络请求失败,请检查网络设置"];

}

- (IBAction)addphotoClick:(id)sender {
    if (self.Photoarray.count >= 5) {
        [UIAlertView showAlertViewWithMessage:@"最多只能选5张照片,可以点击删除已选图片"];
        return;
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.navigationBar.barTintColor  = [UIColor colorWithRed:48.0/255.0 green:167.0/255.0 blue:255.0/255.0 alpha:1.0];
    picker.navigationBar.translucent = YES;
    picker.navigationBar.tintColor  = [UIColor whiteColor];
    picker.navigationBarHidden = NO;
    
    picker.maximumNumberOfSelection = 5-self.Photoarray.count;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    // only allow video clips if they are at least 5s
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 1;
        } else {
            return YES;
        }
    }];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        __block NSUInteger page = self.Photoarray.count + 1;
        [self.Photoarray addObjectsFromArray:assets];
        // add view
        CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollview.frame.size.height);
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *asset =  obj;
            if (asset) {
                UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
                UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
                
                [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, 65, 65)];
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
                [recognizer setNumberOfTapsRequired:1];
                [recognizer setNumberOfTouchesRequired:1];
                [imageview addGestureRecognizer:recognizer];
                imageview.tag = idx;
                [self.scrollview addSubview:imageview];
            }
        }];
        self.scrollview.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * ([self.Photoarray count] +1), pageSize.height);
    }
}

-(void) tagSelected:(UITapGestureRecognizer * ) tap
{
    UIView * view = tap.view;
    removeImageview = (UIImageView *) view;
    UIActionSheet * alertalertss= [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"移除图片" otherButtonTitles:nil, nil];
    alertalertss.tag = 1;
    [alertalertss showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (actionSheet.tag) {
        case 1:
        {
            if (buttonIndex == 0) {
                //移除图片
                if (removeImageview) {
                    [self.Photoarray removeObjectAtIndex:(removeImageview.tag)];
                    for (UIView * view in self.scrollview.subviews) {
                        if ([view isKindOfClass:[UIImageView class]]) {
                            [view removeAllSubViews];
                            [view removeFromSuperview];
                        }
                    }
                    //add
                    [self.scrollview reloadInputViews];
                    self.scrollview.contentSize = CGSizeMake(0, 0);
                    
                    __block NSUInteger page =  1;
                    // add view
                    CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollview.frame.size.height);
                    [self.Photoarray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        ALAsset *asset =  obj;
                        if (asset) {
                            UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
                            UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
                            
                            [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, 65, 65)];
                            imageview.userInteractionEnabled = YES;
                            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
                            [recognizer setNumberOfTapsRequired:1];
                            [recognizer setNumberOfTouchesRequired:1];
                            [imageview addGestureRecognizer:recognizer];
                            imageview.tag = idx;
                            [self.scrollview addSubview:imageview];
                        }
                    }];
                    self.scrollview.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * ([self.Photoarray count] +1), pageSize.height);
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            UITextField *tf = [alertView textFieldAtIndex:0];
            copyText = tf.text;
            // NICK
            if (tf.text.length > 0 && tf.text.length <= 15) {
                self.title = tf.text;
                self.text_nick.text = tf.text;
                self.text_nick.textColor = [tools colorWithIndex:0];
            }else{

                if (tf.text.length > 15) {
                    [UIAlertView showAlertViewWithMessage:@"标题不能超过15位"];
                }

            }
        }
            break;
        case 2:
        {
            if (buttonIndex != 0) {
                self.text_age.text = [alertView buttonTitleAtIndex:buttonIndex];
                self.text_age.textColor = [tools colorWithIndex:0];
            }
        }
            break;
        case 4:
        {
            [self startuploaduserimages];
        }
        default:
            break;
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.textview isFirstResponder]) {
        [self.textview resignFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入活动标题:"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
                
                
                prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [prompt textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeDefault;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                if (copyText) {
                    tf.text = copyText;
                }
                prompt.tag = 1; // change name or nick
                [prompt show];
            }
        }
            break;
        case 1:
        {
            
            if (indexPath.row == 0) {
                //年龄
                
                 UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@""
                 message:@"请选择活动时间:"
                 delegate:self
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@"今天",@"明天",@"后天", nil];
                 
//                 prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
//                 UITextField *tf = [prompt textFieldAtIndex:0];
//                 tf.keyboardType = UIKeyboardTypeNumberPad;
//                 tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                
                 prompt.tag = 2; // change name or nick
                 [prompt show];
                
            }else  if (indexPath.row == 1) {
                    //居住地
                    self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
                    [self.locatePicker showInView:self.view];
                }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                //类型
                XCJSelectCroupTypeViewController * viewtype = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelectCroupTypeViewController"];
                viewtype.title = @"选择活动类型";
                [self.navigationController pushViewController:viewtype animated:YES];
            }
            
        }
            break;
        case 3:
        {
            if (indexPath.row == 0) {
                //标签
                
            }
            
        }
            break;
        default:
            break;
    }
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length <= 1000) {
        self.label_sign.text = [NSString stringWithFormat:@"%d",textView.text.length];
        self.label_sign.textColor = [UIColor grayColor];
    }else{
        self.label_sign.text = [NSString stringWithFormat:@"-%d",textView.text.length-1000];
        self.label_sign.textColor = [UIColor redColor];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"说点什么吧"]) {
        textView.text = @"";
        return YES;
    }
    return YES;
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.cityValue = [NSString stringWithFormat:@"%@ %@", picker.locate.state, picker.locate.city];
    self.text_address.text = self.cityValue;
    self.text_address.textColor = [tools colorWithIndex:0];
}

- (void) cancel
{
    [self cancelLocatePicker];
}

- (void) complate
{
    [self cancelLocatePicker];
    self.text_address.text = self.cityValue;
    self.text_address.textColor = [tools colorWithIndex:0];
}


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
