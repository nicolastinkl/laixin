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


@interface PostActivityViewController () <UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
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
    [_inputTextView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithString:@"{242}"];//[UIColor colorWithHex:SystemKidsColor]];
//    //back
	UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
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
    [rightView addSubview: self.postButton = postBtn];
    
    //post下的指示器
    UIActivityIndicatorView *postIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    postIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    postIndicator.frameSize = CGSizeMake(20, 20);
    postIndicator.center = postBtn.center;
    [rightView addSubview: self.postIndicator = postIndicator];
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamedTwo:@"header_bg_opaque"] forBarMetrics:UIBarMetricsDefault];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(CompletionPostImage:)];
    
    self.title = @"发布动态";
    
    //scrollView
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frameWidth, self.view.frameHeight-64)];
    _scrollView.scrollsToTop = NO;
    //动起来
    _scrollView.contentSize = CGSizeMake(_scrollView.frameWidth, _scrollView.frameHeight+1);
    _scrollView.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [_scrollView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;

    [self.view addSubview:_scrollView];
    
    UIImageView *textBackView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 15, self.view.frameWidth-8*2, 100-6*2)];
    textBackView.image = [[UIImage imageNamed:@"edit_text_bg.png"]stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
    textBackView.userInteractionEnabled = YES;
    textBackView.backgroundColor = [UIColor whiteColor];
    textBackView.layer.cornerRadius = 5.0f;
    [_scrollView addSubview:self.inputTextBackView = textBackView];
    
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 1, textBackView.frameWidth-5*2, textBackView.frameHeight-1*2)];
    _inputTextView.clipsToBounds = YES;
    _inputTextView.delegate = self;
    _inputTextView.font = [UIFont systemFontOfSize:14];
    _inputTextView.scrollsToTop = NO;
    _inputTextView.returnKeyType = UIReturnKeyDone;
    [textBackView addSubview:_inputTextView];
    
    _inputTextView.text = @"请勿发布带有色情或者非法不良信息";
    //监视输入内容大小，在KVO里自动调整
    [_inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];    
    self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, _inputTextBackView.frameBottom+10, 70, 70)];
    _postImageView.contentMode = UIViewContentModeScaleAspectFill;
    _postImageView.clipsToBounds = YES;
    _postImageView.layer.borderColor = [UIColor grayColor].CGColor;
    _postImageView.layer.borderWidth = 0.5f;
    [_scrollView addSubview:_postImageView];
    
    if (_postImage) {
        _postImageView.image = self.postImage;
    }
    
    [_inputTextView becomeFirstResponder];
    
}

-(IBAction)CompletionPostImage:(id)sender
{
    [self postAction];
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
            TokenAPP = token;
            [self uploadImagetoken:token];
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
        NSData * imageData = UIImageJPEGRepresentation(self.postImage, 1);
          [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg",self.uploadKey] mimeType:@"image/jpeg" ];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
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
                glist.group_id = self.gID;
                glist.time = [[NSDate date] timeIntervalSinceNow];
                
                [_needRefreshViewController.activities insertObject:glist atIndex:0];
                [_needRefreshViewController.tableView reloadData];
                [_needRefreshViewController reloadSingleActivityRowOfTableView:0 withAnimation:YES];
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
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
