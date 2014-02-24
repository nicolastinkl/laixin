//
//  ChatViewController.m
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ChatViewController.h"
#import "Extend.h"
#import "MLTextView.h"
#import "XCAlbumAdditions.h"
#import "XCJChatMessageCell.h"
#import "XCAlbumAdditions.h"
#import "CustomMethod.h"
#import "MarkupParser.h"
#import "OHAttributedLabel.h"
#import "UIButton+Bootstrap.h"
#import "Conversation.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "Sequencer.h"
#import "FCMessage.h"
#import "FCUserDescription.h"
#import "LXRequestFacebookManager.h"
#import "CoreData+MagicalRecord.h"
#import "MessageList.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import "FDStatusBarNotifierView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "XCJSettingGroupViewController.h"
#import "XCJAddUserTableViewController.h"
#import "FCHomeGroupMsg.h"
#import "FacialView.h"
#import "XCJChatSendImgViewController.h"
#import "XCJChatSendInfoView.h"
#import "XCJWholeNaviController.h"
#import "UIImage+WebP.h"
#import "UIButton+Bootstrap.h"
#import "RemoteImgListOperator.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "EGOCache.h"
#import "UIImage+Resize.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"

#define  keyboardHeight 216
#define  facialViewWidth 300
#define facialViewHeight 180
#define  audioLengthDefine  1050

@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,XCJChatSendImgViewControllerdelegate,UIScrollViewDelegate,facialViewDelegate,XCJChatSendInfoViewDelegate,VoiceRecorderBaseVCDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
    NSString * PasteboardStr;
    NSArray * userArray;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    UIView  * EmjView;
    XCJChatSendInfoView *SendInfoView;
    NSURL * playingURL;
    XCJChatMessageCell * playingCell;
}
@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) UIView *keyboardView;
@property (strong,nonatomic) NSMutableArray *messageList;
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;


@property (retain, nonatomic)  ChatVoiceRecorderVC      *recorderVC;

@property (retain, nonatomic)   AVAudioPlayer           *player;

@property (copy, nonatomic)     NSString                *originWav;         //原wav文件名

@property (copy, nonatomic)     NSString                *convertAmr;        //转换后的amr文件

@end

@implementation ChatViewController
@synthesize m_objImgListOper = _objImgListOper;
@synthesize recorderVC,player,originWav,convertAmr;
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
    
    //加个拖动手势
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    panRecognizer.delegate = self;
//    [self.tableView addGestureRecognizer:panRecognizer];
    
    
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    
    UIButton * buttonChangeAudio = (UIButton *) [self.inputContainerView subviewWithTag:7];
    [buttonChangeAudio addTarget:self action:@selector(SHowAudioButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    
    {
        UIButton * buttonAudioss = (UIButton *) [self.inputContainerView subviewWithTag:9];
        [buttonAudioss sendMessageStyle];
        [buttonAudioss setTitle:@"按住说话" forState:UIControlStateNormal];
//        [buttonAudioss addTarget:self action:@selector(speakClick:) forControlEvents:UIControlStateNormal];
        //添加长按手势
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] init];
        [gr addTarget:self action:@selector(recordBtnLongPressed:)];
        gr.minimumPressDuration = 0.3;
        [buttonAudioss addGestureRecognizer:gr];
        
        
//        UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
//        longPrees.delegate = self;
//        longPrees.minimumPressDuration = 0.3;
//        [buttonAudioss addGestureRecognizer:longPrees];
    }
    
    UIButton * buttonAudio8 = (UIButton *) [self.inputContainerView subviewWithTag:8];
    
    [buttonAudio8 addTarget:self action:@selector(ShowkeyboardButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    
//    self.inputContainerView.layer.borderColor = [UIColor grayColor].CGColor;
//    self.inputContainerView.layer.borderWidth = 0.5f;
    self.inputContainerView.top = self.view.height - self.inputContainerView.height;
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //监视输入内容大小，在KVO里自动调整
//    [self.inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    
    //创建表情键盘
    if (scrollView==nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, keyboardHeight)];
        [scrollView setBackgroundColor:[UIColor whiteColor]];
        for (int i=0; i<4; i++) {
            FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(10+320*i, 18, facialViewWidth, facialViewHeight)];
            [fview setBackgroundColor:[UIColor clearColor]];
            [fview loadFacialView:i size:CGSizeMake(74, 74)];
            fview.delegate=self;
            [scrollView addSubview:fview];
        }
    }
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.contentSize=CGSizeMake(320*4, keyboardHeight);
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;

    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(98, keyboardHeight-40, 150, 30)];
    [pageControl setCurrentPage:0];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];//RGBACOLOR(195, 179, 163, 1);
    pageControl.currentPageIndicatorTintColor = ios7BlueColor;//RGBACOLOR(132, 104, 77, 1);
    pageControl.numberOfPages = 4;//指定页面个数
    [pageControl setBackgroundColor:[UIColor clearColor]];
    [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    
    EmjView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, keyboardHeight)];
    [EmjView addSubview:scrollView];
//    [EmjView addSubview:pageControl];
    [self.view addSubview:EmjView];
    
    [self setUpSequencer];
    
    if (self.gid) {
        // get user count
        {
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.members" parameters:@{@"gid":self.gid} success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    NSDictionary * dict =  responseObject[@"result"];
                    NSArray * arr =  dict[@"members"];
                    if (arr.count > 0) {
                        userArray = arr;
                        self.title = [NSString stringWithFormat:@"群聊(%d)",arr.count+1];
                    }
                }
            } failure:^(MLRequest *request, NSError *error) {
            }];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStyleDone  target:self action:@selector(SeeGroupInfoClick:)];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ta的资料" style:UIBarButtonItemStyleDone target:self action:@selector(SeeUserInfoClick:)];
        if (!self.userinfo) {
            // from db or networking
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                if (response) {
                    self.userinfo = response;
                    self.title = self.userinfo.nick;
                }
            } withuid:self.conversation.facebookId];
        }
    }
    
    
    //初始化播放器
    player = [[AVAudioPlayer alloc]init];
}

-(IBAction)ShowkeyboardButtonClick:(id)sender
{
    ( (UIButton *) [self.inputContainerView subviewWithTag:8]).hidden = YES;
    ( (UIButton *) [self.inputContainerView subviewWithTag:7]).hidden = NO;
    ((UIButton *) [self.inputContainerView subviewWithTag:9]).hidden = YES;
    [self.inputTextView becomeFirstResponder];
    
}
-(IBAction)SHowAudioButtonClick:(id)sender
{
    ( (UIButton *) [self.inputContainerView subviewWithTag:9]).hidden = NO;
    ( (UIButton *) [self.inputContainerView subviewWithTag:8]).hidden = NO;
    ( (UIButton *) [self.inputContainerView subviewWithTag:7]).hidden = YES;
    [self.inputTextView resignFirstResponder];
}

#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"录音完成，文件路径:%@",_filePath);
    
    if (originWav.length > 0){
        self.convertAmr = [originWav stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"]];
        NSString * strAMRName = [VoiceRecorderBaseVC getPathByFileName:convertAmr  ofType:@"amr"];
        if (strAMRName.length > 0) {
            // send amr
            SLog(@"amr : %@",strAMRName);
            UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
            [buttonAudio setTitle:@"按住开始" forState:UIControlStateNormal];
            [buttonAudio sendMessageStyle];
            //2.audio   3.video
            [self SendMediaSource:strAMRName withType:2];
        }
    }
}

