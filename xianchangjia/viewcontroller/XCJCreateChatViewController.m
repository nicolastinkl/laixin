//
//  XCJCreateChatViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJCreateChatViewController.h"
#import "THContactPickerView.h"

@interface XCJCreateChatViewController ()<THContactPickerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@end

#define kKeyboardHeight 216.0

@implementation XCJCreateChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble{
    
}

-(void)contactBubbleWasSelected:(THContactBubble *)contactBubble
{

}

-(void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble
{

}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"选择要聊天的好友"];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height ) style:UITableViewStylePlain]; //- kKeyboardHeight
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = self.topLayoutGuide.length;
    }
    CGRect frame = self.contactPickerView.frame;
    frame.origin.y = topOffset;
    self.contactPickerView.frame = frame;
    [self adjustTableViewFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame {
    CGRect frame = self.tableView.frame;
    frame.origin.y = self.contactPickerView.frame.size.height;
    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height;// - kKeyboardHeight;
    self.tableView.frame = frame;
}


#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.contactPickerView.selectedContactBubble.textView resignFirstResponder];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *user = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user];
    }
    
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    int index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}



@end
