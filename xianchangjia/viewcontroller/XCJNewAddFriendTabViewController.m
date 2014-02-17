//
//  XCJNewAddFriendTabViewController.m
//  laixin
//
//  Created by apple on 14-1-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJNewAddFriendTabViewController.h"
#import "FCBeAddFriend.h"
#import "CoreData+MagicalRecord.h"
#import "XCAlbumAdditions.h"
#import "FCUserDescription.h"
#import "XCJAddUserTableViewController.h"

@interface XCJNewAddFriendTabViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;
- (void)showRecipe:(FCBeAddFriend *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation XCJNewAddFriendTabViewController
@synthesize fetchedResultsController = _fetchedResultsController;
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [self HomeReloadFetchedResults:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HomeReloadFetchedResults:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];
    
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    if (numberOfRows <= 0) {
        // show info
        [self showErrorText:@"暂时还没有人添加你为好友"];
    }else{
        [self hiddeErrorText];
    }
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        /*
         http://stackoverflow.com/questions/14690681/nsfetchedresultschangeupdate-fired-instead-of-nsfetchedresultschangedelete#new-answer
         
         If I update this property to [NSNumber numberWithBool:YES] the NSFetchedResultsControllerDelegate calls didChangeObject but firing NSFetchedResultsChangeUpdate instead of NSFetchedResultsChangeDelete.
         
         MARK:     [NSPredicate predicateWithFormat:@" gType = 1"];  get error
         
         */
        self.fetchedResultsController = [FCBeAddFriend MR_fetchAllSortedBy:@"addTime" ascending:NO withPredicate:nil groupBy:nil delegate:self]; //@"gbadgeNumber"
    }
	return _fetchedResultsController;
}

#pragma mark - fetchedResultsController
#pragma mark UIViewController overrides

// because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
// we will see the NSManagedObjectContext set up before any persistent stores are registered
// we will need to fetch again after the persistent store is loaded
- (void)HomeReloadFetchedResults:(NSNotification*)note {
    
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

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
#pragma mark  NSFetchedResultsController to respond to additions, removals and so on.
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    // select all unread bradge number
    
//    NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"gbadgeNumber > %d",0];
//    NSInteger  inter =  [FCHomeGroupMsg MR_countOfEntitiesWithPredicate:preCMD];
//    
//    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
//    if (inter > 0) {
//        [delegate.tabBarController.tabBar.items[0] setBadgeValue:@"新"];
//    }else{
//        [delegate.tabBarController.tabBar.items[0] setBadgeValue:nil];
//    }
    
    
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case NSFetchedResultsChangeUpdate:
        {
            
			[self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            
        }
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
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

- (void)showRecipe:(FCBeAddFriend *) info animated:(BOOL)animated
{
    XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
    addUser.UserInfo = info.beAddFriendShips;
    [self.navigationController pushViewController:addUser animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FCBeAddFriend *info = (FCBeAddFriend *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *labelnick = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *labelLiyou = (UILabel *)[cell.contentView viewWithTag:3];
    UIImageView *imgViewbuttonBG = (UIImageView *)[cell.contentView viewWithTag:4];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:5];
    UILabel *labelSign = (UILabel *)[cell.contentView viewWithTag:6];
    
    {
        [imgView setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:info.beAddFriendShips.headpic Size:160]] placeholderImage:[UIImage imageNamed:@"mqz_album_private"]];
        labelnick.text = info.beAddFriendShips.nick;
        labelLiyou.text = [tools FormatStringForDate:info.addTime];// info.beAddFriendShips.signature;
    }
    
    if ([info.hasAdd boolValue]) {
        button.hidden = YES;
        imgViewbuttonBG.hidden = YES;
        labelSign.text = @"已添加";
    }else{
        if ([[[LXAPIController sharedLXAPIController] chatDataStoreManager] isMyFriends:info.beAddFriendShips.uid]) {
            //is my friend
            button.hidden = YES;
            imgViewbuttonBG.hidden = YES;
            labelSign.text = @"已添加";
            info.hasAdd = @(YES);
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
        }else{
            button.hidden = NO;
            imgViewbuttonBG.hidden = NO;
            labelSign.text = @"";
            [button addTarget:self action:@selector(addFriendClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

-(IBAction)addFriendClick:(id)sender
{
    UIButton * button = (UIButton*)sender;
    UIView * superView = button.superview.superview.superview;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:(UITableViewCell *)superView];
    FCBeAddFriend *userinfo = (FCBeAddFriend *)[self.fetchedResultsController objectAtIndexPath:indexPath];    
    if (userinfo) {
        [SVProgressHUD showWithStatus:@"正在添加"];
        NSDictionary * parames = @{@"uid":@[userinfo.beAddFriendShips.uid]};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.add_friend" parameters:parames success:^(MLRequest *request, id responseObject) {
            // add this user to friends DB
            // setFriendsObject
            if (responseObject) {
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFriendsUserDescription:userinfo.beAddFriendShips];
                userinfo.hasAdd = @YES;
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                // reload this cell
                [self configureCell:(UITableViewCell *)superView atIndexPath:indexPath];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"添加失败"];
        }];
    }else{
      [SVProgressHUD showErrorWithStatus:@"添加失败"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FCBeAddFriend *recipe = (FCBeAddFriend *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
}

// clean up our new observers
- (void)viewDidUnload {
    self.fetchedResultsController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
