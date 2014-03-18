//
//  XCJMessageReplyInfoViewController.m
//  laixin
//
//  Created by apple on 14-1-17.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJMessageReplyInfoViewController.h"
#import "ActivityTableViewCell.h"
#import "XCJUserInfoController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "FCReplyMessage.h"
#import "XCJGroupPost_list.h"
#import "Comment.h"
#import "UIAlertViewAddition.h"
#import "InterceptTouchView.h"
#import "FCUserDescription.h"
#import "XCJGroupPost_list.h"

@interface XCJMessageReplyInfoViewController ()<ActivityTableViewCellDelegate,UITextViewDelegate,InterceptTouchViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    XCJGroupPost_list * currentGroup;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UITextView *inputTextView;
@property (nonatomic,strong) UIImageView *inputTextBackView;

@property (nonatomic,assign) CGFloat tableBaseYOffsetForInput;


@property (nonatomic,strong) NSMutableArray *cellHeights;
@end

@implementation XCJMessageReplyInfoViewController


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
    self.title = @"详细";
//    UIView *origView = self.view;
//    self.view = [[InterceptTouchView alloc]initWithFrame:origView.frame];
//    
//    ((InterceptTouchView*)self.view).interceptTouchViewDelegate = self;
    
//    origView.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    

    //评论输入框
    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frameBottom,self.view.frameWidth, 47)];
    _inputView.backgroundColor = [UIColor whiteColor];
    _inputView.layer.borderColor = [UIColor grayColor].CGColor;
    _inputView.layer.borderWidth = .5f;
   
    
    UIImageView *textBackView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 6, _inputView.frameWidth-8*2, _inputView.frameHeight-6*2)];
    textBackView.image = [[UIImage imageNamed:@"edit_text_bg.png"]stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f];
    [_inputView addSubview:self.inputTextBackView = textBackView];
    
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(textBackView.frameX+5, textBackView.frameY+1, textBackView.frameWidth-5*2, textBackView.frameHeight-1*2)];
    _inputTextView.clipsToBounds = YES;
    self.inputTextView.delegate = self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:14];
    _inputTextView.scrollsToTop = NO;
    [_inputView addSubview:_inputTextView];
    [self.view addSubview:_inputView];
    //监视输入内容大小，在KVO里自动调整
//    [_inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    
    if (self.message.jsonStr) {
        // fromat
        NSDictionary * obj =  self.message.jsonStr;
        if (obj) {
            XCJGroupPost_list * list = [XCJGroupPost_list turnObject:obj];
            currentGroup = list;
            [self initLikesCount];
            [self.tableView reloadData];
        }
    }else{
        if (self.post) {
            currentGroup = self.post;
//            拉取 赞的人
            [self initLikesCount];
            [self.tableView reloadData];
        }else{
            //post.get(postid) 参数可以是数组
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.get" parameters:@{@"postid": self.message.postid} success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    NSDictionary * dict = responseObject[@"result"];
                    NSArray *array = dict[@"posts"];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if (idx == 0) {
                            self.message.jsonStr =  obj;
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                            XCJGroupPost_list * list = [XCJGroupPost_list turnObject:obj];
                            currentGroup = list;
                            [self initLikesCount];
                            [self.tableView reloadData];
                        }
                    }];
                }
            } failure:^(MLRequest *request, NSError *error) {
                [self showErrorText:@"数据请求失败"];
            }];

        }
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) initLikesCount
{
    /*
    if(currentGroup.like > 0)
    {
        NSDictionary * parames = @{@"postid":currentGroup.postid,@"pos":@0,@"count":@"100"};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.likes" parameters:parames success:^(MLRequest *request, id responseObject) {
            NSDictionary * groups = responseObject[@"result"];
            NSArray * postsDict =  groups[@"users"];
            if (postsDict&& postsDict.count > 0) {
                NSMutableArray * mutaArray = [[NSMutableArray alloc] init];
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    postlikes * likes = [postlikes turnObject:obj];
                    [mutaArray addObject:likes];
                }];
                currentGroup.like = postsDict.count;
                [currentGroup.likeUsers  removeAllObjects];
                [currentGroup.likeUsers addObjectsFromArray:mutaArray];
                //indexofActivitys
                [self.tableView reloadData];
            }
        } failure:^(MLRequest *request, NSError *error) {
            
        }];
    }*/
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XCJGroupPost_list *activity = currentGroup;
    if (activity) {
        if (_cellHeights&&[_cellHeights[indexPath.row] floatValue]>0) {
            return [_cellHeights[indexPath.row] floatValue];
        }
        
        static NSString *CellIdentifier = @"Cell";
        ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ActivityTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.activity = currentGroup;
        
        [_cellHeights replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:cell.cellHeight]];
        
        return cell.cellHeight;
    }
    return 46+10*2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_inputTextView.isFirstResponder) {
        [_inputTextView resignFirstResponder];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ActivityTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    XCJGroupPost_list* activity = currentGroup;
    cell.needRefreshViewController = self;
    
   
    //    cell.indexofActivitys =  [self.activities indexOfObject:activity];
    cell.activity = activity;
    // start requst comments  and likes
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)activityCell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XCJGroupPost_list* activity = currentGroup;
    ActivityTableViewCell *cell = (ActivityTableViewCell *)activityCell;
    
