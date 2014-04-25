//
//  XCJRecommendLSFriendViewcontr.m
//  laixin
//
//  Created by apple on 2/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJRecommendLSFriendViewcontr.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "FCUserDescription.h"
#import "HZAreaPickerView.h"
#import "CTAssetsPickerController.h"
#import "UIImage+Resize.h"
#import "SCJChooseSignOrDesViewControl.h"


#define BUTTONCOLL  5
#define DISTANCE_BETWEEN_ITEMS  5.0
#define LEFT_PADDING            5.0
#define ITEM_WIDTH              65.0
#define TITLE_HEIGHT            40.0

@interface XCJRecommendLSFriendViewcontr ()<HZAreaPickerDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    UIImageView * removeImageview;
    NSString * TokenAPP;
    UIImage *ImageFile;
    NSArray * tagsArray;
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

@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue,*CurrentUserid;
@property (strong, nonatomic) NSMutableArray *Photoarray;
@end

@implementation XCJRecommendLSFriendViewcontr

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
    NSMutableArray * array = [[NSMutableArray alloc] init];
    self.Photoarray = array;
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(SureSendPutMMClick:)];
    self.navigationItem.rightBarButtonItem = item;
    [self.button setHeight:44];
    [self.button infoStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLaixin:) name:@"changeLaixinMMID" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLaixinDesLabel:) name:@"changeLaixinDesLabel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLaixinAgaeDesLabel:) name:@"changeLaixinAgaeDesLabel" object:nil];
}


-(void) changeLaixinAgaeDesLabel:(NSNotification * ) notify
{
    if (notify.object) {
        self.text_age.text = notify.object;
        self.text_age.textColor =[tools colorWithIndex:0];

    }
}


