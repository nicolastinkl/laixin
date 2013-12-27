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

@interface XCJFriendViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * _dataSource;
}
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _dataSource = array;
    self.title = @"好友";
//    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    
    self.tableView.rowHeight = 70.0f;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //test  add friends
    /*
     {
     NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
     NSDictionary * parames = @{@"uid":@[userid]};
     [[MLNetworkingManager sharedManager] sendWithAction:@"user.add_friend" parameters:parames success:^(MLRequest *request, id responseObject) {
     
     } failure:^(MLRequest *request, NSError *error) {
     
     }];
     }
     */
    [self reload:nil];
//    [self reloadContacts];
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
                SLog(@"User denied access 1");
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
         SLog(@"User denied access 2");
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

-(void) _addContactToAddressBook:(ABAddressBookRef ) addressBooks
{
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
        [_dataSource addObject:addressBook];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
	
    NSMutableArray * arrays = [[NSMutableArray alloc] init];
    [_dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCJAddressBook * addressbook = obj;
        if (addressbook.tel.length == 11 && ![addressbook.tel hasPrefix:@"0"]) {
            [arrays addObject:addressbook.tel];  //并且删除本机号码
        }
    }];
//    SLog(@"json : %@",[arrays JSONString]);
}

- (void)reload:(id)sender
{
    [_dataSource removeAllObjects];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
    NSDictionary * parames = @{@"uid":userid,@"pos":@0,@"count":@100};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_list" parameters:parames success:^(MLRequest *request, id responseObject) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } failure:^(MLRequest *request, NSError *error) {
        
    }];
     
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"XCJFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
   /*DAImageResizedImageView* image = (DAImageResizedImageView *)[cell.contentView viewWithTag:1];
    UserInfo_default * info = _dataSource[indexPath.row];
    [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",info.user_avatar_image]]];
    ((UILabel *)[cell.contentView viewWithTag:2]).text = info.user_name;
   ((UILabel *)[cell.contentView viewWithTag:3]).text = info.user_profile;
    */
    XCJAddressBook *book = [_dataSource objectAtIndex:indexPath.row];
    ((UILabel *)[cell.contentView viewWithTag:2]).text  = book.name;
    ((UILabel *)[cell.contentView viewWithTag:3]).text  = book.tel;
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UserInfo_default * info = _dataSource[indexPath.row];
//    
//    XCJUserViewController *viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserViewController"];
//    viewcon.userinfo = info;
//    viewcon.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:viewcon animated:YES];
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
