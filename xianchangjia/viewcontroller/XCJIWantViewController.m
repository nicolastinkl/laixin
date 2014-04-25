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
#import "XCJNearbyInviteViewContr.h"
#import "XCJFindRoomViewControl.h"
#import "PPPinPadViewController.h"
#import "XCJDreamVoiceViewController.h"
#import "XCJWellDreamTableViewController.h"
#import "XCJWellDreamNewsTableViewController.h"
#import "XCJWellDreamUsersTableViewController.h"
#import "XLSwipeContainerController.h"
#import "XLSwipeNavigationController.h"
#import "SBSegmentedViewController.h"
@interface XCJIWantViewController ()<PinPadPasswordProtocol>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(openDreamGoodVoice) name:@"openDreamGoodVoice" object:nil];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
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
            
           label_name.text = @"群组动态";
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"postid > %@",@"0"];
            
            ConverReply * contr =   [ConverReply MR_findFirstWithPredicate:pre];
            if (contr) {
                if ([contr.badgeNumber intValue ] > 0 || [contr.content isEqualToString:@"新朋友圈消息"]) {
                    if([contr.badgeNumber intValue ] > 0)
                        badage.text = [NSString stringWithFormat:@"%@",contr.badgeNumber];
                    badage.hidden = NO;
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id resobj, NSError *error) {
                        if(resobj)
                        {
                            
                            FCUserDescription * localdespObject = resobj;
                            [imageSign setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:localdespObject.headpic Size:100]]];
                        }
                        
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
            label_name.text = @"来抢";
            badage.hidden = YES;
            image_New.hidden = YES;
            [image_New setFrame:CGRectMake(273, 17, 10, 10)];
        }
            break;
            
        case 2:
            //@"group_avatar_default_0"
            image_bgSign.image = [UIImage imageNamed:@"tb_icon_menu_weitao_normal"];
            label_name.text = @"来活动";
            badage.hidden = YES;
            image_New.hidden = YES;
            [image_New setFrame:CGRectMake(273, 17, 10, 10)];
         
            break;
        case 3:
            //@"group_avatar_default_0"
            image_bgSign.image = [UIImage imageNamed:@"opengroup_everjoin_icon"];
            label_name.text = @"来信&新声带";
            badage.hidden = YES;
            image_New.hidden = YES;
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
            [UIAlertView showAlertViewWithMessage:@"该功能需要向‘来信小助手’申请权限才能进入"];
            
//            NSURL *viewUserURL = [NSURL URLWithString:@"myapp://user/view/joeldev"];
//            [[UIApplication sharedApplication] openURL:viewUserURL];
            
            return;
            
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
            if ([LXAPIController sharedLXAPIController].currentUser.active_level>=3 || [LXAPIController sharedLXAPIController].currentUser.actor_level>=3) {
                PPPinPadViewController * pinViewController = [[PPPinPadViewController alloc] init];
                pinViewController.delegate = self;
                NSString * Pin = [[NSUserDefaults standardUserDefaults] stringForKey:PWdString];
                if (Pin && Pin.length > 0) {
                    pinViewController.inputModel = 1;                    
                }else{
                    pinViewController.inputModel = 2;
                }
                [self presentViewController:pinViewController animated:YES completion:NULL];
            }else{
                [UIAlertView showAlertViewWithMessage:@"抱歉,您不属于这个圈子,无法进入查看内容.\n\n 进入条件:只有被该圈内用户激活才能进入."];
            }
            
        }
            break;
        case 2:
        {
            XCJNearbyInviteViewContr*viewcontr  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJNearbyInviteViewContr"];
            viewcontr.title = @"来活动";
            [self.navigationController pushViewController:viewcontr animated:YES];
        }
            break;
        case 3:
        {
            if ( [USER_DEFAULT boolForKey:KeyChain_Laixin_dream_goodvoice]) {
                [self openDreamGoodVoice];
            }else{
                XCJDreamVoiceViewController*viewcontr  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJDreamVoiceViewController"];
                viewcontr.title = @"来梦想好声音";
                [self.navigationController pushViewController:viewcontr animated:YES];
            }
            
        }
            break;
        default:
            break;
    }
}

-(void) openDreamGoodVoice
{
    /*model
    XCJWellDreamTableViewController*child_1  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJWellDreamTableViewController"];
    
    XCJWellDreamNewsTableViewController*child_3  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJWellDreamNewsTableViewController"];
    
    XCJWellDreamUsersTableViewController*child_2  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJWellDreamUsersTableViewController"];
    
    XLSwipeNavigationController * contr =  [[XLSwipeNavigationController alloc] initWithViewControllers:child_1, child_2, child_3, nil];
    
    [self presentViewController:contr animated:YES completion:^{
        
    }];*/
    /*push*/
    SBSegmentedViewController *segmentedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSegmentedViewController"];
	segmentedViewController.position = SBSegmentedViewControllerControlPositionNavigationBar;
	[segmentedViewController addStoryboardSegments:@[@"segmentOne", @"segmentTwo",@"segmentThree"]];
    [self.navigationController pushViewController:segmentedViewController animated:YES];
}

- (BOOL)checkPin:(NSString *)pin {
    
    NSString * newmd5Str = [pin md5Hash];
    
    NSString * PinOld = [[NSUserDefaults standardUserDefaults] stringForKey:PWdString];
    
    return [newmd5Str isEqualToString:PinOld];
}

- (NSInteger)pinLenght {
    return 4;
}


- (void)CorrectRight
{
    
    XCJFindRoomViewControl*viewcontr  = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJFindRoomViewControl"];
    viewcontr.title = @"来抢";
    [self.navigationController pushViewController:viewcontr animated:YES];
    
}

- (void)CorrectError
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