//    if (activity.like == 0 && !cell.HasLoadlisks) {
//        cell.HasLoadlisks = YES;
//        if (activity) {
//            NSDictionary * parames = @{@"postid":activity.postid,@"pos":@0,@"count":@"1000"};
//            [[MLNetworkingManager sharedManager] sendWithAction:@"post.likes" parameters:parames success:^(MLRequest *request, id responseObject) {
//                NSDictionary * groups = responseObject[@"result"];
//                NSArray * postsDict =  groups[@"users"];
//                if (postsDict&& postsDict.count > 0) {
//                    NSMutableArray * mutaArray = [[NSMutableArray alloc] init];
//                    [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        postlikes * likes = [postlikes turnObject:obj];
//                        [mutaArray addObject:likes];
//                    }];
//                    
//                    [activity.likeUsers addObjectsFromArray:mutaArray];
//                    activity.like = postsDict.count;
//                    //indexofActivitys
//                    [self reloadSingleActivityRowOfTableView:0  withAnimation:NO];
//                }
//                cell.HasLoadlisks = YES;
//            } failure:^(MLRequest *request, NSError *error) {
//                cell.HasLoadlisks =YES;
//            }];
//        }else{
//            //[UIAlertView showAlertViewWithMessage:@"该条动态不存在"];
//        }
//        
//    }
    
    if (activity.replycount > 0 && activity.comments.count <= 0 && !cell.HasLoad) {
        /* get all list data*/
        cell.HasLoad = YES;
        if (activity) {
            NSDictionary * parames = @{@"postid":activity.postid,@"pos":@0,@"count":@"1000"};
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.get_reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //    postid = 12;
                /*
                 Result={
                 “posts”:[*/
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"replys"];
                if (postsDict && postsDict.count > 0) {
                    NSMutableArray * mutaArray = [[NSMutableArray alloc] init];
                    [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Comment * comment = [Comment turnObject:obj];
                        [mutaArray addObject:comment];
                    }];
                    activity.comments =mutaArray;
                    activity.replycount = postsDict.count;
                    //indexofActivitys
                    [self reloadSingleActivityRowOfTableView:0 withAnimation:NO];
                }
                cell.HasLoad = YES;
            } failure:^(MLRequest *request, NSError *error) {
                cell.HasLoad = NO;
            }];
        }else{
            //[UIAlertView showAlertViewWithMessage:@"该条动态不存在"];
        }
        
    }
    
    if (activity.excount > 0) {
        if (activity.excountImages.count <= 0 && !cell.isloadingphotos) {
            //check from networking
            
            cell.isloadingphotos = YES;
            NSString * cacheKey = [NSString stringWithFormat:@"post.readex.%@",activity.postid];
            NSArray * cahceArray = [[EGOCache globalCache] plistForKey:cacheKey];
            //            SLog(@"cahceArray :%@",cahceArray);
            if (cahceArray && cahceArray.count > 0) {
                NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                [[cahceArray mutableCopy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                    [arrayURLS addObject:stringurl];
                }];
                activity.excountImages = arrayURLS ;
                cell.isloadingphotos = NO;
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }else{
                
                [[MLNetworkingManager sharedManager] sendWithAction:@"post.readex" parameters:@{@"postid":activity.postid} success:^(MLRequest *request, id responseObject) {
                    if (responseObject) {
                        NSDictionary  * result = responseObject[@"result"];
                        NSArray * array = result[@"exdata"];
                        if (array.count > 0) {
                            [[EGOCache globalCache]  setPlist:[array mutableCopy] forKey:cacheKey];
                        }
                        NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                            [arrayURLS addObject:stringurl];
                        }];
                        [activity.excountImages removeAllObjects];
                        [activity.excountImages addObjectsFromArray:arrayURLS];
                        //                    [_tableView reloadData];
                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    cell.isloadingphotos = NO;
                } failure:^(MLRequest *request, NSError *error) {
                    cell.isloadingphotos = NO;
                }];
            }
        }
        
    }
}
#pragma mark  comments

