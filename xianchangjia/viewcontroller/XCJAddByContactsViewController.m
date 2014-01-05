//
//  XCJAddByContactsViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAddByContactsViewController.h"
#import "UIAlertViewAddition.h"
#import "XCAlbumAdditions.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XCJAddressBook.h"
#import "MLNetworkingManager.h"
#import "DataHelper.h"

@interface XCJAddByContactsViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary * dictPhones;
    NSMutableArray * _datasource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableContacts;

@end

@implementation XCJAddByContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableContacts.dataSource = self;
    self.tableContacts.delegate = self;
    NSMutableArray * array  = [[NSMutableArray alloc] init];
    _datasource = array;
    NSMutableDictionary * dict  = [[NSMutableDictionary alloc] init];
    dictPhones = dict;
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
    return dictPhones.allValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellContacts";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel * titleName  =  (UILabel * ) [cell.contentView subviewWithTag:1];
    UILabel * contentSign  =  (UILabel * ) [cell.contentView subviewWithTag:2];
    UIImageView * contentSignimage  =  (UIImageView * ) [cell.contentView subviewWithTag:3];
    XCJAddressBook * addressbook =  dictPhones.allValues[indexPath.row];
    if (addressbook.HasRegister) {
        contentSign.text = @"添加";
        contentSignimage.hidden = NO;
        contentSign.textColor = [UIColor colorWithHex:0x444444];
    }else{
        contentSign.text = @"邀请";
        contentSign.textColor = [UIColor grayColor];
        contentSignimage.hidden = YES;
    }
    titleName.text = addressbook.name;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44.0f;
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
        [dictPhones setValue:addressBook forKey:addressBook.tel];
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
//    [_datasource  addObjectsFromArray:addarray];
    
    if (arrays.count > 0) {
        NSDictionary * parames = @{@"phone_list":arrays};
        [[MLNetworkingManager sharedManager] sendWithAction:@"phonebook.upload"  parameters:parames success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * dict = responseObject[@"data"];
                NSArray * array =  dict[@"users"];
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * phone=[DataHelper getStringValue:obj[@"phone"] defaultValue:@""];
                    if ([dictPhones.allKeys containsObject:phone]) {
                        SLog(@"phone %@",phone);
                        XCJAddressBook * addressbook =  [dictPhones.allKeys valueForKey:phone];
                        NSString * uid=[DataHelper getStringValue:obj[@"uid"] defaultValue:@""];
                        addressbook.UID = uid;
                        addressbook.HasRegister = YES;
//                        [dictPhones setObject:addressbook forKey:phone];
                    }
                }];
                
                [dictPhones.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    XCJAddressBook * addressbook1 = obj1;
                    XCJAddressBook * addressbook2 = obj2;
                    if (addressbook1.HasRegister > addressbook2.HasRegister) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedDescending;
                }];
            }
            [self.tableContacts reloadData];
        } failure:^(MLRequest *request, NSError *error) {
            [self.tableContacts reloadData];
        }];
        
    }


    
}

- (IBAction) findAllLocalContacts:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"启动手机通讯录匹配" message:@"看看手机通讯录里谁在使用来信? \n (不保存通讯录的任何资料,仅使用特征码作为匹配识别)" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIView *subView = (UIView * ) [self.view subviewWithTag:1];
        subView.hidden = YES;
        [self reloadContacts];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
