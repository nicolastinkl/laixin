//
//  XCJGroupUsersTableViewController.m
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJGroupUsersTableViewController.h"
#import "XCAlbumAdditions.h"
#import "LXUser.h"
#import "XCJAddUserTableViewController.h"


@interface XCJGroupUsersTableViewController ()
{
    NSMutableArray * _datasource;
}
@end

@implementation XCJGroupUsersTableViewController

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
    self.title = @"群组成员";
   
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition object:nil];
    
    [self reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



-(void) showErrorInfoWithRetryNot:(NSNotification * ) notify
{
    [self hiddeErrorInfoWithRetry];
    // start retry
    [self.tableView showIndicatorViewLargeBlue];
    [self reloadData];
}

-(void)reloadData
{
    [self.tableView showIndicatorViewLargeBlue];
    
    {
        // request  data from net working
        //        group.members(gid) 群成员列表
        //        Result= {"members":[{"type":0,"uid":4,"time":1388661405}]}
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.members" parameters:@{@"gid":self.gid} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * dict =  responseObject[@"result"];
                NSArray * arr =  dict[@"members"];
                if (arr.count > 0) {
                    NSMutableArray * userArray = [[NSMutableArray alloc] init];
                    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [userArray addObject:[DataHelper getStringValue:obj[@"uid"] defaultValue:@""]];
                    }];
                    
                    self.title = [NSString stringWithFormat:@"群组成员(%d)",userArray.count];
                    
                    NSDictionary * parameIDS = @{@"uid":userArray};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parameIDS success:^(MLRequest *request, id responseObject) {
                        // "users":[....]
                        NSDictionary * userinfo = responseObject[@"result"];
                        NSArray * userArray = userinfo[@"users"];
                        [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            LXUser * luser = [[LXUser alloc] initWithDict:obj];
                            [_datasource addObject:luser];
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFriendsObject:luser];
                        }];
 
                        [self.tableView hideIndicatorViewBlueOrGary];
                        [self.tableView reloadData];
                    } failure:^(MLRequest *request, NSError *error) {
                        [self.tableView hideIndicatorViewBlueOrGary];
                        [self showErrorInfoWithRetry];
                    }];
                }else{
                    //没有用户
                    [self.tableView hideIndicatorViewBlueOrGary];
                    [self showErrorText:@"没有找到群组成员"];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            [self.tableView hideIndicatorViewBlueOrGary];
            [self showErrorInfoWithRetry];
        }];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LXUser * user =  _datasource[indexPath.row];
    UIImageView * image =  (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelNick =  (UILabel *) [cell.contentView subviewWithTag:2];
    // Configure the cell...
    [image setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:160]]];
    labelNick.text = user.nick;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXUser * currentUser =  _datasource[indexPath.row];
    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
        if (response) {
            //FCUserDescription
            [SVProgressHUD dismiss];
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
            addUser.UserInfoJson = currentUser;
            [self.navigationController pushViewController:addUser animated:YES];
        }
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
