//
//  XCJSettingGroupViewController.m
//  laixin
//
//  Created by apple on 14-1-6.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJSettingGroupViewController.h"
#import "POHorizontalList.h"
#import "XCAlbumAdditions.h"
#import "LXUser.h"
#import "MLNetworkingManager.h"
#import "XCJAddUserTableViewController.h"
#import "LXAPIController.h"
#import "XCJChangeNickNaviController.h"
#import "XCJChangeSignNaviController.h"
#import "XCJErWeiCodeViewController.h"


@interface XCJSettingGroupViewController ()<POHorizontalListDelegate>
{
    NSMutableArray *freeList;
}
@end

@implementation XCJSettingGroupViewController

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
    NSMutableArray * ar  = [[NSMutableArray alloc] init];
    freeList = ar;
     ListItem *item = [[ListItem alloc] initWithFrame:CGRectZero imageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] nick:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick] uid:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]];
    [freeList addObject:item];
    if (self.uidArray) {
        NSDictionary * parames = @{@"uid":self.uidArray};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
           [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
               ListItem *item1 = [[ListItem alloc] initWithFrame:CGRectZero imageUrl:currentUser.headpic nick:currentUser.nick uid:currentUser.uid];
               [freeList addObject:item1];
           }];
            
            POHorizontalList *  list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 135.0) title:@"群成员" items:freeList];
            [list setDelegate:self];
            UIView * view =  [self.tableView.tableHeaderView subviewWithTag:11];
            [view addSubview:list];
            
           
        } failure:^(MLRequest *request, NSError *error) {
            
            POHorizontalList *  list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 135.0) title:@"群成员" items:freeList];
            [list setDelegate:self];
            UIView * view =  [self.tableView.tableHeaderView subviewWithTag:11];
            [view addSubview:list];
            
        }];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
   
    //conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    FCUserDescription * user = [[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:item.uid];
    if (user) {
        //FCUserDescription
        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
        addUser.UserInfo = user;
        [self.navigationController pushViewController:addUser animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            //群名称
            XCJChangeNickNaviController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChangeNickNaviController"];
            [self presentViewController:view animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            //群二维码
            
            XCJErWeiCodeViewController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJErWeiCodeViewController"];
            view.gid = self.gid;
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 2:
        {
            //群公告
            XCJChangeSignNaviController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChangeSignNaviController"];
            [self presentViewController:view animated:YES completion:^{
                
            }];
        }
            break;
            
        default:
            break;
    }
    
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