-(void) SendMediaSource:(NSString *) filePath  withType:(NSInteger ) type
{
    
    NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
    if(token.length > 0){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        FCMessage *msg = [FCMessage MR_createInContext:localContext];
        msg.text = @"";
        msg.messageSendStatus = @(4); // ready to send
        msg.messageguid = [self getMD4HashWithObj];
        msg.sentDate = [NSDate date];
        msg.messageType = @(messageType_audio);
        msg.audioUrl = filePath;
        int leg = [self getFileSize:filePath];
        msg.audioLength = @(leg/audioLengthDefine);
        // message did not come, this will be on rigth
        msg.messageStatus = @(NO);
        msg.messageId =  @"";
        self.conversation.lastMessage = @"[语音]";
        self.conversation.lastMessageDate = [NSDate date];
        self.conversation.badgeNumber = @0;
        self.conversation.messageStutes = @(messageStutes_outcoming);
        [self.conversation addMessagesObject:msg];
        [self.messageList addObject:msg];
        [localContext MR_saveToPersistentStoreAndWait];
        [self insertTableRow];
    }else{
        // token has 1 hour expire
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
            if (response) {
                NSString * token =  response[@"token"];
                [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = @"";
                msg.messageSendStatus = @(4); // ready to send
                msg.messageguid = [self getMD4HashWithObj];
                msg.sentDate = [NSDate date];
                msg.messageType = @(messageType_audio);
                msg.audioUrl = filePath;
                // message did not come, this will be on rigth
                msg.messageStatus = @(NO);
                msg.messageId =  @"";
                self.conversation.lastMessage = @"[语音]";
                self.conversation.lastMessageDate = [NSDate date];
                self.conversation.badgeNumber = @0;
                self.conversation.messageStutes = @(messageStutes_outcoming);
                [self.conversation addMessagesObject:msg];
                [self.messageList addObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
                [self insertTableRow];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",@"Message",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
    return;
    
     //2.audio   3.video
    NSString * postType;
    if (self.gid.length > 0) {
        postType = @"Post";
    }else{
        postType = @"Message";
        
    }
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id responsessssss, NSError *error) {
        if (responsessssss) {
            NSString * token =  responsessssss[@"token"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
            [parameters setValue:token forKey:@"token"];
            [parameters setValue:[NSString stringWithFormat:@"%d",type] forKey:@"x:filetype"];
            [parameters setValue:@"" forKey:@"x:content"];
            
            [parameters setValue:@([self getFileSize:filePath]) forKey:@"x:length"];
            [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
            __block NSData * PCMData;
            operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"audio/amr-wb" error:nil ];
                PCMData = [NSData dataWithContentsOfFile:filePath];
                if (PCMData) {
                    [formData appendPartWithFileData:PCMData name:@"file" fileName:@"file" mimeType:@"audio/amr-wb"]; //录音
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
                SLLog(@"responseObject %@",responseObject);
                if (responseObject) {
                    NSDictionary * result =  responseObject[@"result"];
                    if (result) {
                        
                            // update lastmessage id index
                            NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                            
                            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                            if (messageIndex < indexMsgID) {
                                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                [USER_DEFAULT synchronize];
                            }
                            NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                            NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                          //  [self SendImageWithMeImageurl:url withMsgID:msgID];
                        
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        FCMessage *msg = [FCMessage MR_createInContext:localContext];
                        msg.text = @"";
                        msg.sentDate = [NSDate date];
                        msg.messageType = @(messageType_audio);
                        msg.audioUrl = url;
                        // message did not come, this will be on rigth
                        msg.messageStatus = @(NO);
                        msg.messageId =  msgID;
                            self.conversation.lastMessage = @"[语音]";
                        self.conversation.lastMessageDate = [NSDate date];
                        self.conversation.badgeNumber = @0;
                        self.conversation.messageStutes = @(messageStutes_outcoming);    
                        [self.conversation addMessagesObject:msg];
                        [self.messageList addObject:msg];
                        [localContext MR_saveToPersistentStoreAndWait];
                    }
                    [SVProgressHUD dismiss];
                    //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                SLLog(@"error :%@",error.userInfo);
                [SVProgressHUD dismiss];
            }];
        }
    } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    
    
}

#pragma mark - 获取文件大小
- (int) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}

-(IBAction)speakClick:(id)sender
{
    if (!self.recorderVC) {
        //初始化录音vc
        self.recorderVC = [[ChatVoiceRecorderVC alloc]init];
        recorderVC.vrbDelegate = self;
    }
    //设置文件名
    self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
    UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
    [buttonAudio setTitle:@"松开结束" forState:UIControlStateNormal];
    [buttonAudio infoStyle];
    //开始录音
    [recorderVC beginRecordByFileName:self.originWav];
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//    [super touchesEnded:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//    [super touchesMoved:touches withEvent:event];
//}

-(void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer
{

     UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
     SLog(@"recordBtnLongPressedss..");
        [self speakClick:nil];
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        [buttonAudio sendMessageStyle];
        [buttonAudio setTitle:@"按住说话" forState:UIControlStateNormal];
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:nil forKey:@"data"]]];
    }
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollViewss
//{
//    if (scrollViewss && scrollViewss == scrollView) {
//        int page = scrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
//        pageControl.currentPage = page;//pagecontroll响应值的变化
//    }
//}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//}


-(IBAction)SeeUserInfoClick:(id)sender
{
    //查看好友资料
    XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
    addUser.UserInfo = self.userinfo;
    [self.navigationController pushViewController:addUser animated:YES];
}

-(IBAction)SeeGroupInfoClick:(id)sender
{
    XCJSettingGroupViewController * groupsettingview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSettingGroupViewController"];
    groupsettingview.title = self.title;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * uid = [DataHelper getStringValue:obj[@"uid"] defaultValue:@""];
        if (uid.length > 0) {
            [array addObject:uid];
        }
    }];
    groupsettingview.uidArray = array;
    groupsettingview.gid = self.gid;
    [self.navigationController pushViewController:groupsettingview animated:YES];
}

- (void) setUpSequencer
{
    __weak ChatViewController *self_ = self;
     Sequencer *sequencer = [[Sequencer alloc] init];
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        self_.messageList = [NSMutableArray arrayWithArray:[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchAllMessagesInConversation:self_.conversation]];
//        [self_.messageList turnObjectCore:[NSMutableArray arrayWithArray:[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchAllMessagesInConversation:self_.conversation]]];
        [self_.tableView reloadData];
        //tableView底部
        [self scrollToBottonWithAnimation:NO];
        
        completion(nil);
    }];
    [sequencer run];
    
}

//- (MessageList*)messageList
//{
//    if (!_messageList) {
//        _messageList = [[MessageList alloc]init];
//    }
//    return _messageList;
//}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.conversation.badgeNumber intValue] > 0) {
        self.conversation.badgeNumber = @(0);
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
      //  [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageTabBarItemBadge" object:nil];
    }
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    /* receive websocket message
     */
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(webSocketDidReceivePushMessage:)
     name:MLNetworkingManagerDidReceivePushMessageNotification
     object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PostLoacationClick:) name:@"PostChatLoacation" object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (operation && [operation isExecuting]) {
        [operation cancel];
    }
