//
//  XCJSearchUsersViewController.m
//  laixin
//
//  Created by apple on 2/20/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSearchUsersViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJAddUserTableViewController.h"
@interface XCJSearchUsersViewController ()

@end

@implementation XCJSearchUsersViewController

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
    return self.arrayUsers.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LXUser * user = [[LXUser alloc ] initWithDict:self.arrayUsers[indexPath.row]];
    // Configure the cell...
    
    UIImageView * image = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelNick = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelLocation = (UILabel *) [cell.contentView subviewWithTag:3];
    UIImageView * Image_sex = (UIImageView *) [cell.contentView subviewWithTag:4];
    UIImageView * Image_friend = (UIImageView *) [cell.contentView subviewWithTag:5];
    if (user.sex == 1) {
        Image_sex.image = [UIImage imageNamed:@"md_boy"];
    }else if (user.sex == 2) {
        Image_sex.image = [UIImage imageNamed:@"md_girl"];
    }
    if ([[[LXAPIController sharedLXAPIController ] chatDataStoreManager] isMyFriends:user.uid]) {
        Image_friend.hidden = NO;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        Image_friend.hidden = YES;
    }
    ((UILabel *) [cell.contentView subviewWithTag:21]).height = 0.5;
    [image setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:160]]];
    labelNick.text = user.nick;
    if (labelNick.text.length <= 0) {
        labelNick.text = @"未命名";
    }
    labelNick.textColor = [tools colorWithIndex:user.actor_level];
    if (user.signature.length < 1) {
        labelLocation.text = @"Ta正在构建一个伟大签名";
    }else{
        labelLocation.text = user.signature;
    }
    
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXUser * currentUser = [[LXUser alloc ] initWithDict:self.arrayUsers[indexPath.row]];
    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
        if (response) {
            //FCUserDescription
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
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
