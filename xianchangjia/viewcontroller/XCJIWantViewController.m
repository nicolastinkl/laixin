//
//  XCJIWantViewController.m
//  laixin
//
//  Created by apple on 14-2-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJIWantViewController.h"
#import "XCAlbumAdditions.h"
#import "LKBadgeView.h"
#import "ConverReply.h"
#import "CoreData+MagicalRecord.h"
#import "XCJAppDelegate.h"
#import "FCUserDescription.h"
#import "XCJMessageReplylistController.h"
#import "UIAlertViewAddition.h"
#import "XCJFriendGroupViewController.h"
#import "XCJFindYouMMViewcontr.h"

@interface XCJIWantViewController ()

@end

@implementation XCJIWantViewController

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

     [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(MainappControllerUpdateDataReplyMessage:) name:@"MainappControllerUpdateDataReplyMessage" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
    [self MainappControllerUpdateDataReplyMessage:nil];
}

-(void) MainappControllerUpdateDataReplyMessage:(NSNotification * ) noty
{
    NSPredicate *predicatesss = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
    ConverReply * con = [ConverReply MR_findFirstWithPredicate:predicatesss];
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([con.badgeNumber intValue] > 0) {
        [delegate.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",[con.badgeNumber intValue]]];
    }else{
        if ([con.content isEqualToString:@"新朋友圈消息"]) {
            [delegate.tabBarController.tabBar.items[2] setBadgeValue:@"新"];
        }else{
            [delegate.tabBarController.tabBar.items[2] setBadgeValue:nil];
        }
    }
    [self.tableView reloadData];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellforiWant";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel * label_name = (UILabel *)[cell.contentView subviewWithTag:1];
    LKBadgeView  * badage = (LKBadgeView *)[cell.contentView subviewWithTag:2];
    UIImageView * imageSign = (UIImageView *)[cell.contentView subviewWithTag:3];
    UIImageView * image_New = (UIImageView *)[cell.contentView subviewWithTag:4];
    UIImageView * image_bgSign = (UIImageView *)[cell.contentView subviewWithTag:6];
    badage.widthMode = LKBadgeViewWidthModeSmall;
    badage.horizontalAlignment = LKBadgeViewHorizontalAlignmentLeft;
    badage.badgeColor = [UIColor redColor];
    badage.textColor = [UIColor whiteColor];
    
    image_bgSign.layer.cornerRadius = 15;
    image_bgSign.layer.masksToBounds = YES;
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
        {
            image_bgSign.image = [UIImage imageNamed:@"file_icon_history"];
            
           label_name.text = @"朋友圈";
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"postid > %@",@"0"];
            
            ConverReply * contr =   [ConverReply MR_findFirstWithPredicate:pre];
            if (contr) {
                if ([contr.badgeNumber intValue ] > 0 || [contr.content isEqualToString:@"新朋友圈消息"]) {
                    if([contr.badgeNumber intValue ] > 0)
                        badage.text = [NSString stringWithFormat:@"%@",contr.badgeNumber];
                    badage.hidden = NO;
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id resobj, NSError *error) {
                        FCUserDescription * localdespObject = resobj;
                        [imageSign setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:localdespObject.headpic Size:100]]];
                    } withuid:contr.uid];
                    imageSign.hidden = NO;
                    image_New.hidden = NO;
                    [image_New setFrame:CGRectMake(273, 2, 10, 10)];
                }else{
                     image_New.hidden = YES;
                     badage.hidden = YES;
                    imageSign.hidden = YES;
                }
            }else{
                badage.text = @"";
                badage.hidden = YES;
                image_New.hidden = YES;
                
                imageSign.hidden = YES;
            }
        }
            break;
        case 1:
        {
            image_bgSign.image = [UIImage imageNamed:@"file_icon_cloud"];
            label_name.text = @"抢你妹";
            badage.hidden = YES;
            image_New.hidden = YES;
            [image_New setFrame:CGRectMake(273, 17, 10, 10)];
        }
            break;
            
        case 2:
            image_bgSign.image = [UIImage imageNamed:@"found_icons_location"];
            label_name.text = @"附近活动";
            badage.hidden = YES;
            image_New.hidden = NO;
            [image_New setFrame:CGRectMake(273, 17, 10, 10)];
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"badgeNumber > %@",@"0"];
            ConverReply * contr =   [ConverReply MR_findFirstWithPredicate:pre];
            XCJFriendGroupViewController *viewcontr  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJFriendGroupViewController"];
            viewcontr.conversation = contr;
            [viewcontr hasNewPostInfo];
            [self.navigationController pushViewController:viewcontr animated:YES];
            
        }
           break;
        case 1:
        {
            XCJFindYouMMViewcontr*viewcontr  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJFindYouMMViewcontr"];
            viewcontr.title = @"抢你妹";
            [self.navigationController pushViewController:viewcontr animated:YES];
            //[UIAlertView showAlertViewWithMessage:@"内测功能,敬请期待"];
        }
            break;
        default:
            break;
    }
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