//    scrollView.delegate=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    NSDictionary * MsgContent  = notification.userInfo;
    SLLog(@"MsgContent :%@",MsgContent);
    if ([MsgContent[@"push"] intValue] == 1) {
        NSString *requestKey = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        if ([requestKey isEqualToString:@"newmsg"]) {
            /*
             {"push": true, "data": {"message": {"toid": 14, "msgid": 5, "content": "\u6211\u6765\u4e86sss", "fromid": 2, "time": 1388477804.0}}, "type": "newmsg"}
             */
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"message"];
            
            
            // update lastmessage id index
            NSInteger indexMsgID = [DataHelper getIntegerValue:dicMessage[@"msgid"] defaultValue:0];
            
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            
            NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
            if ([self.conversation.facebookId isEqualToString:facebookID]) {
                // int view
                NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                NSString * typeMessage = [tools getStringValue:dicMessage[@"type"] defaultValue:@""];
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                //                FCMessage  find this infomation
                NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
                FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
                if (message) {
                    // change by tinkl   ....MARK:  has this record
                    [self.messageList addObject:message]; //table reload
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_incoming);
                    [localContext MR_saveToPersistentStoreAndWait];
                    
                }else{
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = content;
                    
                    msg.sentDate = date;
                    // message did come, this will be on left
                    msg.messageStatus = @(YES);
                    if ([typeMessage isEqualToString:@"txt"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            self.conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            self.conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"emj"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            self.conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            self.conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"pic"]) {
                        //image
                        msg.messageType = @(messageType_image);
                        self.conversation.lastMessage = @"[图片]";
                        msg.imageUrl = imageurl;
                    }else if ([typeMessage isEqualToString:@"vic"]) {
                        //audio
                        NSString * audiourl = [tools getStringValue:dicMessage[@"voice"] defaultValue:@""];
                        self.conversation.lastMessage = @"[语音]";
                        msg.audioUrl = audiourl;
                        msg.messageType = @(messageType_audio);
                        int length  = [dicMessage[@"length"] intValue];
                        msg.audioLength = @(length/audioLengthDefine);
                    }else if ([typeMessage isEqualToString:@"map"]) {
                        self.conversation.lastMessage = @"[位置信息]";
                        msg.imageUrl = imageurl;
                        msg.messageType = @(messageType_map);
                    }else if ([typeMessage isEqualToString:@"video"]) {
                        self.conversation.lastMessage = @"[视频]";
                        msg.videoUrl = imageurl;
                        msg.messageType = @(messageType_video);
                    }
                    
                    msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                    
                    self.conversation.lastMessageDate = date;
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_incoming);
                    [self.conversation addMessagesObject:msg];
                    [self.messageList addObject:msg]; //table reload
                    [localContext MR_saveToPersistentStoreAndWait];
                }
                [self insertTableRow];

            }else if(![self.conversation.facebookId isEqualToString:facebookID]){
                //out view
                NSString * content = dicMessage[@"content"];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                NSString * typeMessage = [tools getStringValue:dicMessage[@"type"] defaultValue:@""];
                
                // update lastmessage id index
                NSInteger indexMsgID = [DataHelper getIntegerValue:dicMessage[@"msgid"] defaultValue:0];
                
                NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                if (messageIndex < indexMsgID) {
                    [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    [USER_DEFAULT synchronize];
                }
                
                NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
                FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
                if (message) {
                    // change by tinkl   ....MARK:  has this record
                }else{
                    
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = content;
                    NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                    msg.sentDate = date;
                    if ([typeMessage isEqualToString:@"txt"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            self.conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            self.conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"emj"]) {
                        if ([content containString:@"sticker_"]) {
                            msg.messageType = @(messageType_emj);
                            self.conversation.lastMessage = @"[表情]";
                        }else{
                            msg.messageType = @(messageType_text);
                            self.conversation.lastMessage = content;
                        }
                    }else if ([typeMessage isEqualToString:@"pic"]) {
                        //image
                        msg.messageType = @(messageType_image);
                        self.conversation.lastMessage = @"[图片]";
                        msg.imageUrl = imageurl;
                    }else if ([typeMessage isEqualToString:@"vic"]) {
                        //audio
                        NSString * audiourl = [tools getStringValue:dicMessage[@"voice"] defaultValue:@""];
                        self.conversation.lastMessage = @"[语音]";
                        msg.audioUrl = audiourl;
                        msg.messageType = @(messageType_audio);
                    }else if ([typeMessage isEqualToString:@"map"]) {
                        self.conversation.lastMessage = @"[位置信息]";
                        msg.imageUrl = imageurl;
                        msg.messageType = @(messageType_map);
                    }else if ([typeMessage isEqualToString:@"video"]) {
                        self.conversation.lastMessage = @"[视频]";
                        msg.videoUrl = imageurl;
                        msg.messageType = @(messageType_video);
                    }
                    
                    [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]];
                    // message did come, this will be on left
                    msg.messageStatus = @(YES);
                    msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                    self.conversation.lastMessage = content;
                    self.conversation.lastMessageDate = date;
                    self.conversation.messageStutes = @(messageStutes_incoming);
                    // increase badge number.
                    int badgeNumber = [self.conversation.badgeNumber intValue];
                    badgeNumber ++;
                    self.conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                    
                    [self.conversation addMessagesObject:msg];
                    [localContext MR_saveToPersistentStoreAndWait];
                }
            }
        }else if ([requestKey isEqualToString:@"newpost_error"]){
            // group new msg
            /*
             “data”:{
             “post”:{
             “postid”:
             “uid”:
             “group_id”:
             “content”:
                */
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"post"];
            NSString * gid = [tools getStringValue:dicMessage[@"gid"] defaultValue:@""];
            
            //获取群组消息类型 然后做相关写入操作
            NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"gid == %@ ",gid];
            FCHomeGroupMsg * groupMessage = [FCHomeGroupMsg MR_findFirstWithPredicate:parCMDss];
            if ([groupMessage.gType isEqualToString: @"2"]) {
                 
                NSString * uid = [tools getStringValue:dicMessage[@"uid"] defaultValue:@""];
                if([uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
                {
                    return;
                }
                
                
                NSString * facebookID = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
                if ([self.conversation.facebookId isEqualToString:facebookID]) {
                    // int view
                    NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
                    NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = content;
                    NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                    msg.sentDate = date;
                    // message did come, this will be on left
                    msg.messageStatus = @(YES);
                    if (imageurl.length > 5)
                    {
                        msg.messageType = @(messageType_image);
                        self.conversation.lastMessage = @"[图片]";
                    }
                    
                    else
                    {
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                    
                    msg.imageUrl = imageurl;
                    msg.messageId = [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                    
                    self.conversation.lastMessageDate = date;
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_incoming);
                    [self.conversation addMessagesObject:msg];
                    [self.messageList addObject:msg]; //table reload
                    [localContext MR_saveToPersistentStoreAndWait];
                    [self insertTableRow];
                    
                }else if(![self.conversation.facebookId isEqualToString:facebookID]){
                    //out view
                    NSString * content = dicMessage[@"content"];
                    NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = content;
                    NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                    msg.sentDate = date;
                    if (imageurl.length > 5)
                    {
                        msg.messageType = @(messageType_image);
                        self.conversation.lastMessage = @"[图片]";
                    }
                    else
                    {
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                    [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]];
                    // message did come, this will be on left
                    msg.messageStatus = @(YES);
                    msg.messageId =  [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                        FCUserDescription * localdespObject = response;
                        self.conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
                    } withuid:uid];
                    self.conversation.lastMessageDate = date;
                    self.conversation.messageStutes = @(messageStutes_incoming);
                    // increase badge number.
                    int badgeNumber = [self.conversation.badgeNumber intValue];
                    badgeNumber ++;
                    self.conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                    
                    [self.conversation addMessagesObject:msg];
                    [localContext MR_saveToPersistentStoreAndWait];
                }
            }
            
            
            
        }
    }
    
}

- (void)dealloc
{
    //删除Observer
//	[self.messageList removeObserver:self forKeyPath:@"array"];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MLNetworkingManagerDidReceivePushMessageNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString * ) getMD4HashWithObj
{
     NSTimeInterval doub = [[NSDate date] timeIntervalSinceNow];
    int x = arc4random() % 1000000;
    NSString * guid = [[NSString stringWithFormat:@"%f%d",doub, x] md5Hash];
    SLLog(@"gener guid: %@",guid);
    return guid;
}

#pragma mark -
#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = str;
    msg.sentDate = [NSDate date];
    msg.messageType = @(messageType_emj);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageguid = [self getMD4HashWithObj];
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageId = @"";
    self.conversation.lastMessage = @"[表情]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [self.messageList addObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self insertTableRow];
    
    return;
    SLog(@"str:%@",str);
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button showIndicatorView];
    button.userInteractionEnabled = NO;
    //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
    NSDictionary * parames = @{@"uid":self.conversation.facebookId,@"content":str};
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
        NSDictionary * dic = [responseObject objectForKey:@"result"];
        if (dic) {
            // update lastmessage id index
            NSInteger indexMsgID = [DataHelper getIntegerValue:dic[@"msgid"] defaultValue:0];
            
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = str;
            msg.sentDate = [NSDate date];
            msg.messageType = @(messageType_emj);
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            msg.messageId = [tools getStringValue:dic[@"msgid"] defaultValue:@"0"];
            self.conversation.lastMessage = @"[表情]";
            self.conversation.lastMessageDate = [NSDate date];
            self.conversation.badgeNumber = @0;
            self.conversation.messageStutes = @(messageStutes_outcoming);
            [self.conversation addMessagesObject:msg];
            [self.messageList addObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
            [button defaultStyle];
            [self insertTableRow];
        }
        
        [button hideIndicatorView];
        button.userInteractionEnabled = YES;
    } failure:^(MLRequest *request, NSError *error) {
        
        [button hideIndicatorView];
        button.userInteractionEnabled = YES;
    }];
}

