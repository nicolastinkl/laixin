//
//  XCJInviteCommentViewController.m
//  laixin
//
//  Created by apple on 3/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJInviteCommentViewController.h"
#import "XCAlbumAdditions.h"
#import "Comment.h"
#import "FCUserDescription.h"
#import "XCJCommentView.h"
#import "UIView+Animation.h"
#import "UIView+Indicator.h"
#import "UIView+Additon.h"

@interface XCJInviteCommentViewController ()<XCJCommentViewDelegate>
{
    NSMutableArray *  _datasource;
    int currentPage;
    UIButton * button_load;
    UIView * view_load;
    Boolean noMoreData;
    XCJCommentView * CommentView;
}
@end

@implementation XCJInviteCommentViewController

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

    
    self.title = @"用户评论";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    noMoreData = NO;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    _datasource =array;
    currentPage = 0;
    [self loadData:currentPage];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表评论" style:UIBarButtonItemStyleDone target:self action:@selector(AddCommentClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGFloat newY = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height ;
     if (CommentView) {
         [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          animations:^{
//                              CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                               [CommentView setTop:APP_SCREEN_HEIGHT - CommentView.height-newY];
                          }
                          completion:^(BOOL finished) {
                             
                          }];
        
     }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (CommentView) {
        NSDictionary *userInfo = [notification userInfo];
        [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             //                              CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                             
                             [CommentView setTop:APP_SCREEN_HEIGHT + CommentView.height];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

-(IBAction)AddCommentClick:(id)sender
{
    if (CommentView == nil) {
        CommentView = [[[NSBundle mainBundle] loadNibNamed:@"XCJCommentView" owner:self options:nil] firstObject];
        CommentView.delegate = self;
    }
    
    [self.navigationController.view addSubview:CommentView];
//    [CommentView showAnimatingLayer];
    [CommentView.textview becomeFirstResponder];
    
}


-(void) closeView
{
    [CommentView.textview resignFirstResponder];
//    [CommentView endAnimatingLayer];
    [CommentView removeFromSuperview];

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
            Comment  *comment = [[Comment alloc] init];
            comment.replyid = repID;
            comment.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
            comment.postid = self.postid;
            comment.time = [[NSDate date] timeIntervalSinceNow];
            comment.timeText = @"刚刚";
            comment.content = content;
            [_datasource insertObject:comment atIndex:0];
            [self.tableView reloadData];
            [self closeView];
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
            [self.tableView reloadData];
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
            [button_load setTitle:@"加载完成" forState:UIControlStateNormal];
            [button_load setEnabled:NO];
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        [button_load setTitle:@"请求失败,请点击重试" forState:UIControlStateNormal];
        [view_load hideIndicatorViewBlueOrGary];
    }];
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
            FCUserDescription * user = response;
            //内容
            if (user.headpic) {
                [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]]  placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            }else{
                [imageview setImage:[UIImage imageNamed:@"avatar_default"]];
            }
            labelName.text = user.nick;
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
    UITableViewCell * cell =  [tableView cellForRowAtIndexPath:indexPath];
//    UIView * imageview = (UIView *) [cell.contentView subviewWithTag:2];
    if ([cell.reuseIdentifier isEqualToString:@"loadingCell"]) {
        [self LoadMoreClick:nil];
//        [imageview showIndicatorViewBlue];
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
