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
#import "Chat.h"
#import "MessageCell.h"
#import "MessageList.h"
#import "Message.h"
#import "XCAlbumAdditions.h"
#import "XCJChatMessageCell.h"
#import "XCAlbumAdditions.h"
#import "CustomMethod.h"
#import "MarkupParser.h"
#import "OHAttributedLabel.h"
#import "UIButton+Bootstrap.h"

@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (weak, nonatomic) UIView *keyboardView;


@property (strong,nonatomic) MessageList *messageList;
@property (strong,nonatomic) NSMutableArray *messageCellHeights;

@property (nonatomic, strong) MessageCell *prototypeCell;

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
    self.title = self.chat.name;
//    self.inputTextView.scrollsToTop = NO;
    
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
    //载入聊天记录
    //获取聊天列表
    NSArray *data =
    @[
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/1600725215/180/5628483622/1",
          @"name":@"天若有情天亦老天若有情天亦老天若有情天亦老天若有情天亦老",
          @"time":@1386039357,
          @"content":@"昨天你睡觉的时候",
          },
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/3217545835/50/40012531405/0",
          @"name":@"司空滢渟9945",
          @"time":@1386039358,
          @"content":@"昨天你睡觉的时候在干 2.绘制",
          }
    ];
    
    [self.messageList turnObject:data];
    
    //重新排序
    [self.messageList sortWithAscending:YES];
    
    //初始化高度记录数组
//    for (NSUInteger i=0; i<self.messageList.count; i++) {
//        [self.messageCellHeights addObject:@0];
//    }
    
    //重载TableView
    [self.tableView reloadData];
    
    //KVO监控chatList单例数组
    [self.messageList addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior context:nil];

    //tableView底部
    [self scrollToBottonWithAnimation:NO];
}

- (void)dealloc
{
    //删除Observer
	[self.messageList removeObserver:self forKeyPath:@"array"];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SendTextMsgClick:(id)sender {
    Message *message = [[Message alloc]init];
    message.name = @"天王盖地虎";
    message.content = self.inputTextView.text;
    message.time = [[NSDate date] timeIntervalSince1970];
    message.avatarURL = [NSURL URLWithString:@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1"];
    //添加到列表
    [self.messageList addObject:message];
    self.inputTextView.text = @"";
     UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
}

- (MessageList*)messageList
{
    if (!_messageList) {
        _messageList = [[MessageList alloc]init];
    }
    return _messageList;
}

- (NSMutableArray*)messageCellHeights
{
    if (!_messageCellHeights) {
        _messageCellHeights = [[NSMutableArray alloc]init];
    }
    return _messageCellHeights;
}

#warning 测试是否捕获到了正确的键盘
- (IBAction)adjustKeyboardFrame:(id)sender {
    //检测冲突
    [self.view exerciseAmiguityInLayoutRepeatedly:YES];
    //其他
    //    if (self.keyboardView) {
    //        CGRect frame = self.keyboardView.frame;
    //        frame.origin.y += 2;
    //        self.keyboardView.frame = frame;
    //
    //        static CGFloat green = 255.0;
    //        green -= 10;
    //        if (green<0) {
    //            green = 255.0;
    //        }
    //        self.keyboardView.backgroundColor = [UIColor colorWithRed:0 green:green/255.0 blue:0 alpha:1.0];
    //    }
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
    
    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    Message *message = [[Message alloc]init];
    message.name = @"天王盖地虎";
    message.content = @"";
    message.time = [[NSDate date] timeIntervalSince1970];
    message.avatarURL = [NSURL URLWithString:@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1"];
    message.messageImage = postImage;
    //添加到列表
    [self.messageCellHeights addObject:@0];
    [self.messageList addObject:message];
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
    
    label.delegate = self;
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
    Message *message = self.messageList[indexPath.row];
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
    [imageview setImageWithURL:message.avatarURL];
    labelName.text = message.name;
    labelTime.text = [tools timeLabelTextOfTime:message.time];
    labelContent.text = message.content;
//    [self creatAttributedLabel:message.content Label:labelContent];
    /*build test frame */
    [labelContent sizeToFit];
    if (message.messageImage) {
        //display image  115 108
        [imageview_Img setImage:message.messageImage];
        imageview_Img.hidden = NO;
        [imageview_BG setHeight:108.0f];
        [imageview_BG setWidth:115.0f];
    }else{
        imageview_Img.hidden = YES;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize sizeToFit = [ message.content sizeWithFont:labelContent.font constrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
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
    Message *message = self.messageList[indexPath.row];
    if (message.messageImage) {
        return 148.0f;
    }
    return [self heightForCellWithPost:message.content]+20.0f;

    //如果有记录，直接返回
    if ([self.messageCellHeights[indexPath.row] integerValue]>0) {
        return [self.messageCellHeights[indexPath.row] doubleValue];
    }
    
    if (!self.prototypeCell)
    {
        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    }
    
    self.prototypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row>0&&[((Message*)self.messageList[indexPath.row-1]).name isEqualToString:((Message*)self.messageList[indexPath.row]).name]) {
        self.prototypeCell.isDisplayOnlyContent = YES;
    }else{
        self.prototypeCell.isDisplayOnlyContent = NO;
    }
    
    self.prototypeCell.message = self.messageList[indexPath.row];
    
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    //记录高度
    self.messageCellHeights[indexPath.row] = [NSNumber numberWithDouble:size.height+1];
    
    return size.height+1;
}


#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    if (self.keyboardView&&self.keyboardView.frameY<self.keyboardView.window.frameHeight) {
//        //到这里说明其不是第一次推出来的，而且中间变化，无需动画直接变
////        self.inputContainerViewBottomConstraint.top = keyboardFrame.size.height;
//        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
////        [self.view setNeedsUpdateConstraints];
//        return;
//    }
    
    
    self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    self.tableView.height = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    //tableView滚动到底部
    [self scrollToBottonWithAnimation:YES];
    
//    [self animateChangeWithConstant:keyboardFrame.size.height withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    //晚一小会获取。
//   [self performSelector:@selector(resetKeyboardView) withObject:nil afterDelay:0.001];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.inputContainerView.top = self.view.height - self.inputContainerView.height;
    self.tableView.height  = self.view.height - self.inputContainerView.height;
    
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
#warning 以上只适用于IOS7，其他的系统需要测试。
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