- (IBAction)SendTextMsgClick:(id)sender {
// 群聊
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button showIndicatorView];
    button.userInteractionEnabled = NO;
    if (self.gid) {
        NSString * text = self.inputTextView.text;
        if ([text trimWhitespace].length > 0) {
            
//            self.inputContainerView.height  = 44.0f;
//            ((UIImageView *) [self.inputContainerView subviewWithTag:2]).height = 33.0f;
//            UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
//            imageBg.height = 44.0f;
//            self.inputTextView.height = 33.0f;
//            self.inputContainerView.top = self.view.height - self.inputContainerView.height;
//            self.tableView.height  = self.view.height - self.inputContainerView.height;
            
            NSDictionary * parames = @{@"gid":self.gid,@"content":text};
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.add" parameters:parames success:^(MLRequest *request, id responseObject) {
                NSDictionary * dic = [responseObject objectForKey:@"result"];
                if (dic) {
                    //postid  none nessciary
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = text;
                    msg.sentDate = [NSDate date];
                    msg.messageType = @(messageType_text);
                    // message did not come, this will be on rigth
                    msg.messageStatus = @(NO);
                    msg.messageId = [tools getStringValue:dic[@"postid"] defaultValue:@"0"];
                    self.conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick],text];
                    self.conversation.lastMessageDate = [NSDate date];
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_outcoming);
                    self.inputTextView.text = @"";
                    [self.conversation addMessagesObject:msg];
                    [self.messageList addObject:msg];
                    [localContext MR_saveToPersistentStoreAndWait];
                    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
                    [button defaultStyle];
                    [self insertTableRow];
                }
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            } failure:^(MLRequest *request, NSError *error) {
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            }];
            
        }
        
    }else{
        NSString * text = self.inputTextView.text;
        if ([text trimWhitespace].length > 0) {
            //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = text;
            msg.sentDate = [NSDate date];
            msg.messageType = @(messageType_text);
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            msg.messageSendStatus = @(4); // ready to send
            msg.messageId = @"";
            msg.messageguid = [self getMD4HashWithObj];
            self.conversation.lastMessage = text;
            self.conversation.lastMessageDate = [NSDate date];
            self.conversation.badgeNumber = @0;
            self.conversation.messageStutes = @(messageStutes_outcoming);
            self.inputTextView.text = @"";
            [self.conversation addMessagesObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            [self.messageList addObject:msg];
            [self insertTableRow];
            
//          dictionary[@"messageId"] = @"";
            
//            NSIndexPath * indexpath = [NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0];
//
//            XCJChatMessageCell * cell = (XCJChatMessageCell*)[self.tableView cellForRowAtIndexPath:indexpath];
//            [cell layoutSubviews];
//            [cell layoutIfNeeded];
//            [cell setNeedsLayout];
//            //(XCJChatMessageCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexpath];
//
            
           /* NSDictionary * parames = @{@"uid":self.conversation.facebookId,@"content":text};
            [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
                NSDictionary * dic = [responseObject objectForKey:@"result"];
                if (dic) {
                    // update lastmessage id index
                    NSInteger indexMsgID = [DataHelper getIntegerValue:dic[@"msgid"] defaultValue:0];
                    
                    NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    if (messageIndex < indexMsgID) {
                        [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                        [USER_DEFAULT synchronize];
                    }
                    
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = text;
                    msg.sentDate = [NSDate date];
                    msg.messageType = @(messageType_text);
                    // message did not come, this will be on rigth
                    msg.messageStatus = @(NO);
                    msg.messageId = [tools getStringValue:dic[@"msgid"] defaultValue:@"0"];
                    self.conversation.lastMessage = text;
                    self.conversation.lastMessageDate = [NSDate date];
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_outcoming);
                    self.inputTextView.text = @"";
                    [self.conversation addMessagesObject:msg];
                  
                    [localContext MR_saveToPersistentStoreAndWait];
                    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
                    [button defaultStyle];
                    [self.messageList addObject:msg];
                    [self insertTableRow];
                }
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            } failure:^(MLRequest *request, NSError *error) {
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            }];
            */
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self uploadImage:ImageFile token:TokenAPP];
    }
}

- (IBAction)adjustKeyboardFrame:(id)sender {
    //检测冲突
    [self.view exerciseAmiguityInLayoutRepeatedly:YES];
}

- (IBAction)addImage:(id)sender {
    //ActionSheet选择拍照还是相册
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
    //必须隐藏键盘否则会出问题。
    [self.inputTextView resignFirstResponder];
    */
    if (SendInfoView == nil) {
        SendInfoView = [[[NSBundle mainBundle] loadNibNamed:@"XCJChatSendInfoView" owner:self options:nil] lastObject];
        SendInfoView.delegate = self;
    }
    
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = SendInfoView;
    [self.inputTextView reloadInputViews];
    

}
- (void)takePhotoClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:camera animated:YES completion:nil];
    }
}

- (void)choseFromGalleryClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}

- (void) postLoactionMsg:(NSDictionary * ) notity
{
    
    UIImage * image =  notity[@"image"];
    NSString * address =  notity[@"strAddresss"];
    NSNumber * lat =  notity[@"lat"];
    NSNumber * log =  notity[@"log"];
    
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getMD4HashWithObj], @".jpg"];
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSData *webData = UIImageJPEGRepresentation(image, 0.5f);
    [webData writeToFile:file atomically:YES];
    
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.sentDate = [NSDate date];
    msg.imageUrl = file;
    msg.messageType = @(messageType_map);
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageId = @"";
    msg.messageguid = [self getMD4HashWithObj];
    msg.text = address;
    msg.longitude = log;
    msg.latitude = lat;
    self.conversation.lastMessage = @"[位置信息]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self.messageList addObject:msg];
    [self insertTableRow];
    
}

-(void) PostLoacationClick:(NSNotification * ) notity
{
    if (notity.userInfo) {
        //   NSDictionary *dict = @{@"image":image,@"strAddresss",strAddresss,@"lat":@(lat),@"log":@(log)};
        
        UIImage * image =  notity.userInfo[@"image"];
        NSString * address =  notity.userInfo[@"strAddresss"];
        NSNumber * lat =  notity.userInfo[@"lat"];
        NSNumber * log =  notity.userInfo[@"log"];
        NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
        if(token.length > 0){
            [self postLoactionMsg:notity.userInfo];
        }else{
            // token has 1 hour expire
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
                if (response) {
                    NSString * token =  response[@"token"];
                    [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                    [self postLoactionMsg:notity.userInfo];
                }
            } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",@"Message",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
        }
        
        return;
        
        
        NSString * postType;
        if (self.gid.length > 0) {
            postType = @"Post";
        }else{
            postType = @"Message";
        }
        
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id responsesssss, NSError *errorsssss) {
            if (responsesssss) {
                NSString * token =  [responsesssss objectForKey:@"token"];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
                [parameters setValue:token forKey:@"token"];
                [parameters setValue:@"1" forKey:@"x:filetype"];
                [parameters setValue:@"" forKey:@"x:content"];
                [parameters setValue:@"" forKey:@"x:length"];
                if (self.gid.length > 0) {
                    [parameters setValue:self.gid forKey:@"x:gid"];
                }else{
                    [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
                }
                NSData *imageDatasss  =  [UIImage imageToWebP:image quality:75.0];
                //imageDatasss = UIImageJPEGRepresentation(image, 0.5);
                
                operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    //        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
                    [formData appendPartWithFileData:imageDatasss name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
                    SLLog(@"responseObject %@",responseObject);
                    if (responseObject) {
                        NSDictionary * result =  responseObject[@"result"];
                        if (result) {
                            if (self.gid.length > 0) {
                                
                                NSString *msgID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                                [self SendImageWithMeImageurl:url withMsgID:msgID];
                            } else {
                                // update lastmessage id index
                                NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                                
                                NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                if (messageIndex < indexMsgID) {
                                    [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                    [USER_DEFAULT synchronize];
                                }
                                
                                NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
//                                [self SendImageWithMeImageurl:url withMsgID:msgID];
                                
                                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                                msg.sentDate = [NSDate date];
                                msg.messageType = @(messageType_map);
                                
                                msg.imageUrl = url;
                                // message did not come, this will be on rigth
                                msg.messageStatus = @(NO);
                                msg.messageId = msgID;
                                msg.text = address;
                                msg.longitude = log;
                                msg.latitude = lat;
                                
                                self.conversation.lastMessage = @"[位置信息]";
                                self.conversation.lastMessageDate = [NSDate date];
                                self.conversation.badgeNumber = @0;
                                self.conversation.messageStutes = @(messageStutes_outcoming);    
                                [self.conversation addMessagesObject:msg];
                                [self.messageList addObject:msg];
                                [localContext MR_saveToPersistentStoreAndWait];
                                [self insertTableRow];
                            }
                        }
                        [SVProgressHUD dismiss];
                        //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    SLLog(@"error :%@",error.userInfo);
                    [SVProgressHUD dismiss];
                }];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
}

- (void)choseLocationClick
{

    XCJWholeNaviController * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJWholeNaviController"];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)sendMyfriendsClick
{
    
}

- (void)moreClick
{
}

- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    NSString *requestString = [linkInfo.URL absoluteString];
    if (requestString && requestString.length > 5) {
        //        NSString * number = [attributedLabel.attributedText.string substringWithRange:linkInfo.range];
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"Safari打开",@"复制", nil];
        [sheet showInView:self.view];
    }else
    {
        NSString * number = [attributedLabel.attributedText.string substringWithRange:linkInfo.range];
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:number delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"呼叫 %@",number],@"添加至联系人",@"复制", nil];
        [sheet showInView:self.view];
    }
    
    //    NSLog(@"%@    .....   %@",    [attributedLabel.attributedText.string substringWithRange:linkInfo.range],attributedLabel.attributedText.string);
    //NSRegularExpression regularExpression
    
    //    NSString *requestString = [linkInfo.URL absoluteString];
    //    if ([[UIApplication sharedApplication]canOpenURL:linkInfo.URL]) {
    //        [[UIApplication sharedApplication]openURL:linkInfo.URL];
    //    }
    
    return NO;
}

#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                    camera.delegate = self;
                    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:camera animated:YES completion:nil];
                }
            }
                break;
            case 1:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
                    photoLibrary.delegate = self;
                    photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:photoLibrary animated:YES completion:nil];
                }
            }
                break;
            default:
                break;
        }
    }
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
            {
                if (PasteboardStr) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:PasteboardStr];
                }
            }
                break;
                
            default:
                break;
        }
    }

}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    
//    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    //upload image
    [self performSelector:@selector(uploadContent:) withObject:theInfo];
    
}