- (void)reloadSingleActivityRowOfTableView:(NSInteger)row withAnimation:(BOOL)animation
{
    [_cellHeights replaceObjectAtIndex:row withObject:@0];
    [self.tableView reloadData];
    
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

- (void)sendCommentContent:(NSString*)content ToActivity:(XCJGroupPost_list*)currentOperateActivity atCommentIndex:(NSInteger)commentIndex
{
    if ([content isNilOrEmpty]) {
        return;
    }
    
    NSDictionary * parames = @{@"postid":currentOperateActivity.postid,@"content":content};
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"replyid":1}
        
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            NSString * repID = [DataHelper getStringValue:result[@"replyid"] defaultValue:@""];
            
            int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
            if (localreplyid < [repID intValue]) {
                [USER_DEFAULT setInteger:[repID intValue] forKey:KeyChain_Laixin_Max_ReplyID];
                [USER_DEFAULT synchronize];
            }
            
            Comment  *comment = [[Comment alloc] init];
            comment.replyid = repID;
            comment.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
            comment.postid = currentOperateActivity.postid;
            comment.time = [[NSDate date] timeIntervalSince1970];
            comment.content = content;
            [currentOperateActivity.comments addObject:comment];
            //刷新此cell
            [self reloadSingleActivityRowOfTableView:0 withAnimation:NO];
        }
        //        //升序排序
        //        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_time" ascending:YES];
        //        [currentOperateActivity.comments sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"回复失败 请重试!"];
    }];
    
}


- (void)clickDeleteButton:(UIButton *)commentButton onActivity:(XCJGroupPost_list *)activity
{
    if (activity) {
        [SVProgressHUD show];
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.delete" parameters:@{@"postid":activity.postid} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                // delete ok
                [SVProgressHUD dismiss];
                @try {
//                    int index = [self.activities indexOfObject:activity];
//                    [self.cellHeights removeObjectAtIndex:index];
//                    [self.activities removeObject:activity];
//                    NSIndexPath  * indexpath = [NSIndexPath indexPathForRow:index inSection:0];
//                    [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationTop];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                @catch (NSException *exception) {
                    [UIAlertView showAlertViewWithMessage:@"删除失败"];
                }
                @finally {
                    
                }
                
            }
            
            
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"删除失败"];
            [SVProgressHUD dismiss];
        }];
    }
}


#pragma mark - ActivityTableViewCellDelegate
//点击某用户名
- (void)clickUserID:(NSString *)uid onActivity:(XCJGroupPost_list *)activity
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id result, NSError * error) {
        infoview.UserInfo = result;
        infoview.title = @"详细资料";
        [self.navigationController pushViewController:infoview animated:YES];
    } withuid:uid];
}

//点击当前activity的发布者头像
- (void)clickAvatarButton:(UIButton *)avatarButton onActivity:(XCJGroupPost_list *)activity
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id result, NSError * error) {
        infoview.UserInfo = result;
        infoview.title = @"详细资料";
        [self.navigationController pushViewController:infoview animated:YES];
    } withuid:activity.uid];
}

