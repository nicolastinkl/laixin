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
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    NSString * ImageFile;
}

@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) UIView *keyboardView;
@property (strong,nonatomic) NSMutableArray *messageList;
@end

@implementation ChatViewController

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
	// Do any additional setup after loading the view.
    self.title = self.conversation.facebookName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //加个拖动手势
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    panRecognizer.delegate = self;
//    [self.tableView addGestureRecognizer:panRecognizer];
    
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    
//    self.inputContainerView.layer.borderColor = [UIColor grayColor].CGColor;
//    self.inputContainerView.layer.borderWidth = 0.5f;
    self.inputContainerView.top = self.view.height - self.inputContainerView.height;
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
//    [self.tableView reloadData];
    
    //KVO监控chatList单例数组
//    [self.messageList addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior context:nil];
    
    [self setUpSequencer];
    
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
        
    }
    /* receive websocket message*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketDidReceivePushMessage:)
                                                 name:MLNetworkingManagerDidReceivePushMessageNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (operation && [operation isExecuting]) {
        [operation cancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    NSDictionary * MsgContent  = notification.userInfo;
    SLog(@"MsgContent :%@",MsgContent);
    if ([MsgContent[@"push"] intValue] == 1) {
        NSString *requestKey = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        if ([requestKey isEqualToString:@"newmsg"]) {
            /*
             {"push": true, "data": {"message": {"toid": 14, "msgid": 5, "content": "\u6211\u6765\u4e86sss", "fromid": 2, "time": 1388477804.0}}, "type": "newmsg"}
             */
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"message"];
            
            NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
            if ([self.conversation.facebookId isEqualToString:facebookID]) {
                // int view
                NSString * content = dicMessage[@"content"];
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
                msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                
                self.conversation.lastMessageDate = date;
                self.conversation.badgeNumber = @0;
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
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                self.conversation.lastMessage = content;
                self.conversation.lastMessageDate = date;
                
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

- (IBAction)SendTextMsgClick:(id)sender {
    NSString * text = self.inputTextView.text;
    if ([text trimWhitespace].length > 0) {
        //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
        
        NSDictionary * parames = @{@"uid":self.conversation.facebookId,@"content":text};
        [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
            NSDictionary * dic = [responseObject objectForKey:@"result"];
            if (dic) {
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
                self.inputTextView.text = @"";
                [self.conversation addMessagesObject:msg];
                [self.messageList addObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
                UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
                [button defaultStyle];
                [self insertTableRow];
            }
           
        } failure:^(MLRequest *request, NSError *error) {
        }];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view];
    //必须隐藏键盘否则会出问题。
    [self.inputTextView resignFirstResponder];
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

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    //upload image
    [self performSelector:@selector(uploadContent:) withObject:theInfo];
    
    
}

- (void)uploadContent:(NSDictionary *)theInfo {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
    
    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
        NSString * namefile =  [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@",timeDesc,self.conversation.facebookId]];
        NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        NSLog(@"Upload Path: %@", filePath);
        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 1);
        [webData writeToFile:filePath atomically:YES];
        [self uploadFile:filePath  key:key];
    }
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
    
    NSDictionary * parames = @{@"uid":self.conversation.facebookId};
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
        NSDictionary * dic = [responseObject objectForKey:@"result"];
        if (dic) {
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = @"";
            msg.sentDate = [NSDate date];
            msg.messageType = @(messageType_image);
            msg.messageId = msgid;
            msg.imageUrl = url;
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            self.conversation.lastMessage = @"[图片]";
            self.conversation.lastMessageDate = [NSDate date];
            self.conversation.badgeNumber = @0;
            [self.conversation addMessagesObject:msg];
            [self.messageList addObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
            [button defaultStyle];
            [self insertTableRow];
        }
        
    } failure:^(MLRequest *request, NSError *error) {
    }];
}


- (void)uploadFile:(NSString *)filePath  key:(NSString *)key {
    // setup 1: frist get token
    //http://service.xianchangjia.com/upload/Message?sessionid=YtcS7pKQSydYPnJ
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
        if (response) {
            NSString * token =  [response objectForKey:@"token"];
            TokenAPP = token;
            ImageFile = filePath;
            [self uploadImage:filePath token:token];
        }
    } withParems:[NSString stringWithFormat:@"upload/Message?sessionid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
}

