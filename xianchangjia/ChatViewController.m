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

@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,MLActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MLTextView *inputTextView;

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
    self.inputTextView.scrollsToTop = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //加个拖动手势
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:panRecognizer];
    
    self.inputContainerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.inputContainerView.layer.borderWidth = .5f;
    //载入聊天记录
    //获取聊天列表
    NSArray *data =
    @[
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/1600725215/180/5628483622/1",
          @"name":@"天若有情天亦老天若有情天亦老天若有情天亦老天若有情天亦老",
          @"time":@1386039357,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/3217545835/50/40012531405/0",
          @"name":@"司空滢渟9945",
          @"time":@1386039358,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/3217545835/50/40012531405/0",
          @"name":@"司空滢渟9945",
          @"time":@1386039359,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp4.sinaimg.cn/1600725215/180/5628483622/1",
          @"name":@"天若有情天亦老天若有情天亦老天若有情天亦老天若有情天亦老",
          @"time":@1386039357,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1",
          @"name":@"炒股--达人",
          @"time":@1386039358,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1",
          @"name":@"炒股--达人",
          @"time":@1386039359,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
      @{
          @"avatarURL":@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1",
          @"name":@"炒股--达人",
          @"time":@1386039359,
          @"content":@"昨天你睡觉的时候在干什么。。天若有情天亦老天若有情天亦老天若有情天亦老",
          },
    ];
    
    [self.messageList turnObject:data];
    
    //重新排序
    [self.messageList sortWithAscending:YES];
    
    //初始化高度记录数组
    for (NSUInteger i=0; i<self.messageList.count; i++) {
        [self.messageCellHeights addObject:@0];
    }
    
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
    MLActionSheet *actionSheet = [[MLActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    [actionSheet showInView:self.view];
    //必须隐藏键盘否则会出问题。
    [self.inputTextView resignFirstResponder];
}

#pragma mark actionSheet delegate
- (void)actionSheet:(MLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
    message.content = @"。";
    message.time = [[NSDate date] timeIntervalSince1970];
    message.avatarURL = [NSURL URLWithString:@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1"];
    message.messageImage = postImage;
    //添加到列表
    [self.messageCellHeights addObject:@0];
    [self.messageList addObject:message];
}


#pragma mark - TextView delegate

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
    return cell;
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
    
    if (self.keyboardView&&self.keyboardView.frameY<self.keyboardView.window.frameHeight) {
        //到这里说明其不是第一次推出来的，而且中间变化，无需动画直接变
        self.inputContainerViewBottomConstraint.constant = keyboardFrame.size.height;
        [self.view setNeedsUpdateConstraints];
        return;
    }
    
    [self animateChangeWithConstant:keyboardFrame.size.height withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    //晚一小会获取。
    [self performSelector:@selector(resetKeyboardView) withObject:nil afterDelay:0.001];
    
    //tableView滚动到底部
    [self scrollToBottonWithAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];

    [self animateChangeWithConstant:0. withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    self.keyboardView = nil;
}

- (void)animateChangeWithConstant:(CGFloat)constant withDuration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve
{
    self.inputContainerViewBottomConstraint.constant = constant;
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
            self.inputContainerViewBottomConstraint.constant = keyboardWindowFrameHeight - newKeyFrameY;
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
                self.inputContainerViewBottomConstraint.constant = self.keyboardView.frameHeight;
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
                self.inputContainerViewBottomConstraint.constant = 0;
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
    //0.01秒的时间。
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    //在延迟0.1秒之后执行block
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
    });

}
@end