-(IBAction)SureSendPutMMClick:(id)sender
{
    if (self.Photoarray.count <= 0) {
        [UIAlertView showAlertViewWithMessage:@"一张照片也不上传,你在玩我么?"];
        return;
    }
    if (self.CurrentUserid.length <= 0) {
        [UIAlertView showAlertViewWithMessage:@"必须选择妹妹来信号"];
        return;
    }
    
    if ([self.text_age.text  isEqualToString:@"(必填)"]) {
        [UIAlertView showAlertViewWithMessage:@"必须选择年龄"];
        return;
    }
    if ([self.text_address.text  isEqualToString:@"(必填)"]) {
        [UIAlertView showAlertViewWithMessage:@"必须选择居住地"];
        return;
    }
    
    if ([self.text_phoneNumber.text  isEqualToString:@"(可选)"]) {
        [UIAlertView showAlertViewWithMessage:@"手机号码还是要填写的"];
        return;
    }
    
    if (self.label_des.text.length <= 0) {
        [UIAlertView showAlertViewWithMessage:@"你不看提示的么,描述?"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在提交资料..."];
    [[MLNetworkingManager sharedManager] sendWithAction:@"recommend.new" parameters:@{@"uid":self.CurrentUserid,@"recommend_word":self.label_des.text,@"sex":@"1",@"sex_want":@"1",@"contact":[NSString stringWithFormat:@"[phone]%@",self.text_phoneNumber.text],@"city":self.text_address.text,@"age":self.text_age.text,@"tags":tagsArray} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            //上传图片
           int recomdID =  [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
            if (recomdID == 0) {
                [SVProgressHUD dismiss];
                //start upload image
                // http://service.xianchangjia.com/recommend/upload/Media?sessionid=FE9ZZNsqRSwqYtp&uid=17&recommend_uid=19&usepage=1
                [self startuploaduserimages];
                
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
    } withParems:[NSString stringWithFormat:@"recommend/upload/Media?sessionid=%@&uid=%@&recommend_uid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid],self.CurrentUserid,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]];
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
    [UIAlertView showAlertViewWithMessage:@"网络请求失败,请检查网络设置"];
    [SVProgressHUD dismiss];
}

-(void) changeLaixinDesLabel:(NSNotification * ) notify
{
    if (notify.object) {
        NSDictionary * dict = notify.object;
        NSString * string = dict[@"description"];
        NSArray * array = dict[@"labelArray"];
        tagsArray = array;
        self.label_des.text = string;
        self.label_des.textColor =[tools colorWithIndex:0];
        self.label_sign.text = @"";
//        self.view_label.top = self.label_des.top + self.label_des.height  + BUTTONCOLL;
        
        [self.view_label.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *view = obj;
            [view removeFromSuperview];
        }];
        
        //self.view_label
        __block float prewith;
        __block float preLeft;
        __block float row = 0;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * str = obj;
            float buttonWeidth = 25 + str.length*10;
            UILabel *iv;
            if ((prewith+buttonWeidth+preLeft+BUTTONCOLL) < 250) {
                iv = [[UILabel alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (20+BUTTONCOLL) * row, buttonWeidth, 20)];
            }else{
                row ++;
                preLeft = 0;
                prewith = 0;
                iv = [[UILabel alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (20+BUTTONCOLL) * row, buttonWeidth, 20)];
            }
            prewith = buttonWeidth;
            preLeft = iv.left;
            [iv setFont:[UIFont systemFontOfSize:14.0f]];
            [iv setTextColor:[UIColor whiteColor]];
            iv.text = str;
            iv.textAlignment = NSTextAlignmentCenter;
            int ramd =  arc4random() % 9;
            iv.backgroundColor = [tools colorWithIndex:ramd];
            
            [self.view_label addSubview:iv];
        }];
//        [self.desCell setHeight:(self.view_label.top + self.view_label.height)];
//        [self.tableView reloadData];

    }
} 

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(267.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
}


-(void) changeLaixin:(NSNotification * ) notify
{
    if (notify.object) {
        NSString * userid = notify.object;
        self.CurrentUserid = userid;
        FCUserDescription * user = [[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:userid];
        UIImageView * image_icon  = (UIImageView *) [self.laixinView subviewWithTag:1];
        NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
        [image_icon setImageWithURL:[NSURL URLWithString:Urlstring]];
        self.laixinView.hidden = NO;
        self.text_laixinID.text = @"";
        self.text_nick.text = user.nick;
        self.text_nick.textColor = [tools colorWithIndex:0];
    }
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SLog(@" %d  %d",indexPath.section,indexPath.row);
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 1) {
                //更改昵称
                return;
                UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入妹妹的名称或昵称:"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
                
                
                prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [prompt textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeDefault;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;

                prompt.tag = 1; // change name or nick
                [prompt show];
            }
        }
            break;
        case 1:
        {
          
            if (indexPath.row == 0) {
                //年龄
                /*
                 UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入妹妹的年龄:"
                 message:@""
                 delegate:self
                 cancelButtonTitle:@"取消"
                 otherButtonTitles:@"确定", nil];
                 
                 prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                 UITextField *tf = [prompt textFieldAtIndex:0];
                 tf.keyboardType = UIKeyboardTypeNumberPad;
                 tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                 
                 prompt.tag = 2; // change name or nick
                 [prompt show];
                 */
            }else
            if (indexPath.row == 1) {
                //居住地
                self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
                [self.locatePicker showInView:self.view];
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                //联系方式
                UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入手机号码:"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
                
                
                prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [prompt textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeNumberPad;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                
                prompt.tag = 3; // change name or nick
                [prompt show];
            }else if (indexPath.row == 1) {
                //详细资料
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            UITextField *tf = [alertView textFieldAtIndex:0];
             // NICK
            if (tf.text.length > 0) {
                self.text_nick.text = tf.text;
                self.text_nick.textColor = [tools colorWithIndex:0];
            }
        }
            break;
        case 2:
        {
            
            UITextField *tf = [alertView textFieldAtIndex:0];
            //AGE
            if (tf.text.length > 0) {
                int age = [tf.text intValue];
                if (age > 100) {
                    [UIAlertView showAlertViewWithMessage:@"这么老了还玩App 赶紧滚回去睡觉."];
                }else if(age < 18){
                    [UIAlertView showAlertViewWithMessage:@"你太小了,不适合用这么高档的App."];
                }else{
                    self.text_age.text = tf.text;
                    self.text_age.textColor = [tools colorWithIndex:0];
                }
                
            }
        }
            break;
            
            case 3:
        {
            
            UITextField *tf = [alertView textFieldAtIndex:0];
            //PHONE
            if (tf.text.length > 0) {
                if (tf.text.length == 11) {
                    self.text_phoneNumber.text = tf.text;
                    self.text_phoneNumber.textColor = [tools colorWithIndex:0];
                }else {
                    [UIAlertView showAlertViewWithMessage:@"手机号码格式错误"];
                }
            }
        }
            break;
            case 4:
        {
            if (buttonIndex == 1) {
                [self uploadImage:ImageFile token:TokenAPP];
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

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"changeSegueDeslaixin"]) {
        SCJChooseSignOrDesViewControl * viewcontr = [segue destinationViewController];
        [viewcontr fillDescription:self.label_des.text withArray:nil];
    }
}

@end
