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
#import "SJAvatarBrowser.h"
#import "XCJSelfPhotoViewController.h"
#import "FCMessage.h"

@interface XCJUserInfoController ()<UIActionSheetDelegate,UIAlertViewDelegate>
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
        if ([self.UserInfo.sex intValue] == 1) {
            self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([self.UserInfo.sex intValue] == 2) {
            self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
        }
        
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[tools getStringValue:self.UserInfo.headpic defaultValue:@""] Size:100]]];

    }else{
        self.UserInfo = self.frend.friendRelation;
        self.Label_nick.text  = self.frend.friendRelation.nick;
        self.Label_sign.text  = self.frend.friendRelation.signature;
        if ([self.frend.friendRelation.sex intValue] == 1) {
            self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([self.frend.friendRelation.sex intValue] == 2) {
            self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
        }
        
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[tools getStringValue:self.frend.friendRelation.headpic defaultValue:@""] Size:100]]];
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
//        UserDict[@"婚姻状态"] = self.UserInfo.marriage;
    }
    if (![[DataHelper getStringValue:self.UserInfo.position defaultValue:@""] isNilOrEmpty]) {
        UserDict[@"地区"] = self.UserInfo.position;
    }
    if (![self.UserInfo.signature isNilOrEmpty]) {
        UserDict[@"个性签名"] = self.UserInfo.signature;
    }
    
    if ([self.UserInfo.uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id ]]) {
        self.Button_Sendmsg.hidden = YES;
        self.Image_btnBG.hidden = YES;
    }else{
        self.Button_Sendmsg.hidden = NO;
        [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.Button_Sendmsg sendMessageStyle];
    }     
    [self.tableView reloadData];
    
    UIBarButtonItem * rightitem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(delmyfriendClick:)];
    self.navigationItem.rightBarButtonItem  = rightitem;
    
    NSString  * plistKeyName =[NSString stringWithFormat:@"user.posts_%@", self.UserInfo.uid];
    NSArray *arrayss = [[EGOCache globalCache] plistForKey:plistKeyName];
    if (arrayss && arrayss.count > 0) {
        NSMutableArray * arrObj = [NSMutableArray arrayWithArray:arrayss];
        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:[arrObj firstObject]];
        if (post) {
            UserDict[@"最新动态"] = post.content;
            [self.tableView reloadData];
        }
    }else{
        NSString * key =[NSString stringWithFormat:@"fetchRequestUserIDPOSY.%@",self.UserInfo.uid];
        NSArray * valueforKey = [[EGOCache globalCache] plistForKey:key];
        if ([valueforKey firstObject]) {
            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:[valueforKey firstObject]];
            UserDict[@"最新动态"] = post.content;
        }else{
            /*
             [[MLNetworkingManager sharedManager] sendWithAction:@"user.posts" parameters:@{@"uid":self.UserInfo.uid,@"count":@"1"} success:^(MLRequest *request, id responseObject) {
             if (responseObject) {
             NSDictionary * dicreult = responseObject[@"result"];
             NSArray * array = dicreult[@"posts"];
             [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             
             [[EGOCache globalCache] setPlist:@[obj] forKey:key withTimeoutInterval:60*3];
             
             XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
             UserDict[@"最新动态"] = post.content;
             }];
             [self.tableView reloadData];
             }
             } failure:^(MLRequest *request, NSError *error) {
             
             }];
             */
        }
        
        
    }
    
    NSString * key =[NSString stringWithFormat:@"fetchRequestUserID.%@",self.UserInfo.uid];
    NSString * valueforKey = [[EGOCache globalCache] stringForKey:key];
    if (valueforKey && valueforKey.length > 0) {
    }else{
        //check user neweast infomation
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesByNetCompletion:^(id response, NSError *error) {
            FCUserDescription* newFcObj = response;
            self.Label_nick.text  = newFcObj.nick;
            self.Label_sign.text  = newFcObj.signature;
            [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[tools getStringValue:newFcObj.headpic defaultValue:@""] Size:100]]];
            [[EGOCache globalCache] setString:@"1" forKey:key withTimeoutInterval:60*5];
            [self.tableView reloadData];
        } withuid:self.UserInfo.uid];
    }
}

-(IBAction)delmyfriendClick:(id)sender
{
    UIActionSheet * actionsh = [[UIActionSheet alloc] initWithTitle:@"删除好友将不会看到该好友动态信息" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除好友" otherButtonTitles:@"设置备注名", nil];
    [actionsh showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
         [SVProgressHUD showWithStatus:@"正在删除..."];
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.del_friend" parameters:@{@"uid":@[self.frend.friendID]} success:^(MLRequest *request, id responseObject) {
            [SVProgressHUD dismiss];
            NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
            [self.frend MR_deleteInContext:localContext];
            [localContext MR_saveOnlySelfAndWait];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"删除失败,请检查网络设置"];
        }];
    }else if(buttonIndex == 1)
    {
        UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入好友备注名:"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
        
        
        prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf = [prompt textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeDefault;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        prompt.tag = 1; // change name or nick
        [prompt show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if(buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        // NICK
        if (tf.text.length > 0) {
            NSString * strName = tf.text;
            self.UserInfo.nick = strName;
            self.Label_nick.text = strName;
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
            
        }
   }
}

- (IBAction)seeUsericonclick:(id)sender {
    if (self.Image_user.image) {
        
        if ([self.UserInfo.uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id ]]){
            [SJAvatarBrowser showImage:self.Image_user withURL:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]];
        }else{
            [SJAvatarBrowser showImage:self.Image_user withURL:self.UserInfo.headpic];
        }
    }    
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
        
        {
            //系统消息公告
            FCMessage * msg = [FCMessage MR_createInContext:localContext];
            msg.messageType = @(messageType_SystemAD);
            msg.text = [NSString stringWithFormat:@"您邀请%@开始私聊啦",self.UserInfo.nick];
            msg.sentDate = [NSDate date];
            msg.audioUrl = @"";
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            msg.messageId =  [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
            msg.messageguid = @"";
            msg.messageSendStatus = @0;
            msg.read = @YES;
            msg.facebookID = conversation.facebookId;
            conversation.lastMessage = msg.text;
            [conversation addMessagesObject:msg];
        }
        
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
