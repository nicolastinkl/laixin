//
//  PostActivityViewController.m
//  Kidswant
//
//  Created by Molon on 13-11-19.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "PostActivityViewController.h"
#import "tools.h"
#import "Extend.h"
#import "GlobalData.h"
#import "UIAlertViewAddition.h"
#import "BaseDetailViewController.h"
#import "XCAlbumAdditions.h"
#import "LXAPIController.h"
#import "LXRequestFacebookManager.h"
#import "MLScrollRefreshHeader.h"
#import "XCJGroupPost_list.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Addition.h"

@interface PostActivityViewController () <UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    AFHTTPRequestOperation  * operation;
    NSString * TokenAPP;
}

@property (nonatomic,strong) UITextView *inputTextView;
@property (nonatomic,strong) UIImageView *inputTextBackView;
@property (nonatomic,strong) UIImageView *postImageView;
@property (nonatomic,strong) UIButton *postButton;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIActivityIndicatorView *postIndicator;
@end

@implementation PostActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    //[_inputTextView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor colorWithString:@"{242}"];//[UIColor colorWithHex:SystemKidsColor]];
//    //back
	/*UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
     [backBtn setFrame:CGRectMake(13, 26, 48, 30)];
     [backBtn setImage:[UIImage imageNamedTwo:@"share_return"] forState:UIControlStateNormal];
     [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
     
     UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 53, 31)];
     //post
     UIButton *postBtn=[UIButton buttonWithType:UIButtonTypeCustom];
     [postBtn setFrame:CGRectMake(0, 0, 53, 31)];
     [postBtn setImage:[UIImage imageNamedTwo:@"finished_normal"] forState:UIControlStateNormal];
     [postBtn setImage:[UIImage imageNamedTwo:@"finished_pressed"] forState:UIControlStateSelected];
     [postBtn addTarget:self action:@selector(postAction) forControlEvents:UIControlEventTouchUpInside];
     postBtn.enabled = NO;
     [rightView addSubview: self.postButton = postBtn];*/
    
    //post下的指示器
//    UIActivityIndicatorView *postIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    postIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
//    postIndicator.frameSize = CGSizeMake(20, 20);
//    postIndicator.center = postBtn.center;
//    [rightView addSubview: self.postIndicator = postIndicator];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamedTwo:@"header_bg_opaque"] forBarMetrics:UIBarMetricsDefault];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(CompletionPostImage:)];
    
    self.title = @"发布动态";
    
//    //scrollView
//    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frameWidth, self.view.frameHeight)];
//    _scrollView.scrollsToTop = NO;
//    //动起来
//    _scrollView.contentSize = CGSizeMake(_scrollView.frameWidth, _scrollView.frameHeight+1);
//    _scrollView.delegate = self;
//    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
//    [_scrollView addGestureRecognizer:tapGesture];
//    tapGesture.delegate = self;
//
//    [self.view addSubview:_scrollView];
//    
//    UIImageView *textBackView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 15, self.view.frameWidth-8*2, 100-6*2)];
//    textBackView.image = [[UIImage imageNamed:@"edit_text_bg.png"]stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
//    textBackView.userInteractionEnabled = YES;
//    textBackView.backgroundColor = [UIColor whiteColor];
//    textBackView.layer.cornerRadius = 5.0f;
//    [_scrollView addSubview:self.inputTextBackView = textBackView];
//    
//    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 1, textBackView.frameWidth-5*2, textBackView.frameHeight-1*2)];
//    _inputTextView.clipsToBounds = YES;
//    _inputTextView.delegate = self;
//    _inputTextView.font = [UIFont systemFontOfSize:14];
//    _inputTextView.scrollsToTop = NO;
//    _inputTextView.returnKeyType = UIReturnKeyDone;
//    [textBackView addSubview:_inputTextView];
//    
//    _inputTextView.text = @"请勿发布带有色情或者非法不良信息";
//    //监视输入内容大小，在KVO里自动调整
//    [_inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];    
//    self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, _inputTextBackView.frameBottom+10, 70, 70)];
//    _postImageView.contentMode = UIViewContentModeScaleAspectFill;
//    _postImageView.clipsToBounds = YES;
//    _postImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//    _postImageView.layer.borderWidth = 0.5f;
//    [_postImageView makeInsetShadowWithRadius:2 Alpha:0.8];
//    
//    [_scrollView addSubview:_postImageView];
    
    self.inputTextView = (UITextView * )[self.view subviewWithTag:2];
    self.postImageView = (UIImageView * )[self.view subviewWithTag:1];
    if (_postImage) {
        if(self.postImage.imageOrientation!=UIImageOrientationUp)
        {
            self.postImage = [self.postImage fixOrientation] ;//[tools rotateImage:self.postImage];
        }
        
        _postImageView.image = self.postImage;
    }
    
    _postImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    [_postImageView addGestureRecognizer:tapGes];

    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         [_inputTextView becomeFirstResponder];
    });
     
    
}

