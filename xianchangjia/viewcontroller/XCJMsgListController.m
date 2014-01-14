//
//  XCJFriendViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//
#import "XCJMsgListController.h"
#import "XCAlbumAdditions.h"
#import "UserInfo.h"
#import "UIAlertView+AFNetworking.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "DAImageResizedImageView.h"
#import "XCJUserViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MLNetworkingManager.h"
#import "XCJAddressBook.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "FCAccount.h"
#import "FCUserDescription.h"
#import "CoreData+MagicalRecord.h"
#import "XCJUserInfoController.h"
#import "Conversation.h"
#import "FCMessage.h"
#import "LXRequestFacebookManager.h"
#import "ChatViewController.h"
#import "CoreData+MagicalRecord.h"
#import "XCJAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface XCJMsgListController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)showRecipe:(Conversation *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation XCJMsgListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController overrides

// because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
// we will see the NSManagedObjectContext set up before any persistent stores are registered
// we will need to fetch again after the persistent store is loaded
- (void)reloadFetchedResults:(NSNotification*)note {
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    if (note) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [self reloadFetchedResults:nil];
    // observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefetchAllDatabaseDataConver" object:[[UIApplication sharedApplication] delegate]];
    
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    if (numberOfRows <= 0) {
        // show info
        [self showErrorText:@"暂时还没有消息"];
    }else{
        [self hiddeErrorText];
    }
    
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        self.fetchedResultsController = [Conversation MR_fetchAllSortedBy:@"lastMessageDate" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    }
	return _fetchedResultsController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /* receive websocket message
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(webSocketDidReceivePushMessage:)
     name:MLNetworkingManagerDidReceivePushMessageNotification
     object:nil];
     */
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    NSDictionary * MsgContent  = notification.userInfo;
    SLog(@"MsgContent :%@",MsgContent);
    if ([MsgContent[@"push"] intValue] == 1) {
        NSString *requestKey = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        if ([requestKey isEqualToString:@"newmsg"]) {
            /*
             {"push": true, "data": {"message": {"toid": 14, "msgid": 5, "content": "\u6211\u6765\u4e86sss", "fromid": 2, "time": 1388477804.0}}, "type": "newmsg"}
             */
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"message"];
            
            NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
            
            //out view
            NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];

            // Build the predicate to find the person sought
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", facebookID];
            Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
            if(conversation == nil)
            {
                conversation =  [Conversation MR_createInContext:localContext];
            }
                
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            if ([content isNilOrEmpty]) {
                content = @"";
            }
            msg.text = content;
            NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            msg.sentDate = date;
            // message did come, this will be on left
            msg.messageStatus = @(YES);
            
            if (imageurl.length > 5)
            {
                msg.messageType = @(messageType_image);
                conversation.lastMessage = @"[图片]";
            }
            else
            {
                msg.messageType = @(messageType_text);
                conversation.lastMessage = content;
            }
            msg.imageUrl = imageurl;
            msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
            conversation.lastMessageDate = date;
            conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
            conversation.messageStutes = @(messageStutes_incoming);
            conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
            conversation.facebookName = @"";
            conversation.facebookId = facebookID;
            // increase badge number.
            int badgeNumber = [conversation.badgeNumber intValue];
            badgeNumber ++;
            conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
            
            [conversation addMessagesObject:msg];
            [localContext MR_saveOnlySelfAndWait];// MR_saveOnlySelfAndWait];
            
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
            
            SystemSoundID id = 1007; //声音
            AudioServicesPlaySystemSound(id);
            
        } else if([requestKey isEqualToString:@"newpost_error"]){
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"post"];
            NSString * gid = [tools getStringValue:dicMessage[@"group_id"] defaultValue:@""];
            NSString * uid = [tools getStringValue:dicMessage[@"uid"] defaultValue:@""];
            NSString * facebookID = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
            //out view
            NSString * content = dicMessage[@"content"];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
            
            // Build the predicate to find the person sought
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", facebookID];
            Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
            if(conversation == nil)
            {
                conversation =  [Conversation MR_createInContext:localContext];
            }
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = content;
            NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            msg.sentDate = date;
            if (imageurl.length > 5)
            {
                msg.messageType = @(messageType_image);
                conversation.lastMessage = @"[图片]";
            }
            else
            {
                msg.messageType = @(messageType_text);
                conversation.lastMessage = content;
            }
            // message did come, this will be on left
            msg.messageStatus = @(YES);
            msg.messageId = [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                FCUserDescription * localdespObject = response;
                conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
            } withuid:uid];
            conversation.lastMessageDate = date;
            conversation.messageStutes = @(messageStutes_incoming);
            // increase badge number.
            int badgeNumber = [conversation.badgeNumber intValue];
            badgeNumber ++;
            conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
            
            [conversation addMessagesObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
}


