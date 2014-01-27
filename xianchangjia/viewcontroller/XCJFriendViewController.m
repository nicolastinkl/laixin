//
//  XCJFriendViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJFriendViewController.h"
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
#import "FCFriends.h"
#import "CoreData+MagicalRecord.h"
#import "XCJUserInfoController.h"
#import "XCJAddFriendNaviController.h"
#import "FCBeAddFriend.h"
#import "FCBeInviteGroup.h"

@interface XCJFriendViewController ()<NSFetchedResultsControllerDelegate>
{
    NSMutableArray * _dataSource;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)showRecipe:(FCFriends *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation XCJFriendViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - fetchedResultsController
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
		SLLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _dataSource = array;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    {
        
        //    self.title = @"好友";
        //    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
        //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadContacts)];
        //test  add friends
        //     {
        //     NSDictionary * parames = @{@"uid":@[@12,@11,@14]};
        //     [[MLNetworkingManager sharedManager] sendWithAction:@"user.add_friend" parameters:parames success:^(MLRequest *request, id responseObject) {
        //
        //     } failure:^(MLRequest *request, NSError *error) {
        //         
        //     }];
        //    }
        
        
    }
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [self reloadFetchedResults:nil];
    // observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];
    
    ((UILabel * )[self.tableView.tableHeaderView subviewWithTag:1]).height = 0.3;
    ((UILabel * )[self.tableView.tableHeaderView subviewWithTag:2]).height = 0.3;
    
    ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:11]).hidden = YES;
    ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:12]).hidden = YES;
    
//    [self reload:nil];
//    [self reloadContacts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(add_friend_Notify:) name:@"add_friend_Notify" object:[[UIApplication sharedApplication] delegate]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(group_invite_Notify:) name:@"group_invite_Notify" object:[[UIApplication sharedApplication] delegate]];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self add_friend_Notify:nil];
    [self group_invite_Notify:nil];
    
}
- (void) add_friend_Notify:(NSNotification * ) notiy
{
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"hasAdd == %@",@NO];
    NSUInteger cont = [FCBeAddFriend MR_countOfEntitiesWithPredicate:pre];
    if (cont > 0) {
        ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:11]).hidden = NO;
    }else{
        ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:11]).hidden = YES;
    }
}

- (void) group_invite_Notify:(NSNotification * ) notiy
{
    if ([USER_DEFAULT boolForKey:KeyChain_Laixin_message_GroupBeinvite]) {
         ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:12]).hidden = NO;
    }else{
         ((UIImageView * )[self.tableView.tableHeaderView subviewWithTag:12]).hidden = YES;
    }
    
//    NSPredicate * pre = [NSPredicate predicateWithFormat:@"groupID > %@",@"1"];
//    NSUInteger cont = [FCBeInviteGroup MR_countOfEntitiesWithPredicate:pre];
    
}