- (void) changeImage
{
    if ( [_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
    }
 
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
//        photoLibrary.allowsEditing = YES;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}

-(IBAction)CompletionPostImage:(id)sender
{
    [self postAction];
}


- (NSURL * )uploadContent:(NSDictionary *)theInfo {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
    
    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
        NSString * namefile =  [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@",timeDesc,self.gID]];
        NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        NSLog(@"Upload Path: %@", filePath);
        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 1);
        [webData writeToFile:filePath atomically:YES];
        return [NSURL URLWithString:filePath];
    }
    return nil;
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

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage * image =  [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    _postImageView.image = image;
    
    self.filePath = [self uploadContent:theInfo];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backAction
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)postAction
{
    if ([_inputTextView.text isNilOrEmpty]) {
        return;
    }
    [self uploadFile];
//    [self sendPost:_inputTextView.text image:self.postImage];
}

- (void)setPostImage:(UIImage *)postImage
{
    _postImage = [postImage fixOrientation];
}


- (void)uploadFile{
    // setup 1: frist get token
    //http://service.xianchangjia.com/upload/Message?sessionid=YtcS7pKQSydYPnJ
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
        if (response) {
            NSString * token =  [response objectForKey:@"token"];
            if ([token isNilOrEmpty]) {
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
                [alert show];
            }else{
                
                
                [self.inputTextView resignFirstResponder];
                [SVProgressHUD showWithStatus:@"正在发送..."];
                
                TokenAPP = token;
                [self uploadImagetoken:token];
            }
        }
    } withParems:[NSString stringWithFormat:@"upload/Post?sessionid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
}

-(void) uploadImagetoken:(NSString *)token
{
   
    //    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
    //    [img setImage:[UIImage imageWithContentsOfFile:filePath]];
    //    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"1" forKey:@"x:filetype"];
    [parameters setValue:_inputTextView.text forKey:@"x:content"];
    [parameters setValue:@"" forKey:@"x:length"];
    [parameters setValue:self.gID forKey:@"x:gid"];
    operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:self.filePath name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        
//        UIImage * imageHere = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",self.filePath]];
        NSData * imageData = UIImageJPEGRepresentation(self.postImage, 0.5);
          [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg",self.uploadKey] mimeType:@"image/jpeg" ];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3" }
        
// responseObject {
//        errno = 5;
//        error = "No known serializer for object: datetime.datetime(2014, 1, 9, 17, 35, 39)";
//    }
        
        SLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            if (result) {
                NSString *postID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                XCJGroupPost_list *glist = [[XCJGroupPost_list alloc] init];
                glist.postid = postID;
                glist.imageURL = url;
                glist.content = _inputTextView.text;
                glist.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
                glist.ilike = NO;
                glist.like = 0;
                glist.replycount = 0;
                glist.width = [self.postImage size].width;
                glist.height = [self.postImage size].height;
                glist.group_id = self.gID;
                glist.time = [NSDate timeIntervalSinceReferenceDate];
                NSMutableArray * array = [[NSMutableArray alloc] init];
                glist.comments = array;
                
                //[[NSDate date] timeIntervalSinceNow];
                
                [_needRefreshViewController.activities insertObject:glist atIndex:0];
                [_needRefreshViewController.cellHeights insertObject:@0 atIndex:0];
                [_needRefreshViewController reloadSingleActivityRowOfTableView:0 withAnimation:YES];
                [SVProgressHUD dismiss];
                /*
                 "replycount":0,
                 "uid":4,
                 "ilike":false,
                 "content":"来上班5天迟到4次然后人就不见了",
                 "gid":2,
                 "time":1388633691,
                 "postid":12,
                 "like":0
                 */
//                [_needRefreshViewController.refreshView beginRefreshing];
               // [_needRefreshViewController.tableView setContentOffset:CGPointMake(0, -_needRefreshViewController.tableView.contentInset.top) animated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD dismiss];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
        [SVProgressHUD dismiss];
        SLog(@"error :%@",error.userInfo);
        //        [img hideIndicatorViewBlueOrGary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self uploadImagetoken:TokenAPP];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]){
        static CGFloat maxHeight = 120;
        static CGFloat minHeight = 70;
        
        CGFloat origHeight = _inputTextView.frameHeight;
        _inputTextView.frameHeight = (_inputTextView.contentSize.height<=maxHeight)?_inputTextView.contentSize.height:maxHeight;
        if (_inputTextView.frameHeight < maxHeight) {
            _inputTextView.frameHeight = (_inputTextView.contentSize.height>=minHeight)?_inputTextView.contentSize.height:minHeight;
        }
        
        CGFloat offset = _inputTextView.frameHeight - origHeight;
        
        _inputTextBackView.frameHeight +=offset;
        
        _postImageView.frameY += offset;
    }
}

#pragma mark - TextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [_inputTextView resignFirstResponder];
        
        return NO;
    };
    return YES;
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    if ([textView.text isEqualToString:@"请勿发布带有色情或者非法不良信息"]) {
//        textView.text = @"";
//    }
//    return YES;
//}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isNilOrEmpty]) {
        _postButton.enabled = NO;
    }else{
        _postButton.enabled = YES;
    }
}

#pragma mark - 让键盘消失
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![touch.view isKindOfClass:[UITextView class]]&&[_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
    }
    return NO;
}

@end