-(void) uploadImage:(NSString *)filePath  token:(NSString *)token
{
//    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
//    [img setImage:[UIImage imageWithContentsOfFile:filePath]];
//    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"1" forKey:@"filetype"];
    [parameters setValue:@"" forKey:@"content"];
    [parameters setValue:@"" forKey:@"length"];
    [parameters setValue:self.conversation.facebookId forKey:@"toid"];
    operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        //        [formData appendPartWithFileData:imageData name:@"user_avatar" fileName:@"me.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            if (result) {
                NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                [self SendImageWithMeImageurl:url withMsgID:msgID];
            }
           
          //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SLog(@"error :%@",error.userInfo);
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
    SLog(@" nuount : %d",self.messageList.count );
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   /* static NSString *CellIdentifier = @"MessageCell";
    XCJChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row>0&&[((Message*)self.messageList[indexPath.row-1]).name isEqualToString:((Message*)self.messageList[indexPath.row]).name]) {
        cell.isDisplayOnlyContent = YES;
    }else{
        cell.isDisplayOnlyContent = NO;
    }
    
    cell.message = self.messageList[indexPath.row];
#warning 现在是根据名字来判断是否本人，实际情况需要根据uid来判断
    if (![cell.message.name isEqualToString:self.chat.name]) {
        cell.backgroundColor = [UIColor colorWithWhite:0.883 alpha:1.000];
    }else{
        cell.backgroundColor = [UIColor colorWithWhite:0.970 alpha:1.000];
    }
    */
    static NSString *CellIdentifier = @"XCJChatMessageCell";
    XCJChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FCMessage *message = self.messageList[indexPath.row];
//#warning 现在是根据名字来判断是否本人，实际情况需要根据uid来判断
//    if (![message.name isEqualToString:self.chat.name]) {
//        cell.backgroundColor = [UIColor colorWithWhite:0.883 alpha:1.000];
//    }else{
//        cell.backgroundColor = [UIColor colorWithWhite:0.970 alpha:1.000];
//    }
    
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelName = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    UILabel * labelContent = (UILabel *) [cell.contentView subviewWithTag:4];
//    labelContent.delegate = self;
    UIImageView * imageview_Img = (UIImageView *)[cell.contentView subviewWithTag:5];
    UIImageView * imageview_BG = (UIImageView *)[cell.contentView subviewWithTag:6];
    
    if ([message.messageStatus boolValue]) {
        //Incoming
        [imageview setImageWithURL:[NSURL URLWithString:self.userinfo.headpic]];
        labelName.text = self.userinfo.nick;
    }else{
        //Outcoming
        [imageview setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];
        labelName.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    }
    labelTime.text = [tools FormatStringForDate:message.sentDate];
    labelContent.text = message.text;
//    [self creatAttributedLabel:message.content Label:labelContent];
    /*build test frame */
    [labelContent sizeToFit];
    if ([message.messageType intValue] == messageType_image) {
        //display image  115 108
        [imageview_Img setImageWithURL:[NSURL URLWithString:message.imageUrl]];
        imageview_Img.hidden = NO;
        [imageview_BG setHeight:108.0f];
        [imageview_BG setWidth:115.0f];
    }else if ([message.messageType intValue] == messageType_text) {
        imageview_Img.hidden = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize sizeToFit = [ message.text sizeWithFont:labelContent.font constrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
        [labelContent setWidth:sizeToFit.width];
        [labelContent setHeight:sizeToFit.height]; // set label content frame with tinkl
       
        //min height and width  is 35.0f
        //    fmaxf(35.0f, sizeToFit.height + 5.0f ) ,fmaxf(35.0f, sizeToFit.width + 10.0f )
        [imageview_BG setHeight:fmaxf(35.0f, sizeToFit.height + 18.0f )];
        [imageview_BG setWidth:fmaxf(35.0f, sizeToFit.width + 23.0f )];
    }
    
    return cell;
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
        [self.inputTextView resignFirstResponder];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCMessage *message = self.messageList[indexPath.row];
    if ([message.messageType intValue] == messageType_image) {
        return 148.0f;
    }
    return [self heightForCellWithPost:message.text]+20.0f;
}


#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:0.3 animations:^{
        
        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
        self.tableView.height = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
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
         
         self.inputContainerView.top = self.view.height - self.inputContainerView.height;
         self.tableView.height  = self.view.height - self.inputContainerView.height;
     }];
    
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
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    if (![text isNilOrEmpty]) { //range.location >= 0 &&
        button.enabled = YES;
       [button infoStyle];
    }
    if (range.location == 0 && [text isNilOrEmpty]) {
        [button defaultStyle];
    }
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
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
    

}
@end
