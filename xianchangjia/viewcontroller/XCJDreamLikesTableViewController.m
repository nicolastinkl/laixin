//
//  XCJDreamLikesTableViewController.m
//  laixin
//
//  Created by apple on 4/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDreamLikesTableViewController.h"
#import "XCAlbumAdditions.h"
#import "Comment.h"
#import "XCJAddUserTableViewController.h"
#import "UIButton+WebCache.h"
#import "SBSegmentedViewController.h"

@interface XCJDreamLikesTableViewController ()
{
    NSMutableArray *  _datasource;
}
@end

@implementation XCJDreamLikesTableViewController

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
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _datasource = array;
    
    SBSegmentedViewController *segmentedViewController =  (SBSegmentedViewController *)self.navigationController.visibleViewController;
    id someobj = segmentedViewController.someobject;
    self.groupPost = someobj;
    if (self.groupPost.like > 0) {
        // request net working
        [self.tableView showIndicatorViewLargeBlue];
        NSDictionary * parames = @{@"postid":self.groupPost.postid,@"pos":@0,@"count":@"100"};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.likes" parameters:parames success:^(MLRequest *request, id responseObject) {
            NSDictionary * groups = responseObject[@"result"];
            NSArray * postsDict =  groups[@"users"];
            if (postsDict&& postsDict.count > 0) {
                
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    postlikes * likes = [postlikes turnObject:obj];
                    [_datasource addObject:likes];
                }];
                [self.tableView reloadData];
            }
            [self.tableView hideIndicatorViewBlueOrGary];
        } failure:^(MLRequest *request, NSError *error) {
            [self showErrorText:@"网络请求失败"];
            [self.tableView hideIndicatorViewBlueOrGary];
        }];
    }else{
        [self showErrorText:@"还没有人赞"];
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
    return _datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell" forIndexPath:indexPath];
    UIButton * imagebutton = (UIButton *) [cell.contentView subviewWithTag:1];
    imagebutton.layer.cornerRadius = imagebutton.height/2;
    imagebutton.layer.masksToBounds = YES;
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    postlikes * comment = _datasource[indexPath.row];
    UIButton * _avatarButton = (UIButton *) [cell.contentView subviewWithTag:1];
    UILabel * label_name = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * label_sign = (UILabel *) [cell.contentView subviewWithTag:3];
    
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        FCUserDescription * user  = response;
        if (user) {
            label_sign.text =  user.signature;
            
            if (user.headpic) {
                [_avatarButton setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            }else{
                [_avatarButton setImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
            }
            [label_name setText:user.nick];
            [label_name setTextColor:[tools colorWithIndex:[user.actor_level intValue]]];
        }
        
    } withuid:comment.uid];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    postlikes * comment = _datasource[indexPath.row];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        
        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
        addUser.UserInfo = response;
        [self.navigationController pushViewController:addUser animated:YES];
        
    } withuid:comment.uid];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
