//
//  XCJAddFriendTableController.m
//  laixin
//
//  Created by apple on 14-1-4.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAddFriendTableController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "LXUser.h"
#import "LXChatDBStoreManager.h"
#import "LXRequestFacebookManager.h"
#import "LXAPIController.h"
#import "FCUserDescription.h"
#import "XCJAddUserTableViewController.h"
#import "UIAlertViewAddition.h"

@interface XCJAddFriendTableController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickNameText;

@end

@implementation XCJAddFriendTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
//XCJAddUserTableViewController
- (IBAction)cancel_click:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//XCJAddUserTableViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nickNameText) {
        if (![self.nickNameText.text isNilOrEmpty]) {
            
            [self.nickNameText resignFirstResponder];
            
            NSDictionary * paramess = @{@"uid":@[self.nickNameText.text]};
            [[MLNetworkingManager sharedManager] sendWithAction:@"user.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                NSDictionary * groupsss = responseObjects[@"result"];
                NSArray * array = groupsss[@"users"];
                if(array.count  <= 0)
                {
                    [UIAlertView showAlertViewWithTitle:@"该用户不存在" message:@"无法找到该用户,请检查您填写的昵称是否正常"];
                    return ;
                }
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
                        if (response) {
                            //FCUserDescription
                            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
                            addUser.UserInfo = response;
                            addUser.UserInfoJson = currentUser;
                            [self.navigationController pushViewController:addUser animated:YES];
                        }
                    }];
                    
                }];
                
            } failure:^(MLRequest *request, NSError *error) {
            }];
        }
        else{
            return NO;
        }
    }
    return  YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