// clean up our new observers
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
   
    NSInteger numberOfRows = [[Conversation  MR_findAll] count];
    if (numberOfRows <= 0) {
        // show info
        [self showErrorText:@"暂时还没有消息"];
    }else{
        [self hiddeErrorText];
    }
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
    // update unread message badge number
    if ([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]) {
        NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"badgeNumber > %d",0];
        //        NSInteger  inter =  [Conversation MR_countOfEntitiesWithPredicate:preCMD];
        NSArray * array = [Conversation MR_findAllWithPredicate:preCMD];
        __block int badgeNumber = 0;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation * con = obj;
            badgeNumber += [con.badgeNumber intValue];
        }];
        SLog(@"badgeNumber %d   ",badgeNumber);
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        if (badgeNumber > 0) {
            [delegate.tabBarController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",badgeNumber]];
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
        }else{
            [delegate.tabBarController.tabBar.items[2] setBadgeValue:nil];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark - table fetchview
- (void)showRecipe:(Conversation *) friend animated:(BOOL)animated
{
    ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    // private or group
    switch ([friend.messageType intValue]) {
        case XCMessageActivity_UserGroupMessage:
        {
            chatview.title = @"群聊";
            NSString * gid =[friend.facebookId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",XCMessageActivity_User_GroupMessage] withString:@""];
            chatview.gid = gid;
        }
            break;
        case XCMessageActivity_UserPrivateMessage:
        {
            chatview.title = friend.facebookName;
        }
            break;
            
        default:
            break;
    }
    
    chatview.conversation = friend;
    //[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
    
    [self.navigationController pushViewController:chatview animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView * imageIcon = (UIImageView *)[cell.contentView viewWithTag:4];  //icon
    UIImageView * imageStuts = (UIImageView *)[cell.contentView viewWithTag:5];  //status
    UIImageView * imageFrame = (UIImageView *)[cell.contentView viewWithTag:6]; // frame
    switch ([conver.messageType intValue]) {
        case XCMessageActivity_UserPrivateMessage:
        {// 私信
            @try {
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                    FCUserDescription * localdespObject = response;
                    ((UILabel *)[cell.contentView viewWithTag:1]).text  = localdespObject.nick;  //nick
                    [imageIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[NSString stringWithFormat:@"%@",localdespObject.headpic] Size:100]]];
                } withuid:conver.facebookId];
            }
            @catch (NSException *exception) {
                SLog(@"icon %@",exception.userInfo);
            }
            @finally {
                
            }
            
        }
            break;
        case XCMessageActivity_UserGroupMessage:
        {
            [imageIcon setImage:[UIImage imageNamed:@"tabBarContactsIcon-iOS6"]];
            ((UILabel *)[cell.contentView viewWithTag:1]).text  = conver.facebookName;
        }
            break;
        default:
            // ok
            
            break;
    }
    
    
    ((UILabel *)[cell.contentView viewWithTag:2]).text  = conver.lastMessage;  // description
    ((UILabel *)[cell.contentView viewWithTag:3]).text  = [tools FormatStringForDate:conver.lastMessageDate];  //time
    
    switch ([conver.messageStutes intValue]) {
        case messageStutes_incoming:
            [imageStuts setImage:[UIImage imageNamed:@"inboxSeenIcon"]];
            break;
        case messageStutes_outcoming:
            [imageStuts setImage:[UIImage imageNamed:@"inboxRepliedIcon"]];
            break;
        case messageStutes_error:
            [imageStuts setImage:[UIImage imageNamed:@"inboxErrorIcon"]];
            break;
            
        default:
            break;
    }
    UITabBar *tabBar =(UITabBar*) [cell.contentView viewWithTag:12];
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if (![strClassName isEqualToString:@"_UIBadgeView"]) {
                [subview removeFromSuperview];
            }
        }
    }
    if ([conver.badgeNumber intValue] > 0) {
         [tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%@",conver.badgeNumber]];
        //[self showBadgeValue:[NSString stringWithFormat:@"%d",[conver.badgeNumber intValue]] inView:imageFrame];
    }else{
         [tabBar.items[0] setBadgeValue:nil];
        //[self removeBadgeValueInView:imageFrame];
    }
    ((UILabel *)[cell.contentView viewWithTag:11]).height = 0.5f;
    
}

#pragma mark  - bragenumber

- (UIView *)showBadgeValue:(NSString *)strBadgeValue inView:(UIView*)view
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    tabBar.items = @[item];
    //寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //从原视图上移除
                [subview removeFromSuperview];
                //添加到新视图右上角
                [view addSubview:subview];
                subview.frame = CGRectMake(view.frame.size.width-subview.frame.size.width/2-4, -4+4,
                                           subview.frame.size.width, subview.frame.size.height);
                return subview;
            }
        }
    }
    return nil;
}

- (void)removeBadgeValueInView:(UIView*)view
{
    for (UIView *subview in view.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
            [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            SLog(@"            [subview removeFromSuperview];");
            break;
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Conversation *recipe = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
    //    UserInfo_default * info = _dataSource[indexPath.row];
    //
    //    XCJUserViewController *viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserViewController"];
    //    viewcon.userinfo = info;
    //    viewcon.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:viewcon animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        id managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [managedObject MR_deleteEntity];
        [[managedObject managedObjectContext] MR_saveToPersistentStoreAndWait];
         //[[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageTabBarItemBadge" object:nil];
	}
}


@end
