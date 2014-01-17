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


@interface XCJMessageReplyInfoViewController ()<ActivityTableViewCellDelegate>
{
    XCJGroupPost_list * currentGroup;
}
@property (nonatomic,strong) NSMutableArray *cellHeights;
@end

@implementation XCJMessageReplyInfoViewController

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

    if (self.message.jsonStr) {
        // fromat
        NSDictionary * obj =  self.message.jsonStr;
        if (obj) {
            XCJGroupPost_list * list = [XCJGroupPost_list turnObject:obj];
            currentGroup = list;
            [self.tableView reloadData];
        }
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
                        [self.tableView reloadData];
                    }
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [self showErrorText:@"数据请求失败"];
        }];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ActivityTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    XCJGroupPost_list* activity = currentGroup;
    
    
    if (activity.like == 0 && !cell.HasLoadlisks) {
        cell.HasLoadlisks = YES;
        
        NSDictionary * parames = @{@"postid":activity.postid,@"pos":@0,@"count":@"100"};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.likes" parameters:parames success:^(MLRequest *request, id responseObject) {
            NSDictionary * groups = responseObject[@"result"];
            NSArray * postsDict =  groups[@"users"];
            if (postsDict&& postsDict.count > 0) {
                NSMutableArray * mutaArray = [[NSMutableArray alloc] init];
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    postlikes * likes = [postlikes turnObject:obj];
                    [mutaArray addObject:likes];
                }];
                
                [activity.likeUsers addObjectsFromArray:mutaArray];
                //indexofActivitys
                [self reloadSingleActivityRowOfTableView:0  withAnimation:NO];
            }
            cell.HasLoadlisks = YES;
        } failure:^(MLRequest *request, NSError *error) {
            cell.HasLoadlisks =YES;
        }];
         
    }
    
    if (activity.comments.count <= 0 && !cell.HasLoad) {
        /* get all list data*/
        cell.HasLoad = YES;
        NSDictionary * parames = @{@"postid":activity.postid,@"pos":@0,@"count":@"20"};
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
                [activity.comments addObjectsFromArray:mutaArray];
                //indexofActivitys
                [self reloadSingleActivityRowOfTableView:0 withAnimation:NO];
            }
            cell.HasLoad = YES;
        } failure:^(MLRequest *request, NSError *error) {
            cell.HasLoad = NO;
        }];
    }
    //    cell.indexofActivitys =  [self.activities indexOfObject:activity];
    cell.activity = activity;
    // start requst comments  and likes
    
    return cell;
}

#pragma mark  comments

- (void)reloadSingleActivityRowOfTableView:(NSInteger)row withAnimation:(BOOL)animation
{
 
    [_cellHeights replaceObjectAtIndex:row withObject:@0];
    [self.tableView reloadData];
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

//点击评论按钮
- (void)clickCommentButton:(UIButton *)commentButton onActivity:(XCJGroupPost_list *)activity
{
    
}

- (void)clickLikeButton:(UIButton *)likeButton onActivity:(XCJGroupPost_list *)activity
{

}
//点击评论View中的某行(当前如果点击的是其中的某用户是会忽略的)
- (void)clickCommentsView:(UIView *)commentsView atIndex:(NSInteger)index atBottomY:(CGFloat)bottomY onActivity:(XCJGroupPost_list *)activity
{

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
