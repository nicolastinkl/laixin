//
//  XCJMessageReplylistController.m
//  laixin
//
//  Created by apple on 14-1-11.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJMessageReplylistController.h"
#import "CoreData+MagicalRecord.h"
#import "XCAlbumAdditions.h"
#import "FCUserDescription.h"
#import "ConverReply.h"
#import "FCReplyMessage.h"
#import "XCJGroupPost_list.h"
#import "XCJMessageReplyInfoViewController.h"

@interface XCJMessageReplylistController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext     *managedObjectContext;
- (void)showRecipe:(FCReplyMessage *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation XCJMessageReplylistController
@synthesize fetchedResultsController = _fetchedResultsController;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    if ([self.conversation.badgeNumber intValue] > 0) {
//        self.conversation.badgeNumber = @(0);
//        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
//    }
//}


-(IBAction) clearAllMessageReply:(id)sender
{
    UIActionSheet  *sheet = [[UIActionSheet alloc] initWithTitle:@"将清空本地数据" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空所有数据" otherButtonTitles: nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSPredicate  * pre = [NSPredicate predicateWithFormat:@"postid > %@",@"0"];
        BOOL bol = [FCReplyMessage MR_deleteAllMatchingPredicate:pre];
        if (bol) {
            // OK
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
        }
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
        [self showErrorText:@"暂时还没有人评论或赞我"];
    }else{
        [self hiddeErrorText];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    {
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"badgeNumber > %@",@"0"];
        
        ConverReply * contr =   [ConverReply MR_findFirstWithPredicate:pre];
        if (contr) {
            contr.badgeNumber = @0;
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"MainappControllerUpdateDataReplyMessage" object:nil];
            
        }
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
        self.fetchedResultsController = [FCReplyMessage MR_fetchAllSortedBy:@"time" ascending:NO withPredicate:nil groupBy:nil delegate:self]; //@"gbadgeNumber"
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
		SLLog(@"Unresolved error %@, %@", error, [error userInfo]);
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark - table fetchview

- (void)showRecipe:(FCReplyMessage *) info animated:(BOOL)animated
{
    XCJMessageReplyInfoViewController * msgReplyInfoViewCr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMessageReplyInfoViewController"];
    msgReplyInfoViewCr.message = info;
    [self.navigationController pushViewController:msgReplyInfoViewCr animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FCReplyMessage *info = (FCReplyMessage *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *labelnick = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *labelContent = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *labelTime = (UILabel *)[cell.contentView viewWithTag:4];
    UIImageView *imgViewbuttonBG = (UIImageView *)[cell.contentView viewWithTag:5];
    UIImageView * imageviewTag = (UIImageView *)[cell.contentView viewWithTag:6];
     UILabel * labelText = (UILabel *)[cell.contentView viewWithTag:7];
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
        FCUserDescription * user = response;
        //内容
        if (user.headpic) {
            [imgView setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:160]]   placeholderImage:[UIImage imageNamed:@"avatar_fault"]];
        }else{
            [imgView setImage:[UIImage imageNamed:@"avatar_fault"]];
        }
        labelnick.text = user.nick;
        labelnick.textColor = [tools colorWithIndex:[user.actor_level intValue]];
    } withuid:info.uid];
    labelTime.text = [tools timeLabelTextOfTime:[info.time doubleValue]];
    
    if ([info.typeReply isEqualToString:@"newlike"]) {
         imageviewTag.hidden = NO;
         labelContent.text = @"";
        labelTime.top  = 50;
    }else if ([info.typeReply isEqualToString:@"newreply"])
    {
        labelContent.text = info.content;
        [labelContent sizeToFit];
        CGFloat height = [self heightForCellWithPost:info.content];
        [labelContent setHeight:height];
        imageviewTag.hidden = YES;
        labelTime.top = labelContent.top + labelContent.height + 2;
    }
    
    if (info.jsonStr) {
        // fromat 
        NSDictionary * obj =  info.jsonStr;//[ objectFromJSONData];
        if (obj) {
            XCJGroupPost_list * list = [XCJGroupPost_list turnObject:obj];
            if (list.imageURL.length > 5) {
                [imgViewbuttonBG setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:list.imageURL Size:240]]];
                labelText.text = @"";
            }else{
                labelText.text = list.content;
                [imgViewbuttonBG setImage:nil];
                //[labelText sizeToFit];
            }
        }
    }else{
        //post.get(postid) 参数可以是数组
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.get" parameters:@{@"postid": info.postid} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
               NSDictionary * dict = responseObject[@"result"];
               NSArray *array = dict[@"posts"];
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (idx == 0) {
                        info.jsonStr =  obj;
                        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                        XCJGroupPost_list * list = [XCJGroupPost_list turnObject:obj];
                        if (list.imageURL.length > 5) {
                            [imgViewbuttonBG setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:list.imageURL Size:240]]];
                        }else{
                            labelText.text = list.content;
                            //[labelText sizeToFit];
                        }
                    }
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
            
        }];
    }
    
}

-(IBAction)addFriendClick:(id)sender
{
    
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
    
    FCReplyMessage *info = (FCReplyMessage *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([info.typeReply isEqualToString:@"newlike"]) {
        return 75.0f;
    }else if ([info.typeReply isEqualToString:@"newreply"])
    {
        //info.content
        CGFloat height = [self heightForCellWithPost:info.content];
        return height + 58;
    }
    return 75.0f;
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(180.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"messagecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FCReplyMessage *recipe = (FCReplyMessage *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
}

// clean up our new observers
- (void)viewDidUnload {
    self.fetchedResultsController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