- (void) SendImageURL:(UIImage * ) url  withKey:(NSString *) key
{
//    [SVProgressHUD showWithStatus:@"正在发送..."];
    [self uploadFile:url  key:key];
}

- (void)uploadContent:(NSDictionary *)theInfo {
    
    XCJChatSendImgViewController * chatImgView = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChatSendImgViewController"];
    //    chatImgView.imageview.image = [postImage copy];
    UIImage *image = theInfo[UIImagePickerControllerOriginalImage];
    int Wasy = image.size.width/APP_SCREEN_WIDTH;
    int Hasy = image.size.height/APP_SCREEN_HEIGHT;
    int quality = Wasy/2;
    UIImage * newimage = [image resizedImage:CGSizeMake(APP_SCREEN_WIDTH*Wasy/quality, APP_SCREEN_HEIGHT*Hasy/quality) interpolationQuality:kCGInterpolationDefault];
    chatImgView.imageviewSource = newimage;
    chatImgView.delegate = self;
    [self presentViewController:chatImgView animated:YES completion:^{
    }];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
//    //Optionally for time zone conversions
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
//    
//    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
////        NSString * namefile =  [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@",timeDesc,self.conversation.facebookId]];
////        NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
////        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
////        SLLog(@"Upload Path: %@", filePath);
////        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 1);
////        [webData writeToFile:filePath atomically:YES];
////        [self uploadFile:filePath  key:key];
//        
//    }
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

- (void) SendImageWithMeImageurl:(NSString * ) url withMsgID:(NSString *) msgid
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = @"";
    msg.sentDate = [NSDate date];
    msg.messageType = @(messageType_image);
    
    msg.imageUrl = url;
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageId = msgid;
    if (self.gid.length > 0) {
        self.conversation.lastMessage = [NSString stringWithFormat:@"%@:[图片]",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick]];
    }else{

        self.conversation.lastMessage = @"[图片]";
    }
    
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);    
    [self.conversation addMessagesObject:msg];
    [self.messageList addObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    [self insertTableRow];
    
   /* NSDictionary * parames = @{@"uid":self.conversation.facebookId};
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
        NSDictionary * dic = [responseObject objectForKey:@"result"];
        if (dic) {
           
        }
        
    } failure:^(MLRequest *request, NSError *error) {
    }];*/
}


- (void)uploadFile:(UIImage *)filePath  key:(NSString *)key {
    // setup 1: frist get token
    //http://service.xianchangjia.com/upload/Message?sessionid=YtcS7pKQSydYPnJ
    NSString * postType;
    if (self.gid.length > 0) {
        postType = @"Post";
    }else{
        postType = @"Message";
    }
    
    NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
    if(token.length > 0){
         [self uploadImage:filePath token:token];
    }else{
        // token has 1 hour expire
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
            if (response) {
                NSString * token =  response[@"token"];
                [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                TokenAPP = token;
                ImageFile = filePath;
                [self uploadImage:filePath token:token];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
    
}

-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
//    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
//    [img setImage:[UIImage imageWithContentsOfFile:filePath]];
//    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    
    SLog(@"start uploading....");
    
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getMD4HashWithObj], @".jpg"];
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSData *webData = UIImageJPEGRepresentation(filePath, 0.5f);
    [webData writeToFile:file atomically:YES];    
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = @"";
    msg.sentDate = [NSDate date];
    msg.imageUrl = file;
    msg.messageType = @(messageType_image);
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageId = @"";
    msg.messageguid = [self getMD4HashWithObj];
    self.conversation.lastMessage = @"[图片]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self.messageList addObject:msg];
    [self insertTableRow];
    
    return;
    
    
    /**
     *  <#Description#>
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"1" forKey:@"x:filetype"];
    [parameters setValue:@"" forKey:@"x:content"];
    [parameters setValue:@"" forKey:@"x:length"];
    if (self.gid.length > 0) {
        [parameters setValue:self.gid forKey:@"x:gid"];
    }else{
        [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
    }
    
    NSData *imageDatasss  =  [UIImage imageToWebP:filePath quality:75.0];
    //NSData * imageDatasss = UIImageJPEGRepresentation(imageSend, 0.5);
    SLog(@"imageDatasss : %.2f KB ",(double)imageDatasss.length/audioLengthDefine);
    operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        [formData appendPartWithFileData:imageDatasss name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            if (result) {
                
                if (self.gid.length > 0) {
                    
                    NSString *msgID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                    NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                    [self SendImageWithMeImageurl:url withMsgID:msgID];
                }else{
                    // update lastmessage id index
                    NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                    
                    NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    if (messageIndex < indexMsgID) {
                        [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                        [USER_DEFAULT synchronize];
                    }
                    NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                    NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                    [self SendImageWithMeImageurl:url withMsgID:msgID];
                }
            }
               [SVProgressHUD dismiss];
          //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SLLog(@"error :%@",error.userInfo);
          [SVProgressHUD dismiss];
//        [img hideIndicatorViewBlueOrGary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        [alert show];
    }];
}

#pragma mark - TextView delegate
/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        if (![self.inputTextView.text isNilOrEmpty]) {
            
            Message *message = [[Message alloc]init];
            message.name = @"天王盖地虎";
            message.content = self.inputTextView.text;
            message.time = [[NSDate date] timeIntervalSince1970];
            message.avatarURL = [NSURL URLWithString:@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1"];
            //添加到列表
            [self.messageCellHeights addObject:@0];
            [self.messageList addObject:message];
            self.inputTextView.text = @"";
        }
        return NO;
    };
    return YES;
}
*/

- (void) insertTableRow
{
    
  //  [self.tableView beginUpdates];
    
   // NSArray *insertion = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageList.count inSection:0]];
    
   // [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationFade];
    
   // [self.tableView endUpdates];
    
    [self.tableView reloadData];
    [self scrollToBottonWithAnimation:YES];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
   /* if ([keyPath isEqualToString:@"contentSize"]){
        //高度最大为80
        static CGFloat maxHeight = 80;
        
        CGFloat origHeight = _inputTextView.frameHeight;
        _inputTextView.frameHeight = (_inputTextView.contentSize.height<=maxHeight)?_inputTextView.contentSize.height:maxHeight;
        
        CGFloat offset = _inputTextView.frameHeight - origHeight;
//        UIImageView * image = (UIImageView *) [self.inputContainerView subviewWithTag:2];
//        image.frameHeight +=offset;
        
        UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
        imageBg.frameHeight += offset;
        
        self.inputContainerView.frameHeight += offset;
        self.inputContainerView.frameY -= (offset);
        
        //tableView的位置也修正下
        _tableView.contentOffset = CGPointMake(0, _tableView.contentOffset.y+offset);
    }
    */
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    
    //元素位置的改变
    BOOL isPrior = [((NSNumber *)[change objectForKey:NSKeyValueChangeNotificationIsPriorKey]) boolValue];//是否是改变之前进来的
    if (isPrior&&[kind integerValue] != NSKeyValueChangeRemoval) {
        return; //改变之前进来却不是Removal操作就忽略
    }
    
    //获取变化值
    NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    if (indices == nil){
        return;
    }
    
    NSUInteger indexCount = [indices count];
    NSUInteger buffer[indexCount];
    [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indexCount; i++) {
        NSUInteger indexPathIndices[2];
        indexPathIndices[0] = 0;
        indexPathIndices[1] = buffer[i];
        NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
        [indexPathArray addObject:newPath];
    }
    //判断值变化是insert、delete、(replace被忽略不需要)。
    if ([kind integerValue] == NSKeyValueChangeInsertion){
        //		//添加对应的Observer
        //		for (NSIndexPath *path in indexPathArray) {
        //			[self addObserverOfChat:self.messageList[path.row]];
        //		}
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        [self scrollToBottonWithAnimation:YES];
    }
    else if ([kind integerValue] == NSKeyValueChangeRemoval){
        //改变之前清除Observer，改变之后剔除TableView里数据，其实用old去获取也可以，但是总觉得没这种方法好
        if (isPrior) {
            //删除对应的Observer
            //			for (NSIndexPath *path in indexPathArray) {
            //				[self removeObserverOfChat:self.chatList[path.row]];
            //			}
        }else{
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
    }
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messageList.count;
}

- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label
{
    o_text = [CustomMethod escapedString:o_text];
    [label setNeedsDisplay];
    NSMutableArray *httpArr = [CustomMethod addHttpArr:o_text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:o_text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:o_text];
    
//    NSString *text = [CustomMethod transformString:o_text emojiDic:self.m_emojiDic];
//    text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",text];
//    
//    MarkupParser *wk_markupParser = [[MarkupParser alloc] init];
//    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkup: text];
////    [attString setFont:[UIFont systemFontOfSize:16]];
//    [label setBackgroundColor:[UIColor clearColor]];
//    [label setAttString:attString withImages:wk_markupParser.images];
    
    NSString *string = o_text;// attString.string;
    
    if ([emailArr count]) {
        for (NSString *emailStr in emailArr) {
            [label addCustomLink:[NSURL URLWithString:emailStr] inRange:[string rangeOfString:emailStr]];
        }
    }
    
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    
//    label.delegate = self;
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(222, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(222, CGFLOAT_MAX)].height;
    label.frame = labelRect;
    label.underlineLinks = YES;//链接是否带下划线
    [label.layer display];
}

-(float) heightforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.height + 15 );
}

