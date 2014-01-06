//
//  XCJAddUserTableViewController.m
//  laixin
//
//  Created by apple on 14-1-4.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAddUserTableViewController.h"
#import "tools.h"
#import "XCAlbumAdditions.h"
#import "UIView+Additon.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"

@interface XCJAddUserTableViewController ()
{
    NSMutableDictionary * UserDict;
}

@property (weak, nonatomic) IBOutlet UIImageView *Image_user;
@property (weak, nonatomic) IBOutlet UIImageView *Image_sex;
@property (weak, nonatomic) IBOutlet UIButton *Button_Sendmsg;
@property (weak, nonatomic) IBOutlet UIImageView *Image_btnBG;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@end

@implementation XCJAddUserTableViewController

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
    self.title = @"详细资料";
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    UserDict = array;
    if (self.UserInfo) {
        self.Label_nick.text  = self.UserInfo.nick;
        if ([self.UserInfo.sex intValue] == 1) {
            self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([self.UserInfo.sex intValue] == 2) {
            self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
        }
        
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getStringValue:self.UserInfo.headpic defaultValue:@""]]];
        
        /*
         @property (nonatomic, retain) NSNumber * create_time;
         @property (nonatomic, retain) NSString * headpic;
         @property (nonatomic, retain) NSNumber * height;
         @property (nonatomic, retain) NSString * marriage;
         @property (nonatomic, retain) NSString * nick;
         @property (nonatomic, retain) NSNumber * sex;
         @property (nonatomic, retain) NSString * signature;*/
        
        if (![self.UserInfo.signature isNilOrEmpty]) {
            UserDict[@"个性签名"] = self.UserInfo.signature;
        }
        if (self.UserInfo.create_time) {
            @try {
                UserDict[@"注册时间"] = [tools timeLabelTextOfTime:[self.UserInfo.create_time doubleValue]];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        
        if (![self.UserInfo.marriage isNilOrEmpty]) {
            UserDict[@"婚姻状态"] = self.UserInfo.marriage;
        }
        if (![self.UserInfoJson.position isNilOrEmpty]) {
            UserDict[@"地区"] = self.UserInfoJson.position;
        }
        
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnDown:) forControlEvents:UIControlEventTouchDown];
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUpOut:) forControlEvents:UIControlEventTouchUpOutside];
}

-(IBAction)touchBtnUpOut:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_normal"]];
}

-(IBAction)touchBtnDown:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_highlighted"]];
}

-(IBAction)touchBtnUp:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_normal"]];
    {
        NSDictionary * parames = @{@"uid":@[self.UserInfo.uid]};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.add_friend" parameters:parames success:^(MLRequest *request, id responseObject) {
            // add this user to friends DB
            // setFriendsObject
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:self.UserInfoJson withCompletion:^(id response, NSError *error) {
                
            }];
        } failure:^(MLRequest *request, NSError *error) {
            
        }];
    }

    
    
    // target to chat view
//    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
//    NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",self.UserInfo.uid];
//    NSArray * array =  [Conversation MR_findAllWithPredicate:pre inContext:localContext];
//    ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
//    if (array.count > 0) {
//        chatview.conversation = array[0];
//    }else{
//        // create new
//        Conversation * conversation =  [Conversation MR_createInContext:localContext];
//        conversation.lastMessage = @"";
//        conversation.lastMessageDate = [NSDate date];
//        conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
//        conversation.messageStutes = @(messageStutes_incoming);
//        conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
//        conversation.facebookName = self.UserInfo.nick;
//        conversation.facebookId = self.UserInfo.uid;
//        conversation.badgeNumber = @0;
//        [localContext MR_saveOnlySelfAndWait];
//        chatview.conversation = conversation;
//    }
//    chatview.userinfo = self.UserInfo;
//    [self.navigationController pushViewController:chatview animated:YES];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return UserDict.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellFriend";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel * title  =  (UILabel * ) [cell.contentView subviewWithTag:1];
    UILabel * content  =  (UILabel * ) [cell.contentView subviewWithTag:2];
    title.text =  UserDict.allKeys[indexPath.row];
    content.text =  UserDict.allValues[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  44.0f;
}

@end
