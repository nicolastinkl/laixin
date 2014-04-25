//
//  XCJCreateChatViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJCreateChatViewController.h"
#import "THContactPickerView.h"
#import "FCFriends.h"
#import "XCAlbumAdditions.h"
#import "XCAlbumDefines.h"
#import "CoreData+MagicalRecord.h"
#import "FCUserDescription.h"
#import "MLNetworkingManager.h"
#import "DataHelper.h"
#import "UIAlertViewAddition.h"
#import "ChatViewController.h"
#import "Conversation.h"

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
    if (self.Currentgid) {
        [self.contactPickerView setPlaceholderString:@"选择要加入的好友"];
    }else{
        [self.contactPickerView setPlaceholderString:@"选择要聊天的好友"];
    }

    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height+44, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height ) style:UITableViewStylePlain]; //- kKeyboardHeight
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    self.tableView.top = self.contactPickerView.height + 44;
    
    self.contacts = [FCFriends MR_findAll];
    self.selectedContacts = [NSMutableArray array];
    self.filteredContacts = self.contacts;
    
}
/*
 
 -(void)viewDidAppear:(BOOL)animated
 {
 [super viewDidAppear:animated];
 if (IS_4_INCH) {
 self.tableView.height = self.view.height - self.contactPickerView.height - 44;
 }else{
 self.tableView.height = 300;
 }
 }
 */

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
//    CGRect frame = self.tableView.frame;
//    frame.origin.y = self.contactPickerView.frame.size.height;
//    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height;// - kKeyboardHeight;
//    self.tableView.frame = frame;
    
    self.tableView.top = 44 + self.contactPickerView.height;
}


#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    FCFriends * userdesp = [self.filteredContacts objectAtIndex:indexPath.row];
    
    ((UILabel *)[cell.contentView viewWithTag:2]).text  =userdesp.friendRelation.nick;// [NSString stringWithFormat:@"id:%@ name:%@", userdesp.friendRelation.uid, ];
    //    ((UILabel *)[cell.contentView viewWithTag:3]).text  = userdesp.friendRelation.signature;
    DAImageResizedImageView* image = (DAImageResizedImageView *)[cell.contentView viewWithTag:1];
    [image setImageWithURL:[NSURL URLWithString:userdesp.friendRelation.headpic]];
    
    ((UILabel *)[cell.contentView viewWithTag:6]).height = 0.5f;
    
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
    
    FCFriends *user = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user.friendRelation.nick];
    }
    if (self.selectedContacts.count > 0) {
        if (self.Currentgid) {
            self.title = [NSString stringWithFormat:@"加入群组(%d)",self.selectedContacts.count];
        }else{
            self.title = [NSString stringWithFormat:@"发起聊天(%d)",self.selectedContacts.count];
            
        }
    }else{
        
        if (self.Currentgid) {
            self.title =@"加入群组";
        }else{
             self.title = @"发起聊天";
            
        }
    }

    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}

-(IBAction) cancelClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(IBAction) complateClick:(id)sender
{
    if(self.Currentgid)
    {
        //加入群组
        if (self.selectedContacts.count > 0) {
            NSMutableArray * arrayUIDs = [[NSMutableArray alloc] init];
            [self.selectedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                FCFriends *userss = obj;
                [arrayUIDs addObject:userss.friendID];
            }];
            
            [SVProgressHUD show];
            double delayInSeconds = .5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [[MLNetworkingManager sharedManager] sendWithAction:@"group.invite" parameters:@{@"gid":self.Currentgid,@"uid":arrayUIDs} success:^(MLRequest *request, id responseObject) {
                    [SVProgressHUD dismiss];
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
                } failure:^(MLRequest *request, NSError *error) {
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"邀请失败"];
                }];
                
            });
            
        }else{
            [UIAlertView showAlertViewWithMessage:@"请选择要加入的成员"];
        }
    }else{
        
        if(self.selectedContacts.count > 1){
            // 群聊必须至少2人
            
            NSMutableArray * arrayUIDs = [[NSMutableArray alloc] init];
            __block NSString * strNames;
            [self.selectedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                FCFriends *userss = obj;
                [arrayUIDs addObject:userss.friendID];
                if (!strNames) {
                    strNames = userss.friendRelation.nick;
                }else{
                    strNames = [NSString stringWithFormat:@"%@,%@",strNames,userss.friendRelation.nick];
                }
            }];
            
            [SVProgressHUD showWithStatus:@"正在创建..."];
            NSDictionary * parames = @{@"name":strNames,@"board":@"",@"type":@"2"};
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.create"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //Result={“gid”:1}
                if (responseObject) {
                    NSDictionary * dict =  responseObject[@"result"];
                    NSString * gid =  [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
                    if ([gid intValue] <= 0) {
                        [SVProgressHUD dismiss];
                        [UIAlertView showAlertViewWithMessage:@"创建失败"];
                        return ;
                    }
                    //group.regupdate(gid) 注册群的消息更新
                    //group.invite (gid,uid)
                    {
                        //                  注册群的消息更新
                        [[MLNetworkingManager sharedManager] sendWithAction:@"group.regupdate" parameters:@{@"gid":gid} success:^(MLRequest *request, id responseObject) {
                            
                        } failure:^(MLRequest *request, NSError *error) {
                        }];
                    }
                    
                    {
                        [arrayUIDs addObject:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]];
                        [[MLNetworkingManager sharedManager] sendWithAction:@"group.invite" parameters:@{@"gid":gid,@"uid":arrayUIDs} success:^(MLRequest *request, id responseObject) {
                            
                            // target to chat view
                            NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
                            NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid]];
                            NSArray * array =  [Conversation MR_findAllWithPredicate:pre inContext:localContext];
                            ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                            if (array.count > 0) {
                                chatview.conversation = array[0];
                            }else{
                                // create new
                                Conversation * conversation =  [Conversation MR_createInContext:localContext];
                                conversation.lastMessage = [NSString stringWithFormat:@"你邀请%@加入了群聊",strNames];
                                conversation.lastMessageDate = [NSDate date];
                                conversation.messageType = @(XCMessageActivity_UserGroupMessage);
                                conversation.messageStutes = @(messageStutes_incoming);
                                conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,@"0"];
                                conversation.facebookName = strNames;
                                conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
                                conversation.badgeNumber = @0;
                                [localContext MR_saveOnlySelfAndWait];
                                chatview.conversation = conversation;
                            }
                            [SVProgressHUD dismiss];
                            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                // create new talk;
                                //                            [self.navigationController pushViewController:chatview animated:YES];
                                //                            UITabBarController * tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
                                //                            tabBarController.selectedIndex = 2;
                                //                            [tabBarController.selectedViewController.navigationController pushViewController:chatview animated:NO];
                            }];
                        } failure:^(MLRequest *request, NSError *error) {
                            
                            [SVProgressHUD dismiss];
                        }];
                    }
                }
            } failure:^(MLRequest *request, NSError *error) {
                [SVProgressHUD dismiss];
                //[UIAlertView showAlertViewWithMessage:@"创建失败"];
            }];
        }else{
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"群聊必须至少2人"];
        }
    }
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
