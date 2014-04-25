//
//  XCJSelectLaixinViewController.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSelectLaixinViewController.h"
#import "XCAlbumAdditions.h"
#import "CoreData+MagicalRecord.h"
#import "FCFriends.h"
#import "FCUserDescription.h"
@interface XCJSelectLaixinViewController ()
{
    NSMutableArray * datasource;
}
@end

@implementation XCJSelectLaixinViewController

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

    NSPredicate * pre = [NSPredicate predicateWithFormat:@"friendID != %@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]];
    NSArray * array =  [FCFriends MR_findAllWithPredicate:pre];
    datasource = [NSMutableArray arrayWithArray:array];
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
    return datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"laixincell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   FCFriends  *friend = datasource[indexPath.row];
    // Configure the cell...
    UIImageView * image_icon  = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * label_nale  = (UILabel *) [cell.contentView subviewWithTag:2];
    label_nale.textColor = [tools colorWithIndex:0];
    [image_icon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:friend.friendRelation.headpic Size:100]]];
    label_nale.text = friend.friendRelation.nick;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
       FCFriends  *friend = datasource[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLaixinMMID" object:friend.friendID];
    [self.navigationController popViewControllerAnimated:YES];
    
    
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