-(float) widthforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.width + 10 );
}

#pragma mark  cellfor

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  两种信息, 1: 用户间聊天信息
                 2: 系统公告
     */
    FCMessage *message = self.messageList[indexPath.row];
    if ([message.messageType intValue] == messageType_SystemAD) {
        //系统公告
        static NSString *CellIdentifier = @"SystemCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * label_text =  (UILabel * )[cell.contentView subviewWithTag:1];
        label_text.text = message.text;
        label_text.layer.cornerRadius = 4.0;
        label_text.layer.masksToBounds = YES;
        float width =  APP_SCREEN_WIDTH * .7;
        float widthtext = [self widthforsystem14:message.text withWidth:width];
        float height = [self heightforsystem14:message.text withWidth:width];
        [label_text sizeToFit];
        [label_text setHeight:height];
        [label_text setWidth:widthtext];
        [label_text setLeft:(APP_SCREEN_WIDTH/2-widthtext/2)];
        return cell;
    }
    
    
    //MESSAGE_GUID
    static NSString *CellIdentifier = @"XCJChatMessageCell";
    XCJChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setCurrentMessage:message];
    [cell setConversation:self.conversation];
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelName = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    UILabel * labelContent = (UILabel *) [cell.contentView subviewWithTag:4];
    UILabel * address = (UILabel *) [cell.contentView subviewWithTag:8];
    UIActivityIndicatorView * indictorView = (UIActivityIndicatorView *) [cell.contentView subviewWithTag:9];
    UIButton * retryButton = (UIButton *) [cell.contentView subviewWithTag:10];
    UIButton * audioButton = (UIButton *) [cell.contentView subviewWithTag:11];
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    if ([message.messageSendStatus intValue] == 1)
    {
        [indictorView startAnimating];
        indictorView.hidden = NO;
        retryButton.hidden = YES;
    }else if ([message.messageSendStatus intValue] == 2)
    {
        indictorView.hidden = YES;
       
        retryButton.hidden = NO;
    }
    else  if ([message.messageSendStatus intValue] == 0){
    {
            indictorView.hidden = YES;
            retryButton.hidden = YES;
    }
    }else if([message.messageSendStatus intValue] == 4)
    {
        [indictorView startAnimating];
        indictorView.hidden = NO;
        retryButton.hidden = YES;
        message.messageSendStatus = @(1);
        NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
        //          create guid
        dictionary[@"MESSAGE_GUID"]  =  message.messageguid;
        dictionary[@"text"]  =  message.text;
        dictionary[@"userid"]  =  self.conversation.facebookId;
        dictionary[@"messagetype"]  = message.messageType;// @(messageType_text);
        NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
        dictionary[@"token"]  =  token;
        switch ([message.messageType intValue]) {
            case messageType_image:
            case messageType_map:
            {
                dictionary[@"fileSrc"] = message.imageUrl;
            }
                break;
            case messageType_audio:
            {
                dictionary[@"fileSrc"] = message.audioUrl;
                dictionary[@"length"]  = @([self getFileSize:message.audioUrl]);
            }
                break;
            default:
                break;
        }
        [audioButton.layer setValue:message.audioUrl forKey:@"audiourl"];
        [cell SendMessageRemoteImgOper:_objImgListOper WithMessage:dictionary type:messageType_text];
//        [cell SendMessageWithMessage:dictionary type:messageType_text];
    }
    
    UIImageView * imageview_Img = (UIImageView *)[cell.contentView subviewWithTag:5];
    UIImageView * imageview_BG = (UIImageView *)[cell.contentView subviewWithTag:6];
    
    if ([message.messageStatus boolValue]) {
        if (self.gid) {
            //message.messageId // this is uid
            if (![message.messageId isNilOrEmpty]) {
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id obj, NSError *error) {
                    FCUserDescription * localdespObject = obj;
                    [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:localdespObject.headpic Size:100]]];
                    labelName.text = localdespObject.nick;
                } withuid:message.messageId];
            }
        }else{
            //Incoming
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:self.userinfo.headpic Size:100]]];
            labelName.text = self.userinfo.nick;
        }
        imageview_BG.image = [UIImage imageNamed:@"bubbleLeftTail"];
        labelContent.textColor = [UIColor blackColor];
    }else{
        //Outcoming
        imageview_BG.image = [UIImage imageNamed:@"bubbleRightTail-1"];
        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]]];
        labelName.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
        labelContent.textColor = [UIColor whiteColor];
    }
    labelTime.text = [tools FormatStringForDate:message.sentDate];
    audioButton.left = 400.0f;
    if ([message.messageType intValue] == messageType_image) {
        //display image  115 108
        labelContent.text  = @"";
        [imageview_Img setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:message.imageUrl Size:160]] placeholderImage:[UIImage imageNamed:@"aio_image_default"]];
