//
//  XCJMessageCenterViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJMessageCenterViewController.h"
#import "DAHttpClient.h"
#import "InviteInfo.h"
#import "UserInfo.h"
#import "XCAlbumDefines.h"
#import "XCModelAllEntity.h"
#import "MessageManager.h"
#import "JSONKit.h"
#import "NSString+Addition.h"

@interface XCJMessageCenterViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation XCJMessageCenterViewController

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
    [self initfeedback];
}


-(void) initfeedback
{
	NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
	[[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"message" Action:@"check_unread_message" success:^(id obj) {
		SLog(@"%@",obj);
		NSDictionary * new_friend_status_array = [obj objectForKey:@"new_friend_status"]; //朋友动态
		if (new_friend_status_array && new_friend_status_array.count > 0) {
			[[new_friend_status_array allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				int userID = [obj intValue];
				NSArray * userValues = new_friend_status_array[obj];
				if (userValues && userValues.count > 0) {
					Friend_New_statuss_all * friendsAll = [[Friend_New_statuss_all alloc] init];
					friendsAll.user_id = userID;
					friendsAll.user_unReadNumber = userValues.count;
					friendsAll.user_update_time = [tools fixStringForDate:[NSDate date]];
					friendsAll.user_hasread = 0;
					
					NSMutableString * mutaStrPhotoIDs = [[NSMutableString alloc] init];
					[userValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						int photoID = [[obj valueForKeyPath:@"id"] intValue];  //photo id
						if (photoID > 0) {
							// photoID will be added to PhotoArray...
							if (idx > 0) {
								[mutaStrPhotoIDs appendFormat:@"-%d",photoID];
							}else{
								[mutaStrPhotoIDs appendFormat:@"%d",photoID];
							}
						}
					}];
					friendsAll.user_photo_ids = mutaStrPhotoIDs;
					[[MessageManager sharedMessageManager] UpdateXCFriendsUnread_status:friendsAll];
				}
			}];
			
		}
		
        
		NSArray * new_received_comment_array = [obj objectForKey:@"new_received_comment"]; //新评论
		if (new_received_comment_array && new_received_comment_array.count > 0) {
			[new_received_comment_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary * comDic = [obj objectForKey:@"comment"];
				if (comDic) {
					commentpostInfo *comInfo = [[commentpostInfo alloc] initWithJSONObject:obj];
					Message_activity * activity = [[Message_activity alloc] init];
					activity.zmessagetypeid = XCMessageActivity_photocomment;
					activity.zmessagetype = XCMessageActivity_photocomment_str;
					activity.zuser_json = [[comDic valueForKeyPath:@"user"] JSONString];
					activity.zdate = comInfo.comment_time;
					activity.zpayload_json = [obj JSONString];
					activity.zphotourl = comInfo.comment_image_url;
					//single
					activity.zPKID =  [NSString stringWithActivityMessageType:XCMessageActivity_photocomment ZPKID:XCMessageActivity_photocomment_str];
					
					if (comInfo.userinfo.user_avatar_image) {
						activity.zuserurl = comInfo.userinfo.user_avatar_image;
					}
					if (comInfo.comment_audio_length >= 1) {
						activity.ztitle = comInfo.userinfo.user_name;
						activity.zContent = @"新语音评论";
					}else{
						activity.ztitle  = comInfo.userinfo.user_name;
						activity.zContent = comInfo.comment_content;
					}
					[[MessageManager sharedMessageManager] handleXCMessage_Activity:activity];
					activity.zPKID =  [NSString stringWithActivityMessageType:XCMessageActivity_photocomment ZPKID:[NSString stringWithFormat:@"%lld",comInfo.to_post_id]];  // muti more
					[[MessageManager sharedMessageManager] handleXCMessage_ActivityWithPhotoCommit:activity];
				}
			}];
			//[BWStatusBarOverlay showWithMessage:[NSString stringWithFormat:@"未读评论(%d)",new_received_comment_array.count] loading:YES animated:NO];
		}
		
		NSArray * new_fans_array = [obj objectForKey:@"new_fans"];//新被添加好友
		if (new_fans_array && new_fans_array.count > 0) {
			[new_fans_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary * userDic = [obj valueForKeyPath:@"user"];
				{
					notify_new_fans * newfans = [[notify_new_fans alloc] init];
					newfans.user_json = [userDic JSONString];
					newfans.user_new_time = [obj valueForKeyPath:@"add_time"];
					newfans.user_id = [[userDic valueForKeyPath:@"id"] intValue];
					newfans.user_hasBeingAdd = 0;
					[[MessageManager sharedMessageManager] insertXC_newFans:newfans];
				}
				
				Message_activity * activity = [[Message_activity alloc] init];
				activity.zmessagetypeid = XCMessageActivity_beingAddingFriends;
				activity.zmessagetype = XCMessageActivity_beingAddingFriends_str;
				activity.zuser_json = [userDic JSONString];
				activity.zdate = [obj valueForKeyPath:@"add_time"];
				UserInfo_default * userinfo = [[UserInfo_default alloc] initWithJSONObject:userDic];
				if (userinfo.user_avatar_image) {
					activity.zuserurl = userinfo.user_avatar_image;
				}
				activity.zmessageHasread = 0;
				activity.zPKID = [NSString stringWithActivityMessageType:XCMessageActivity_beingAddingFriends ZPKID:XCMessageActivity_beingAddingFriends_str];
				activity.privateMsgchildid = userinfo.user_id;
				activity.ztitle  = [NSString stringWithFormat:@"%@",userinfo.user_name];
				[[MessageManager sharedMessageManager] handleXCMessage_Activity:activity];
			}];
		}
		
		{
			NSArray * newChats = [obj objectForKey:@"chat"];// 私信
			if (newChats && newChats.count > 0) {
				[newChats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					Message_activity * privateActivity = [[Message_activity alloc] initWithJsonDictionary_privateMsg:obj];
					privateActivity.zmessagetypeid = XCMessageActivity_UserPrivateMessage;
					privateActivity.zmessagetype = XCMessageActivity_User_privateMessage;
					privateActivity.zother_json = [obj JSONString];
					privateActivity.zPKID = [NSString stringWithActivityMessageType:XCMessageActivity_UserPrivateMessage ZPKID:[NSString stringWithFormat:@"%d",privateActivity.privateMsgchildid]];
					[[MessageManager sharedMessageManager] handleXCMessage_Activity:privateActivity];
					
				}];
				//[tools playVibrate];
				//[BWStatusBarOverlay showWithMessage:[NSString stringWithFormat:@"未读私信(%d)",newChats.count] loading:YES animated:NO];
			}
		}
		{
			NSArray * newChats = [obj objectForKey:@"merchant"]; //新商家消息
			if (newChats && newChats.count > 0) {
				[newChats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					NSDictionary * pagloadDic  = [obj objectForKey:@"payload"];
					if (pagloadDic) {
						int sceneSuperUserid = [[obj valueForKeyPath:@"id"] intValue];
						Message_activity * privateActivity = [[Message_activity alloc] init];
						privateActivity.zPKID = [NSString stringWithActivityMessageType:XCMessageActivity_SceneBusniessMessage ZPKID:[NSString stringWithFormat:@"%d",sceneSuperUserid]];
						privateActivity.zmessagetypeid = XCMessageActivity_SceneBusniessMessage;
						privateActivity.zmessagetype = XCMessageActivity_str_SceneBusniessMessage;
						privateActivity.privateMsg_screent_name = [pagloadDic valueForKeyPath:@"name"];
						privateActivity.privateMsgchildid = sceneSuperUserid;
						privateActivity.privateMsgLastMessageText = [obj valueForKeyPath:@"msg"];
						privateActivity.privateMsgSendUrl = [pagloadDic valueForKeyPath:@"image"];
						privateActivity.zdate = [tools StringForDate:[NSDate date]];
						[[MessageManager sharedMessageManager] handleXCMessage_Activity:privateActivity];
					}
					
				}];
				//[tools playVibrate];
				//[tools playAlertSound];
				//[BWStatusBarOverlay showWithMessage:@"新商家消息" loading:YES animated:NO];
			}
		}
		{
			NSArray * newChats = [obj objectForKey:@"assistant"];  //新小主播消息
			if (newChats && newChats.count > 0) {
				NSDictionary * pagloadDic  = [obj objectForKey:@"payload"];
				if (pagloadDic) {
					int sceneSuperUserid = [[obj valueForKeyPath:@"id"] intValue];
					Message_activity * privateActivity = [[Message_activity alloc] init];
					privateActivity.zPKID = [NSString stringWithActivityMessageType:XCMessageActivity_SceneSmallanchor ZPKID:[NSString stringWithFormat:@"%d",sceneSuperUserid]];
					privateActivity.zmessagetypeid = XCMessageActivity_SceneSmallanchor;
					privateActivity.zmessagetype = XCMessageActivity_str_SceneSmallanchorMessage;
					privateActivity.privateMsg_screent_name = [pagloadDic valueForKeyPath:@"name"];
					privateActivity.privateMsgchildid = sceneSuperUserid;
					privateActivity.privateMsgLastMessageText = [obj valueForKeyPath:@"msg"];
					privateActivity.privateMsgSendUrl = [pagloadDic valueForKeyPath:@"image"];
					privateActivity.zdate = [tools StringForDate:[NSDate date]];
					[[MessageManager sharedMessageManager] handleXCMessage_Activity:privateActivity];
				}
				//[tools playVibrate];
				//[tools playAlertSound];
				//[BWStatusBarOverlay showWithMessage:@"新小主播消息" loading:YES animated:NO];
			}
		}
		
	} error:^(NSInteger index) {
	} failure:^(NSError *error) {
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
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
