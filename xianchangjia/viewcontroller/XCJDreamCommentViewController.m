//
//  XCJDreamCommentViewController.m
//  laixin
//
//  Created by apple on 4/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDreamCommentViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "Comment.h"
#import "FCUserDescription.h"
#import "XCJAddUserTableViewController.h"
#import "SBSegmentedViewController.h"

@interface XCJDreamCommentViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *  _datasource;
    int currentPage;
    UIButton * button_load;
    UIView * view_load;
    Boolean noMoreData;
}


@property (strong, nonatomic) IBOutlet UIView *View_inputview;
@property (weak, nonatomic) IBOutlet UIButton *button_keyboard;
@property (weak, nonatomic) IBOutlet UITextField *textfield_content;
@property (weak, nonatomic) IBOutlet UIButton *button_send;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation XCJDreamCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
        [self.button_send sendMessageClearStyle];
        self.button_send.enabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /**
     *  default location frame
     */
    // Do any additional setup after loading the view.
    self.tableview.height = APP_SCREEN_HEIGHT - self.View_inputview.height;
    
    self.View_inputview.top = APP_SCREEN_HEIGHT - self.View_inputview.height;
        
    self.button_send.enabled = NO;
    
    [self.button_send labelphotoStyle];
    
    self.textfield_content.delegate = self;
    
    /**
     *  default state
     */
    [self.button_keyboard setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    noMoreData = NO;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    _datasource =array;
    currentPage = 0;
    
    
    SBSegmentedViewController *segmentedViewController =  (SBSegmentedViewController *)self.navigationController.visibleViewController;
    id someobj = segmentedViewController.someobject;
    
    self.groupPost = someobj;
    self.postid = self.groupPost.postid;
    [self loadData:currentPage];
}
  

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.button_keyboard setImage:[UIImage imageNamed:@"bar_down_keyboard_icon"] forState:UIControlStateNormal];
    [self.textfield_content resignFirstResponder];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (IBAction)sendContent_Click:(id)sender {
    [self.button_keyboard setImage:[UIImage imageNamed:@"bar_down_keyboard_icon"] forState:UIControlStateNormal];
    [self.textfield_content resignFirstResponder];
    
    if (self.textfield_content.text.length > 0) {
        [self sendContentWith:self.textfield_content.text];
    }
    
}

- (IBAction)keyboardOperationClick:(id)sender {
    if ([self.textfield_content isFirstResponder]) {
        //键盘是弹出的
        
        [self.button_keyboard setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor"] forState:UIControlStateNormal];
        [self.textfield_content resignFirstResponder];
        
    }else{
        [self.textfield_content becomeFirstResponder];
        [self.button_keyboard setImage:[UIImage imageNamed:@"bar_down_keyboard_icon"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
    
}

#pragma mark - Keyboard
- (void)keyboardWillShowHide:(NSNotification *)notification
{
    //    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.View_inputview.superview convertRect:keyboardFrame fromView:nil];
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newTextFieldFrame = self.View_inputview.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    CGFloat inputViewFrameY = keyboardY - self.View_inputview.height;
    // for ipad modal form presentations
    CGFloat messageViewFrameBottom = self.view.frame.size.height - self.View_inputview.height;
    if (inputViewFrameY > messageViewFrameBottom)
        inputViewFrameY = messageViewFrameBottom;
    
    [self.View_inputview setTop:inputViewFrameY];
    
    //[self setTableViewInsetsWithBottomValue:self.view.frame.size.height  - self.View_inputview.frame.origin.y - self.View_inputview.height];
    
    [UIView commitAnimations]; 
    
}


#pragma mark - Dismissive text view delegate

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.tableview.contentInset = insets;
    //    self.tableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    insets.bottom = bottom;
    
    return insets;
}



-(void) sendContentWith:(NSString*) content
{
    [SVProgressHUD show];
    NSDictionary * parames = @{@"postid":self.postid,@"content":content};
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"replyid":1}
        
        if (responseObject) {
            [SVProgressHUD dismiss];
            NSDictionary * result =  responseObject[@"result"];
            NSString * repID = [DataHelper getStringValue:result[@"replyid"] defaultValue:@""];
            
            int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
            if (localreplyid < [repID intValue]) {
                [USER_DEFAULT setInteger:[repID intValue] forKey:KeyChain_Laixin_Max_ReplyID];
                [USER_DEFAULT synchronize];
            }
            self.groupPost.replycount ++;
            Comment  *comment = [[Comment alloc] init];
            comment.replyid = repID;
            comment.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
            comment.postid = self.postid;
            comment.time = [[NSDate date] timeIntervalSinceNow];
            comment.timeText = @"刚刚";
            comment.content = content;
            [_datasource insertObject:comment atIndex:0];
            [self.tableview reloadData];
            self.textfield_content.text = @"";
            
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView showAlertViewWithMessage:@"回复失败 请重试!"];
    }];
}