-(IBAction) AddFriendClick:(id)sender
{
    XCJAddFriendNaviController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddFriendNaviController"];
    [self presentViewController:navi animated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"friendID != %@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]];
        self.fetchedResultsController = [FCFriends MR_fetchAllSortedBy:@"friendRelation.nick_frist_pinyin" ascending:YES withPredicate:pre groupBy:@"friendRelation.nick_frist_pinyin" delegate:self] ;
        //:
    }
	return _fetchedResultsController;
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

-(void) reloadContacts
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //获取通讯录权限
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                [self _addContactToAddressBook:addressBookRef];
            } else {
                SLLog(@"User denied access 1");
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self _addContactToAddressBook:addressBookRef];
    }
    else {
         SLLog(@"User denied access 2");
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
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
	UITableView *tableView = self.tableView;
	
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


-(void) _addContactToAddressBook:(ABAddressBookRef ) addressBooks
{
    NSMutableArray * addarray = [[NSMutableArray alloc] init];
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);

    //通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    //循环，获取每个人的个人信息
    for (NSInteger i = 0; i < nPeople; i++)
    {
        //新建一个addressBook model类
        XCJAddressBook *addressBook = [[XCJAddressBook alloc] init];
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        addressBook.name = nameString;
        addressBook.recordID = (int)ABRecordGetRecordID(person);;
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            //获取电话号码和email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        addressBook.tel = (__bridge NSString*)value;
                        addressBook.tel = [addressBook.tel stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                        addressBook.tel = [addressBook.tel stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        addressBook.tel = [addressBook.tel stringByReplacingOccurrencesOfString:@" " withString:@""];
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = (__bridge NSString*)value;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
        [addarray addObject:addressBook];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
	
    NSMutableArray * arrays = [[NSMutableArray alloc] init];
    [addarray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCJAddressBook * addressbook = obj;
        if (addressbook.tel.length == 11 && ![addressbook.tel hasPrefix:@"0"]) {
//            [arrays addObject:addressbook.tel];  //并且删除本机号码
            if (addressbook.name) {
                [arrays addObject:@{@"phone":addressbook.tel,@"name":addressbook.name}];
            }else{
                [arrays addObject:@{@"phone":addressbook.tel,@"name":@"未知"}];
            }
        }
    }];
    if (arrays.count > 0) {
        NSDictionary * parames = @{@"phone_list":arrays};
        [[MLNetworkingManager sharedManager] sendWithAction:@"phonebook.upload"  parameters:parames success:^(MLRequest *request, id responseObject) {
        } failure:^(MLRequest *request, NSError *error) {
        }];

    }
    
    SLLog(@"json : %@",[arrays JSONString]);
    
}

- (void)reload:(id)sender
{
    [_dataSource removeAllObjects];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //_dataSource
    [_dataSource addObjectsFromArray:[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchAllFCFriends]];
    [self.tableView reloadData];
     
//    NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
//    [postdata setObject:[NSNumber numberWithInt:0] forKey:@"length"];  //加载所有数据
//    [postdata setObject:[NSNumber numberWithInt:0] forKey:@"offset"];
//    NSURLSessionDataTask * task = [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"user_relation" Action:@"get_scene_plus_friends" success:^(id obj) {
//        //get_scene_plus_friends
//        NSArray * array = [obj objectForKey:@"list"];
//        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            UserInfo_default * userinfo = [[UserInfo_default alloc] initWithJSONObject:obj];
//            [_dataSource addObject:userinfo];
//        }];
//        
//        [self.tableView reloadData];
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//        
//    } error:^(NSInteger index) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    } failure:^(NSError *error) {
//    }];
// 
//    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
//    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)self.navigationItem.leftBarButtonItem.customView;
//    [activityIndicatorView setAnimatingWithStateOfTask:task];
  
}

#pragma mark - table fetchview

- (void)showRecipe:(FCFriends *) friend animated:(BOOL)animated
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    infoview.frend = friend;
    infoview.title = @"详细资料";
    [self.navigationController pushViewController:infoview animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   
    DAImageResizedImageView* image = (DAImageResizedImageView *)[cell.contentView viewWithTag:1];
    FCFriends *userdesp = (FCFriends *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    ((UILabel *)[cell.contentView viewWithTag:2]).text  =userdesp.friendRelation.nick;// [NSString stringWithFormat:@"id:%@ name:%@", userdesp.friendRelation.uid, ];
    //    ((UILabel *)[cell.contentView viewWithTag:3]).text  = userdesp.friendRelation.signature;
    [image setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:userdesp.friendRelation.headpic Size:100]]];
    
    ((UILabel *)[cell.contentView viewWithTag:6]).height = 0.5f;
    
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
      return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    FCFriends *userdesp = (FCFriends *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        FCFriends *userdesp = [[sectionInfo objects] firstObject];
        
        return  [self.fetchedResultsController sectionIndexTitleForSectionName:userdesp.friendRelation.nick_pinyin];
    }
    return @"";
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
    static NSString *CellIdentifier = @"XCJFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FCFriends *recipe = (FCFriends *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
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


@end