#pragma mark - InterceptTouchViewDelegate
- (BOOL)interceptTouchWithView:(UIView *)view
{
    if (![view isEqual:_inputTextView]&&[_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
        return YES;
    }
    return NO;
}

//点击评论按钮
- (void)clickCommentButton:(UIButton *)commentButton onActivity:(XCJGroupPost_list *)activity
{
    //滚动到指定activity的底部-10像素
//    NSInteger index = [_activities indexOfObject:activity];
    CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.tableBaseYOffsetForInput = rectOfCellInTableView.origin.y+rectOfCellInTableView.size.height-10;
//
//    self.currentOperateActivity = activity;
//    self.currentCommentToUserIndex = -1;
    [_inputTextView becomeFirstResponder];
    
}



- (void)clickLikeButton:(UIButton *)likeButton onActivity:(XCJGroupPost_list *)activity
{
    likeButton.enabled = NO;
    //赞
    if (!activity.ilike) {
        
        NSDictionary * parames = @{@"postid":activity.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
            activity.ilike = YES;
            activity.like ++;
            likeButton.enabled = YES;
//            [activity.likeUsers addObject:[[LXAPIController sharedLXAPIController] currentUser]];
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"点赞失败 请重试!"];
        }];
    }else{
        NSDictionary * parames = @{@"postid":activity.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.dislike"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //如果有则删除，没有则不动啊
//            for (LXUser *aUser in activity.likeUsers) {
//                if ([aUser.uid isEqualToString:[[LXAPIController sharedLXAPIController] currentUser].uid]) {
//                    [activity.likeUsers removeObject:aUser];
//                    break;
//                }
//            }
            activity.like -- ;
            activity.ilike = NO;
            likeButton.enabled = YES;
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"取消赞失败 请重试!"];
        }];
    }
    
    //执行赞图标放大的动画
    likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
    [UIView animateWithDuration:.50f
                     animations:^{
                         likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                         //刷新对应行
                         [self reloadSingleActivityRowOfTableView:0 withAnimation:NO];
                     }];
}


//点击评论View中的某行(当前如果点击的是其中的某用户是会忽略的)
- (void)clickCommentsView:(UIView *)commentsView atIndex:(NSInteger)index atBottomY:(CGFloat)bottomY onActivity:(XCJGroupPost_list *)activity
{
    //滚动到指定activity的底部-5像素
    CGRect rectOfCellInTableView = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.tableBaseYOffsetForInput = rectOfCellInTableView.origin.y+commentsView.frameY+bottomY;
    
    Comment * comment = currentGroup.comments[index];
    if(![comment.uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
    {
        // if is me...
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            FCUserDescription * user = response;
            _inputTextView.text = [NSString stringWithFormat:@"@%@:",user.nick];
            [_inputTextView becomeFirstResponder];
        } withuid:comment.uid];
    }else{
        _inputTextView.text = @"";
        [_inputTextView becomeFirstResponder];
    }
}

#pragma mark - TextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        if (![_inputTextView.text isNilOrEmpty]) {
            
            [self sendCommentContent:_inputTextView.text ToActivity:currentGroup atCommentIndex:0];
            
//            self.currentOperateActivity = nil;
//            self.currentCommentToUserIndex = -1;
            
            _inputTextView.text = @"";
            [_inputTextView resignFirstResponder];
        }
        return NO;
    };
    return YES;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]){
        //高度最大为80
        static CGFloat maxHeight = 80;
        
        CGFloat origHeight = _inputTextView.frameHeight;
        _inputTextView.frameHeight = (_inputTextView.contentSize.height<=maxHeight)?_inputTextView.contentSize.height:maxHeight;
        
        CGFloat offset = _inputTextView.frameHeight - origHeight;
        
        _inputTextBackView.frameHeight +=offset;
        _inputView.frameHeight +=offset;
        _inputView.frameY -=offset;
        
        //tableView的位置也修正下
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y+offset);
    }
    
    if ([keyPath isEqualToString:@"changeTitle"]) {
//        self.titleString = [NSString stringWithFormat:@"%@",object];
        //        self.titleview.titleView.text = self.titleString;
        //        [self.titleview.titleView sizeToFit];
    }
    // [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGFloat newY = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y - _inputView.frameHeight;//-64
    
    self.tableView.userInteractionEnabled = NO;
    
    //调整tableView的位置
    CGFloat newYOffset = self.tableView.contentOffset.y;
    if (_tableBaseYOffsetForInput) {
        newYOffset = _tableBaseYOffsetForInput-(newY-self.tableView.frameY);
        if (newYOffset<0) { //最顶部
            newYOffset = 0;
        }
    }
    
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                         _inputView.frameY =  self.view.height - keyboardFrame.size.height - 44;// newY;
                         self.tableView.contentOffset = CGPointMake(0, newYOffset );
                     }
                     completion:^(BOOL finished) {
                         self.tableView.userInteractionEnabled = YES;
                     }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    self.tableView.userInteractionEnabled = NO;
    
    //调整tableView位置
    if (_tableView.contentOffset.y > _tableView.contentSize.height-_tableView.frameHeight) {//最底部
           [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         _inputView.frameY = self.view.frameBottom + 100;
                     }
                     completion:^(BOOL finished) {
                         self.tableView.userInteractionEnabled = YES;
                     }];
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