-(IBAction)LoadMoreClick:(id)sender
{
    if (noMoreData) {
        return;
    }
    [self loadData:currentPage];
}

-(void) loadData:(int) page
{
    [button_load setTitle:@"加载中..." forState:UIControlStateNormal];
    NSDictionary * parames = @{@"postid":self.postid,@"pos":@(20*currentPage),@"count":@"20"};
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.get_reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //    postid = 12;
        /*
         Result={
         “posts”:[*/
        NSDictionary * groups = responseObject[@"result"];
        NSArray * postsDict =  groups[@"replys"];
        if (postsDict && postsDict.count > 0) {
            [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Comment * comment = [Comment turnObject:obj];
                [_datasource addObject:comment];
            }];
            [self.tableview reloadData];
            [view_load hideIndicatorViewBlueOrGary];
            currentPage ++;
            if (postsDict.count == 20) {
                [button_load setTitle:@"点击加载更多" forState:UIControlStateNormal];
            }else{
                noMoreData = YES;
                [button_load setTitle:@"加载完成" forState:UIControlStateNormal];
                [button_load setEnabled:NO];
            }
        }else{
            noMoreData = YES;
            [button_load setTitle:@"全部加载完成" forState:UIControlStateNormal];
            [button_load setEnabled:NO];
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        [button_load setTitle:@"请求失败,请点击重试" forState:UIControlStateNormal];
        [view_load hideIndicatorViewBlueOrGary];
    }];
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
    return _datasource.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == _datasource.count) {
        static NSString *CellIdentifier = @"loadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIButton * button = (UIButton *) [cell.contentView subviewWithTag:1];
        UIView * imageview = (UIView *) [cell.contentView subviewWithTag:2];
        button_load = button;
        view_load = imageview;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else
    {
        static NSString *CellIdentifier = @"myCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
        UILabel * labelName = (UILabel *) [cell.contentView subviewWithTag:2];
        UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
        UILabel * labelContent = (UILabel *) [cell.contentView subviewWithTag:4];
        labelContent.textColor = [UIColor grayColor];
        
        [((UILabel *) [cell.contentView subviewWithTag:6]) setHeight:0];
        
        //        cell.backgroundColor = [UIColor clearColor];
        
        //        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"itemsInfo_tabbar_bg"]];
        imageview.layer.cornerRadius = imageview.height/2;
        imageview.layer.masksToBounds = YES;
        
        Comment * comment = _datasource[indexPath.row];
        
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            if(response)
            {
                
                FCUserDescription * user = response;
                //内容
                if (user.headpic) {
                    [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]]  placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                }else{
                    [imageview setImage:[UIImage imageNamed:@"avatar_default"]];
                }
                labelName.text = user.nick;
            }
            
        } withuid:comment.uid];
        
        labelTime.text = comment.timeText;
        
        labelContent.text = comment.content;
        
        CGFloat height =  [self heightForCellWithPost:comment.content];
        [labelContent setHeight:height];
        [labelContent sizeToFit];
        [labelContent setWidth:240.0];
        [((UILabel *) [cell.contentView subviewWithTag:7]) setTop:(height + labelContent.top - 1)];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.button_keyboard setImage:[UIImage imageNamed:@"bar_down_keyboard_icon"] forState:UIControlStateNormal];
    [self.textfield_content resignFirstResponder];
    self.View_inputview.top = APP_SCREEN_HEIGHT - self.View_inputview.height;
    
    UITableViewCell * cell =  [tableView cellForRowAtIndexPath:indexPath];
    //    UIView * imageview = (UIView *) [cell.contentView subviewWithTag:2];
    if ([cell.reuseIdentifier isEqualToString:@"loadingCell"]) {
        [self LoadMoreClick:nil];
        //        [imageview showIndicatorViewBlue];
    }else{
        Comment * comment = _datasource[indexPath.row];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
            
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
            [self.navigationController pushViewController:addUser animated:YES];
            
        } withuid:comment.uid];
        
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_datasource.count == indexPath.row) {
        return 44.0f;
    }
    
    Comment * comment = _datasource[indexPath.row];
    CGFloat height =  [self heightForCellWithPost:comment.content];
    
    return height + 35 ;
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
    CGFloat maxWidth = 240.0f;//[UIScreen mainScreen].applicationFrame.size.width * 0.70f;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 20.0f );
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
