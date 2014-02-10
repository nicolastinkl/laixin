//
//  XCJUserInfoController.m
//  laixin
//
//  Created by apple on 13-12-31.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJUserInfoController.h"
#import "XCAlbumAdditions.h"
#import "FCFriends.h"
#import "FCUserDescription.h"
#import "Conversation.h"
#import "CoreData+MagicalRecord.h"
#import "ChatViewController.h"
#import "XCAlbumDefines.h"
#import "DataHelper.h"
#import "UIButton+Bootstrap.h"
#import "XCJGroupPost_list.h"
#import "XCJSelfPhotoViewController.h"

@interface XCJUserInfoController ()
{
        NSMutableDictionary * UserDict;
}
@property (weak, nonatomic) IBOutlet UIImageView *Image_user;
@property (weak, nonatomic) IBOutlet UIImageView *Image_sex;
@property (weak, nonatomic) IBOutlet UIButton *Button_Sendmsg;
@property (weak, nonatomic) IBOutlet UIImageView *Image_btnBG;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UILabel *Label_sign;
@property (weak, nonatomic) IBOutlet UILabel *Label_address;

@end

@implementation XCJUserInfoController

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
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    UserDict = array;
    
    if (self.UserInfo) {
        self.Label_nick.text  = self.UserInfo.nick;
        self.Label_sign.text  = self.UserInfo.signature;
        self.Label_address.text = @"成都";
        if ([self.UserInfo.sex intValue] == 1) {
            self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([self.UserInfo.sex intValue] == 2) {
            self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
        }
        
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getStringValue:self.UserInfo.headpic defaultValue:@""]]];

    }else{
        self.UserInfo = self.frend.friendRelation;
        self.Label_nick.text  = self.frend.friendRelation.nick;
        self.Label_sign.text  = self.frend.friendRelation.signature;
        self.Label_address.text = @"成都";
        if ([self.frend.friendRelation.sex intValue] == 1) {
            self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([self.frend.friendRelation.sex intValue] == 2) {
            self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
        }
        
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getStringValue:self.frend.friendRelation.headpic defaultValue:@""]]];
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
    if (![[DataHelper getStringValue:self.UserInfo.position defaultValue:@""] isNilOrEmpty]) {
        UserDict[@"地区"] = self.UserInfo.position;
    }
    if (![self.UserInfo.signature isNilOrEmpty]) {
        UserDict[@"个性签名"] = self.UserInfo.signature;
    }
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.posts" parameters:@{@"uid":self.UserInfo.uid,@"count":@"1"} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * dicreult = responseObject[@"result"];
            NSArray * array = dicreult[@"posts"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                 UserDict[@"最新动态"] = post.content;
            }];
            [self.tableView reloadData];
        }
    } failure:^(MLRequest *request, NSError *error) {
        
    }];
    
   
    
    if ([self.UserInfo.uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id ]]) {
        self.Button_Sendmsg.hidden = YES;
        self.Image_btnBG.hidden = YES;
    }else{
        self.Button_Sendmsg.hidden = NO;
        [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.Button_Sendmsg sendMessageStyle];
    }
    
    
    
    [self.tableView reloadData];
}

-(IBAction)touchBtnUp:(id)sender
{
    
    // target to chat view
    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",self.UserInfo.uid];
    Conversation * array =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
    ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    if (array) {
        chatview.conversation = array;
    }else{
        // create new
        Conversation * conversation =  [Conversation MR_createInContext:localContext];
        conversation.lastMessage = @"";
        conversation.lastMessageDate = [NSDate date];
        conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
        conversation.messageStutes = @(messageStutes_incoming);
        conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
        conversation.facebookName = self.UserInfo.nick;
        conversation.facebookId = self.UserInfo.uid;
        conversation.badgeNumber = @0;
        [localContext MR_saveOnlySelfAndWait];
         chatview.conversation = conversation;
     }
     chatview.userinfo = self.UserInfo;
     chatview.title = self.UserInfo.nick;
     [self.navigationController pushViewController:chatview animated:YES];
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
    NSString * text  = UserDict.allValues[indexPath.row];
    content.text = text;
    if ([title.text isEqualToString:@"最新动态"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [content setHeight:[self sizebyText:text]]; // set label content frame with tinkl
//    [content sizeToFit];
//    [content setWidth:186.0f];
    
    return cell;
}

-(CGFloat) sizebyText:(NSString * ) text
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [ text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(186.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return fmaxf(35.0f, sizeToFit.height + 18.0f );
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * title = UserDict.allKeys[indexPath.row];
    if ([title isEqualToString:@"最新动态"]) {
        // enter to user des
        XCJSelfPhotoViewController * selfviewcontr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPhotoViewController"];
        selfviewcontr.userID = self.UserInfo.uid;
        selfviewcontr.title = self.UserInfo.nick;
        [self.navigationController pushViewController:selfviewcontr animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text  = UserDict.allValues[indexPath.row];
    return  [self sizebyText:text] + 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