//        imageview_Img.fullScreenImageURL = [NSURL URLWithString:message.imageUrl];
        imageview_Img.userInteractionEnabled = YES;
        UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewClick:)];
        [imageview_Img addGestureRecognizer:ges];
        
        imageview_Img.hidden = NO;
        [imageview_BG setHeight:108.0f];
        [imageview_BG setWidth:115.0f];
        
        [imageview_Img setHeight:100.0f];
        [imageview_Img setWidth:100.0f];
        
        imageview_BG.hidden = NO;

        address.text = @"";
        address.hidden = YES;
        
        indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
        indictorView.top = imageview_BG.height/2  + 20;
        
        retryButton.left = imageview_BG.left + imageview_BG.width  ;
        retryButton.top = imageview_BG.height/2  + 10;
        
    }else if ([message.messageType intValue] == messageType_text) {
        
        labelContent.text = message.text;
        //    [self creatAttributedLabel:message.content Label:labelContent];
        /*build test frame */
        [labelContent sizeToFit];
        imageview_Img.hidden = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize sizeToFit = [ message.text sizeWithFont:labelContent.font constrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
        [labelContent setWidth:sizeToFit.width+2];
        [labelContent setHeight:sizeToFit.height]; // set label content frame with tinkl
        
        //min height and width  is 35.0f
        //    fmaxf(35.0f, sizeToFit.height + 5.0f ) ,fmaxf(35.0f, sizeToFit.width + 10.0f )
        [imageview_BG setHeight:fmaxf(35.0f, sizeToFit.height + 18.0f )];
        [imageview_BG setWidth:fmaxf(35.0f, sizeToFit.width + 23.0f )];
        imageview_BG.hidden = NO;
        address.text = @"";
        address.hidden = YES;
        
        indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
        indictorView.top = imageview_BG.height/2  + 20;
        
        retryButton.left = imageview_BG.left + imageview_BG.width  ;
        retryButton.top = imageview_BG.height/2  + 10;
        
    }else if([message.messageType intValue] == messageType_emj)
    {
        labelContent.text  = @"";
        //display image  115 108
        [imageview_Img setImage:[UIImage imageNamed:message.text]];
//        imageview_Img.fullScreenImageURL = nil;
        imageview_Img.hidden = NO;
        imageview_Img.userInteractionEnabled = NO;
        [imageview_BG setHeight:108.0f];
        [imageview_BG setWidth:115.0f];
        
        
        [imageview_Img setHeight:100.0f];
        [imageview_Img setWidth:100.0f];
        
        imageview_BG.hidden = YES;
        address.text = @"";
        address.hidden = YES;
        
        
        indictorView.left = imageview_Img.left + imageview_Img.width  + 5;
        indictorView.top = imageview_Img.height/2  + 20;
        
        retryButton.left = imageview_Img.left + imageview_Img.width  ;
        retryButton.top = imageview_Img.height/2  + 10;
    }else if([message.messageType intValue] == messageType_map)
    {
        //display image  115 108
        labelContent.text  = @"";
        [imageview_Img setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:message.imageUrl Size:320]] placeholderImage:[UIImage imageNamed:@"messages_map_image_default"]];
//        imageview_Img.fullScreenImageURL = [NSURL URLWithString:message.imageUrl];
        imageview_Img.hidden = NO;
        [imageview_BG setWidth:174.0f];
        [imageview_BG setHeight:168.0f];
        
        [imageview_Img setHeight:160.0f];
        [imageview_Img setWidth:160.0f];
        
        imageview_BG.hidden = NO;
        imageview_Img.userInteractionEnabled = YES;
        address.text = message.text;
        address.hidden = NO;
        
        
        indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
        indictorView.top = imageview_BG.height/2  + 20;
        
        retryButton.left = imageview_BG.left + imageview_BG.width  ;
        retryButton.top = imageview_BG.height/2  + 10;
        
        
    }else if([message.messageType intValue] == messageType_audio)
    {
        labelContent.text = @"";
        //    [self creatAttributedLabel:message.content Label:labelContent];
        /*build test frame */
        [labelContent sizeToFit];
        imageview_Img.hidden = YES;
        //min height and width  is 35.0f
        //    fmaxf(35.0f, sizeToFit.height + 5.0f ) ,fmaxf(35.0f, sizeToFit.width + 10.0f )
        [imageview_BG setHeight:35.0f];
        [imageview_BG setWidth:80.0f];
        imageview_BG.hidden = NO;
        address.text = @"";
        address.hidden = YES;
        
        indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
        indictorView.top = imageview_BG.height/2  + 20;
        
        retryButton.left = imageview_BG.left + imageview_BG.width;
        retryButton.top = imageview_BG.height/2  + 10;
        
        audioButton.left = 50.0f;
        [audioButton.layer setValue:message.audioUrl forKey:@"audiourl"];
        if ([message.audioLength intValue] > 1000) {
            [audioButton setTitle:[NSString stringWithFormat:@"%d''",[message.audioLength intValue]/audioLengthDefine] forState:UIControlStateNormal];
        }else{
            if ([message.audioLength intValue] < 0) {
                int leng = [message.audioLength intValue];
                leng = -leng;
                 [audioButton setTitle:[NSString stringWithFormat:@"%d''",leng/audioLengthDefine] forState:UIControlStateNormal];
            }else{
                [audioButton setTitle:[NSString stringWithFormat:@"%d''",[message.audioLength intValue]] forState:UIControlStateNormal];
            }
        }
        
        [audioButton addTarget:self action:@selector(playaudioClick:) forControlEvents:UIControlEventTouchUpInside];
        Image_playing.left = imageview_BG.left + imageview_BG.width + 10;
        Image_playing.top = imageview_BG.height/2 + 17 ;
        
         if ([message.messageStatus boolValue])
         {
             //other
             [audioButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
         }else {
             //self
             [audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         }
    }
    
    return cell;
}


-(void) SeeBigImageviewClick:(id) sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    UIView * uiview =  buttonSender.superview.superview;
    XCJChatMessageCell * cell = (XCJChatMessageCell* ) uiview.superview;
    if ([cell.currentMessage.messageType  intValue] == messageType_image) {
        
        //    UIImageView *buttonSender = (UIImageView*)sender;
        IDMPhoto * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:cell.currentMessage.imageUrl]];
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
        [self presentViewController:browser animated:YES completion:nil];
    }
}

-(IBAction)playaudioClick:(id)sender
{
    UIButton * button = (UIButton*)sender;
    NSString * audiourl = [button.layer valueForKey:@"audiourl"];
    //close or stop other audio
    //[self.tableView reloadData];
     XCJChatMessageCell *cell = (XCJChatMessageCell *)button.superview.superview.superview;
    if (playingCell && cell != playingCell &&  playingCell.isplayingAudio) {
        if (playingURL) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
            [player stop];
        }
        [self StopPlayingimgArray:playingCell];
        playingCell.isplayingAudio = NO;
    }
    
   
    if (cell.isplayingAudio) {
        if (playingURL) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
            [player stop];
        }
//        [self.tableView reloadData];
        [self StopPlayingimgArray:cell];
        cell.isplayingAudio = NO;
    }else{
        
        playingCell = cell;
        cell.isplayingAudio = YES;
        //self.messageList[[self.tableView indexPathForCell:cell].row];
        if (audiourl) {
            //http://kidswant.u.qiniudn.com/FpWbDbq6UIkbCw5PunVVB8yphaDL
            NSArray *SeparatedArray = [[NSArray alloc]init];
            SeparatedArray =[audiourl componentsSeparatedByString:@"/"];
            NSString * filename = [SeparatedArray  lastObject];
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            //        NSURL * url =  [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",filename]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString * strFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString * fileNameWhole;
            if ([audiourl containString:@".amr"]) {
                fileNameWhole = [NSString stringWithFormat:@"%@/%@",strFile,filename];
            }else{
                fileNameWhole = [NSString stringWithFormat:@"%@/%@.amr",strFile,filename];
            }
            
            if(![fileManager fileExistsAtPath:fileNameWhole]) //如果不存在
            {
                button.userInteractionEnabled = NO;
                [button showIndicatorView];
                //download audio and play
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                NSURL *URL = [NSURL URLWithString:audiourl];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    SLLog(@"response type : %@",[response MIMEType]);
                    NSString * filename = [response suggestedFilename];
                    return [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",filename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    NSLog(@"File downloaded to: %@", filePath);
                    [button hideIndicatorView];
                    button.userInteractionEnabled = YES;
                    int leng = [self getFileSize:[NSString stringWithFormat:@"%@",fileNameWhole]];
                    //                [button setTitle:[NSString stringWithFormat:@"%d''",leng/1000] forState:UIControlStateNormal];
                    [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                    
                    //初始化播放器的时候如下设置
                    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                            sizeof(sessionCategory),&sessionCategory);
                    
                    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                             sizeof (audioRouteOverride), &audioRouteOverride);
                    
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    //默认情况下扬声器播放
                    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                    [audioSession setActive:YES error:nil];
                    playingURL = [NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                    player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
                    [player prepareToPlay];
                    [player play];
                    [self ShowPlayingimgArray:cell withTime:(int) leng/1024];
                }];
                [downloadTask resume];
            }else{
                button.userInteractionEnabled = YES;
                int leng = [self getFileSize:[NSString stringWithFormat:@"%@",fileNameWhole]];
//                [button setTitle:[NSString stringWithFormat:@"%d''",leng/1024] forState:UIControlStateNormal];
                [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                
                //初始化播放器的时候如下设置
                UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                        sizeof(sessionCategory),&sessionCategory);
                
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                         sizeof (audioRouteOverride), &audioRouteOverride);
                
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                //默认情况下扬声器播放
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                [audioSession setActive:YES error:nil];
                playingURL = [NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
                [player prepareToPlay];
                [player play];
                [self ShowPlayingimgArray:cell withTime:(int) leng/audioLengthDefine];
            }
            
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"播放失败,录音文件不存在"];
        }
    }
    
}


