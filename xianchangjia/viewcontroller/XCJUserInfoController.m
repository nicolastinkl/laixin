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

@interface XCJUserInfoController ()
@property (weak, nonatomic) IBOutlet UIImageView *Image_user;
@property (weak, nonatomic) IBOutlet UIImageView *Image_sex;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UIButton *Button_Sendmsg;
@property (weak, nonatomic) IBOutlet UIImageView *Image_btnBG;
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
    
    // target to chat view
    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",self.UserInfo.uid];
    NSArray * array =  [Conversation MR_findAllWithPredicate:pre inContext:localContext];
    ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    if (array.count > 0) {
        chatview.conversation = array[0];
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
     [self.navigationController pushViewController:chatview animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