-(void) StopPlayingimgArray:(UITableViewCell*) cell
{
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    [Image_playing stopAnimating];
    [Image_playing.layer removeAllAnimations];
}

- (void) ShowPlayingimgArray:(UITableViewCell * ) cell withTime:(int) timer
{
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    NSArray * gifArray = [NSArray arrayWithObjects:
                [UIImage imageNamedTwo:@"voice_receive_icon_1"],
                [UIImage imageNamedTwo:@"voice_receive_icon_2"],
                [UIImage imageNamedTwo:@"voice_receive_icon_3"], nil];
    
    Image_playing.animationImages = gifArray; //动画图片数组
	Image_playing.animationDuration = 1; //执行一次完整动画所需的时长
	//    self.Image_playing.animationRepeatCount = 1;  //动画重复次数
	[Image_playing startAnimating];
    
    [self performSelector:@selector(removeImageAnimation:) withObject:cell afterDelay:timer];
}
-(void) removeImageAnimation:(id) cell
{
    UITableViewCell * cellself = cell;
    UIImageView * Image_playing = (UIImageView*)[cellself.contentView subviewWithTag:12];
    [Image_playing stopAnimating];
    Image_playing.image = nil;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJChatMessageCell * msgcell =(XCJChatMessageCell*) cell;
    UILabel * labelContent = (UILabel *) [msgcell.contentView subviewWithTag:4];
    [labelContent sizeToFit];
    
    /*   Message *message = self.messageList[indexPath.row];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    labelTime.text = [tools timeLabelTextOfTime:message.time];*/
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(35.0f, sizeToFit.height + 35.0f );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.inputTextView isFirstResponder]) {
        self.inputTextView.inputView = nil;
        [self.inputTextView resignFirstResponder];
        [self.inputTextView reloadInputViews];
    }else
    {
        FCMessage *message = self.messageList[indexPath.row];
        if ([message.messageType intValue] == messageType_text) {
            
            UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:message.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制", nil];
             action.tag = 1;
              PasteboardStr = message.text;
              [action showInView:self.view];
        }
    }
}

#pragma mark  heigth for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCMessage *message = self.messageList[indexPath.row];
    
    if ([message.messageType intValue] == messageType_SystemAD) {
        //系统公告
        float width =  APP_SCREEN_WIDTH * .7;
        float height = [self heightforsystem14:message.text withWidth:width];
        return  height + 10.0f;
    }
    
    if ([message.messageType intValue] == messageType_image || [message.messageType intValue] == messageType_emj ) {
        return 148.0f;
    }
    if ([message.messageType intValue] == messageType_map) {
        return 206.0f;
    }
    return [self heightForCellWithPost:message.text]+20.0f;
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableView.height = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
        
        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    }];
    
    
    //tableView滚动到底部
    [self scrollToBottonWithAnimation:YES];
    
    
    //    if (self.keyboardView&&self.keyboardView.frameY<self.keyboardView.window.frameHeight) {
    //        //到这里说明其不是第一次推出来的，而且中间变化，无需动画直接变
    ////        self.inputContainerViewBottomConstraint.top = keyboardFrame.size.height;
    //        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    ////        [self.view setNeedsUpdateConstraints];
    //        return;
    //    }
    
//    [self animateChangeWithConstant:keyboardFrame.size.height withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    //晚一小会获取。
//   [self performSelector:@selector(resetKeyboardView) withObject:nil afterDelay:0.001];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        
    
     [UIView animateWithDuration:0.3 animations:^{
         
//         self.inputContainerView.height  = 44.0f;
//         UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
//         imageBg.height = 44.0f;
//        ((UIImageView *) [self.inputContainerView subviewWithTag:2]).height = 33.0f;
//         self.inputTextView.height = 33;
         
         self.inputContainerView.top = self.view.height - self.inputContainerView.height;
         self.tableView.height  = self.view.height - self.inputContainerView.height;
     }];
    
    if(self.inputContainerView)
    {
        ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
        ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
        
    }
    
//    [self animateChangeWithConstant:0. withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    self.keyboardView = nil;
}

- (void)animateChangeWithConstant:(CGFloat)constant withDuration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve
{
    //self.inputContainerViewBottomConstraint.constant = constant;
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)resetKeyboardView {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    if (!keyboardWindow||![[keyboardWindow description] hasPrefix:@"<UITextEffectsWindow"]) return;
    self.keyboardView = keyboardWindow.subviews[0];
//#warning 以上只适用于IOS7，其他的系统需要测试。
}

#pragma mark  textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

{
    if([text isEqualToString:@"\n"])  {
        
        [self SendTextMsgClick:nil];
        return NO;
    }
    
//    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
//    if (![text isNilOrEmpty]) { //range.location >= 0 &&
//        button.enabled = YES;
//       [button infoStyle];
//       
//
//        
//    }
//    if (range.location == 0 && [text isNilOrEmpty]) {
//        [button defaultStyle];
//    }
    return YES;
}

#pragma mark UIPanGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.inputTextView isFirstResponder];
}

//这里不会让原本的触摸事件失效
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
#define kKeyboardBaseDuration .25f
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGFloat keyboardOrigY = self.keyboardView.window.frameHeight - self.keyboardView.frameHeight;
        static BOOL shouldDisplayKeyWindow = NO;
        static CGFloat lastVelocityY = 1;
        static BOOL isTouchedInputView = NO;
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            //初始化静态变量
            shouldDisplayKeyWindow = NO;
            lastVelocityY = 1;
            isTouchedInputView = NO;
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            //新的键盘位置
            CGFloat newKeyFrameY  = self.keyboardView.frameY + [panRecognizer locationInView:self.inputContainerView].y;
            //键盘所在window的高度
            CGFloat keyboardWindowFrameHeight = self.keyboardView.window.frameHeight;
            
            //修正最底和最高的位置
            if (newKeyFrameY < keyboardOrigY) {
                newKeyFrameY = keyboardOrigY;
            }else if (newKeyFrameY > keyboardWindowFrameHeight){
                newKeyFrameY = keyboardWindowFrameHeight;
            }
            
            //如果数值未变就不处理
            if (newKeyFrameY == self.keyboardView.frameY) {
                return;
            }else if (!isTouchedInputView) {
                //位置变动过说明动过输入框
                isTouchedInputView = YES;
                self.keyboardView.userInteractionEnabled = NO;
            }
            
            //移动到当前触摸位置
//            self.inputContainerViewBottomConstraint.constant = keyboardWindowFrameHeight - newKeyFrameY;
            [self.view setNeedsUpdateConstraints];
            
            //键盘位置
            self.keyboardView.frameY = newKeyFrameY;
            
            //根据方向判断是否隐藏键盘
            CGPoint velocity = [recognizer velocityInView:self.inputContainerView];
            if (velocity.y<0) {
                shouldDisplayKeyWindow = YES;
            }else{
                shouldDisplayKeyWindow = NO;
            }
            lastVelocityY = velocity.y;
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (!isTouchedInputView) {
                return;
            }
            //修正到适合的数值。
            CGFloat adjustVelocity = fabs(lastVelocityY)/750;
            adjustVelocity = adjustVelocity<1?1:adjustVelocity;
            CGFloat duration = kKeyboardBaseDuration/adjustVelocity;
            
            if (shouldDisplayKeyWindow) {
                //移动到原位置
//                self.inputContainerViewBottomConstraint.constant = self.keyboardView.frameHeight;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    //原键盘位置
                    self.keyboardView.frameY = keyboardOrigY;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                }];
            }else{
                //移动到原位置
//                self.inputContainerViewBottomConstraint.constant = 0;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    self.keyboardView.frameY = self.keyboardView.window.frameHeight;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                    //这样可以把原生的动画给覆盖掉，不显示
                    [UIView animateWithDuration:0. animations:^{
                        [self.inputTextView resignFirstResponder];
                    }];
                }];
            }
            
        }
    }
}

#pragma mark other common
- (void)scrollToBottonWithAnimation:(BOOL)animation
{
    if (self.messageList.count<=0) {
        return;
    }
    
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animation];
    }
    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
}

- (IBAction)EmjViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = YES;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = NO;
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
        
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = EmjView;
    EmjView.top = self.view.height - keyboardHeight;
    [self.inputTextView reloadInputViews];
    
}

- (IBAction)KeyBoradViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
    self.inputTextView.inputView = nil;
    EmjView.top = self.view.height;
    [self.inputTextView becomeFirstResponder];
    [self.inputTextView reloadInputViews];
    
}



@end
