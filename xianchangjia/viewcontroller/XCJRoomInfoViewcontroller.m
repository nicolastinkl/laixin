//
//  XCJRoomInfoViewcontroller.m
//  laixin
//
//  Created by apple on 3/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJRoomInfoViewcontroller.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "UIImage-Helpers.h"
#import "XCJFindRoomViewControl.h"
#include "OpenUDID.h"
#import "XCJBuySurityViewController.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"
#import "XCJSendMapViewController.h"
#import "XCJPayInfo.h"
#import "XCJSeeJiuShuiViewController.h"
#import "XCJSelectLaixinViewController.h"
#import "XCJAppDelegate.h"
#import "XCJTableViewMMController.h"
#import "FCUserDescription.h"
#import "UIImage+Resize.h"
#import "IDMPhotoBrowser.h"
#import "Conversation.h"
#import "FCMessage.h"
#import "CoreData+MagicalRecord.h"
#import "UIAlertView+Blocks.h"
#import "XCAlbumDefines.h"

#define PWdString @"PWdStringPINS"


@interface XCJRoomInfoViewcontroller () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    int currentActive_by;
    NSArray * arrayCardIDS;
    NSString * _currentAction;
    NSString * _currentpayID;
}
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_1_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_1_1;


@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *image_button;

@property (weak, nonatomic) IBOutlet UILabel *label_price;
@property (weak, nonatomic) IBOutlet UIButton *button_buy;
@property (weak, nonatomic) IBOutlet UILabel *label_serCount;

@property (weak, nonatomic) IBOutlet UIView *view_kSonger;

@property (weak, nonatomic) IBOutlet UILabel *label_KsongerNum;

@property (weak, nonatomic) IBOutlet UIImageView *image_tuijianPeople;

@end

@implementation XCJRoomInfoViewcontroller

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
    
    self.title = @"房间详情";
    
    [[self.view subviewWithTag:1] setTop:(APP_SCREEN_HEIGHT - 44)];
    [self.tableview setHeight:(APP_SCREEN_HEIGHT - 44)];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareclick:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self.button_buy infoStyle];
    
    currentActive_by = [[LXAPIController sharedLXAPIController] currentUser].active_by;
    if ([self.rominfo.type containString:@"豪"]) {
        [self.image_button setBackgroundImage:[UIImage imageNamed:@"room0002.jpg"] forState:UIControlStateNormal];
    }else   if ([self.rominfo.type containString:@"大"]) {
        [self.image_button setBackgroundImage:[UIImage imageNamed:@"room0003.jpg"] forState:UIControlStateNormal];
    }else   if ([self.rominfo.type containString:@"中"]) {
        [self.image_button setBackgroundImage:[UIImage imageNamed:@"room0004.jpg"] forState:UIControlStateNormal];
    }else   if ([self.rominfo.type containString:@"小"]) {
        [self.image_button setBackgroundImage:[UIImage imageNamed:@"room0005.jpg"] forState:UIControlStateNormal];
    }else{
        [self.image_button setBackgroundImage:[UIImage imageNamed:@"room0001.jpg"] forState:UIControlStateNormal];
    }
    
    int lowPrice = [self.rominfo.lowprice intValue]*.9;
    self.label_price.text = [NSString stringWithFormat:@"￥%d.00",lowPrice];

    self.label_name.text = self.rominfo.name;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLaixin:) name:@"changeLaixinMMID" object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyKSonger:) name:@"updateMyKSonger" object:nil];
    
    /*
     NSRange rang = [self.rominfo.parensNumber rangeOfString:@"-"];
     NSString * num =  [self.rominfo.parensNumber substringToIndex:rang.location];
     if ([num intValue] > 0) {
     [SVProgressHUD showWithStatus:@"正在处理..."];
     [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.count_price" parameters:@{@"mid":@"1",@"people_count":@([num intValue])} success:^(MLRequest *request, id responseObject) {
     if (responseObject) {
     int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
     if (errnoMesg == 0) {
     int price =  [num intValue] * 500;
     int lowPrice = [self.rominfo.lowprice intValue]*.9;
     self.label_price.text = [NSString stringWithFormat:@"￥%d.00",lowPrice + price];
     
     self.label_serCount.text = num;
     [SVProgressHUD dismiss];
     }
     }
     } failure:^(MLRequest *request, NSError *error) {
     [SVProgressHUD dismiss];
     self.label_serCount.text = @"0";
     [UIAlertView showAlertViewWithMessage:@"处理失败"];
     }];
     }
     */
}


-(void) updateMyKSonger:(NSNotification * ) notify
{
    if (notify.object) {
        NSMutableArray * array = [[EGOCache globalCache] plistForKey:KSingerCount];
        if (array.count > 0) {
            self.label_KsongerNum.text = [NSString stringWithFormat:@"%d位 ",array.count];
            self.view_kSonger.backgroundColor = [UIColor lightGrayColor];
            [self.view_kSonger.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [((UIView * )obj) removeAllSubViews];
                [((UIView * )obj) setHidden:YES];
            }];
            [self.view_kSonger layoutIfNeeded];
            self.cell_1_0.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }else{
            self.label_KsongerNum.text = @"";
            
            self.view_kSonger.backgroundColor = [UIColor clearColor];
            [self.view_kSonger.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [((UIView * )obj) removeAllSubViews];
                [((UIView * )obj) setHidden:YES];
            }];
            [self.view_kSonger layoutIfNeeded];
            self.cell_1_0.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
        

        int TITLE_jianxi = 2;
        int view_height = 12; // self.view_kSonger.height / array.count;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * userid = obj;
            int row = idx/3;
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(view_height*(idx%3)+TITLE_jianxi*(idx%3+1),TITLE_jianxi + (view_height+TITLE_jianxi) * row, view_height, view_height)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.hidden = NO;
            iv.clipsToBounds = YES;
            iv.tag = idx;
            iv.layer.cornerRadius = 1;
            iv.layer.masksToBounds = YES;
            [self.view_kSonger addSubview:iv];
            
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                if (response) {
                    FCUserDescription * user = response;
                    NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
                    [iv setImageWithURL:[NSURL URLWithString:Urlstring] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                }
                
            } withuid:userid];
        }];
        
        [self.cell_1_0 reloadInputViews];
    }
    
}

-(void) changeLaixin:(NSNotification * ) notify
{
    if (notify.object) {
        NSString * userid = notify.object;
        FCUserDescription * user = [[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:userid];
        if (user) {
            currentActive_by = [user.active_by intValue];
            
            NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
            [self.image_tuijianPeople setImageWithURL:[NSURL URLWithString:Urlstring]];
            self.image_tuijianPeople.layer.cornerRadius = self.image_tuijianPeople.height/2;
            self.image_tuijianPeople.layer.masksToBounds = YES;
            self.cell_1_1.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    }
}

- (IBAction)addSerClick:(id)sender {
    NSString * count = self.label_serCount.text;
    int thiscount = [count intValue];
    thiscount ++ ;
    if (thiscount > 0) {
        
        [SVProgressHUD showWithStatus:@"正在处理..."];
        [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.count_price" parameters:@{@"mid":@"1",@"people_count":@(thiscount)} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
                if (errnoMesg == 0) {
                    self.label_serCount.text = [NSString stringWithFormat:@"%d",thiscount];
                    
                    int price = thiscount * 500;
                    int lowPrice = [self.rominfo.lowprice intValue]*.9;
                    self.label_price.text = [NSString stringWithFormat:@"￥%d.00",lowPrice + price];
                    
                    
                    [SVProgressHUD dismiss];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"处理失败"];
            
        }];
    }
}


- (IBAction)removeSerClick:(id)sender {
    NSString * count = self.label_serCount.text;
    int thiscount = [count intValue];
    thiscount -- ;
    if (thiscount > 0) {
        [SVProgressHUD showWithStatus:@"正在处理..."];
        [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.count_price" parameters:@{@"mid":@"1",@"people_count":@(thiscount)} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
                if (errnoMesg == 0) {
                    int price = thiscount * 500;
                    int lowPrice = [self.rominfo.lowprice intValue]*.9;
                    self.label_price.text = [NSString stringWithFormat:@"￥%d",lowPrice + price];
                    self.label_serCount.text = [NSString stringWithFormat:@"%d",thiscount];
                    [SVProgressHUD dismiss];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"处理失败"];
            
        }];
    }
}



- (IBAction)seeImage:(id)sender {
    
    UIButton *   buttonSender = sender;
    NSArray * arrayPhotos  = [IDMPhoto photosWithImages:@[[UIImage imageNamed:@"room0001.jpg"],[UIImage imageNamed:@"room0002.jpg"],[UIImage imageNamed:@"room0003.jpg"],[UIImage imageNamed:@"room0004.jpg"],[UIImage imageNamed:@"room0005.jpg"],[UIImage imageNamed:@"room0006.jpg"],[UIImage imageNamed:@"room0007.jpg"],[UIImage imageNamed:@"room0008.jpg"]]];
//    NSArray * arrayPhotos  = [IDMPhoto photosWithURLs:dataSource_imageurls];
    // Create and setup browser
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arrayPhotos animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
    //        browser.delegate = self;
    browser.displayActionButton = NO;
    browser.displayArrowButton = NO;
    browser.displayCounterLabel = YES;
    [browser setInitialPageIndex:0];
    if (buttonSender.imageView.image) {
//        browser.scaleImage = buttonSender.imageView.image;        // Show
    }
    [self presentViewController:browser animated:YES completion:nil];
}

- (IBAction)buyClick:(id)sender {
    NSMutableArray * array = [[EGOCache globalCache] plistForKey:KSingerCount];
    NSString * strtitle;
    if (array.count > 0) {
        strtitle = [NSString stringWithFormat:@"一共选择了%d位K歌指导员,确定提交订单吗",array.count];
    }else{
        strtitle = @"确定提交订单吗";
    }
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:strtitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"￥99元 立即预订" otherButtonTitles:nil, nil];
    actionsheet.tag = 3;
    [actionsheet showInView:self.view];
    
}

-(IBAction)shareclick:(id)sender
{
    //私信ta
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"分享到微信" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"好友", @"朋友圈",@"微信收藏",nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2) {
        //1  朋友圈
        //0   好友
        
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        UIImage * image = [self.tableview  viewToImage:self.tableview.tableHeaderView];
        NSData * data = UIImageJPEGRepresentation(image, .5);
        switch (buttonIndex) {
            case 0:
            {
                [delegate sendImageContent:0 withImageData:data];
            }
                break;
            case 1:
            {
                [delegate sendImageContent:1 withImageData:data];
            }
                break;
            case 2:
            {
                [delegate sendImageContent:2 withImageData:data];
            }
                break;
            default:
                break;
        }
        
    }else if(actionSheet.tag == 3)
    {
        if(buttonIndex == 0)
        {
            [SVProgressHUD showWithStatus:@"正在处理..."];
            [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.cards" parameters:@{} success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    NSDictionary * reultDict = responseObject[@"result"];
                    
                    NSArray * array = reultDict[@"cards"];
                    if (array && array.count > 0) {
                        [SVProgressHUD dismiss];
                        arrayCardIDS = [NSArray arrayWithArray:array];
                        UIAlertView *paySelectBank = [[UIAlertView alloc] initWithTitle:@"选择银行卡" message:nil delegate:self cancelButtonTitle:@"放弃支付" otherButtonTitles:nil, nil];
                        
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString * cardName = [DataHelper getStringValue:obj[@"card_name"] defaultValue:@""];
                            NSString * cardNumberlast = [DataHelper getStringValue:obj[@"card_last"] defaultValue:@""];
                            [paySelectBank addButtonWithTitle:[NSString stringWithFormat:@"%@(尾号%@)",cardName,cardNumberlast]];
                        }];
                        [paySelectBank addButtonWithTitle:@"添加其它银行卡支付"];
                        paySelectBank.tag = 4;
                        [paySelectBank show];
                    }else{
                        arrayCardIDS = @[];
                        //merchandise.tenpay
                        [self SurePayClick:@"merchandise.createorder" withCardid:nil];
                    }
                }
            } failure:^(MLRequest *request, NSError *error) {
                [UIAlertView showAlertViewWithMessage:@"网络请求失败,请检查网络设置"];
            }];
            
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 4)
    {
        if (arrayCardIDS && arrayCardIDS.count > 0) {
            if(buttonIndex > 0)
            {
                if (buttonIndex <= arrayCardIDS.count) {
                    //选择银行卡
                    NSDictionary * objDicy = arrayCardIDS[buttonIndex-1];
                    NSString * cardid = [DataHelper getStringValue:objDicy[@"cardid"] defaultValue:@""];
                    [self SurePayClick:@"merchandise.paybycard" withCardid:cardid];
                }else{
                   // 添加银行卡
                    // 易宝支付: merchandise.createorder  财付通支付 :merchandise.tenpay
                   [self SurePayClick:@"merchandise.createorder" withCardid:nil];
                }
            }
        }
    }
}

//确认支付
-(void) SurePayClick:(NSString * )action withCardid:(NSString * ) cardid
{
    
    _currentAction = action;
    _currentpayID = cardid;
    __block UIAlertView  *  prompt =[[UIAlertView alloc] initWithTitle:@"请输入进入来抢的界面密码" message:@""
       cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
        
    }] otherButtonItems:[RIButtonItem itemWithLabel:@"确定支付" action:^{
        UITextField *tf = [prompt textFieldAtIndex:0];
        // NICK
        if (tf.text.length > 0) {
            
            NSString * newmd5Str = [tf.text md5Hash];
            
            NSString * PinOld = [USER_DEFAULT stringForKey:PWdString];
            
            if ([newmd5Str isEqualToString:PinOld]) {
                NSString* openUDID = [OpenUDID value];
                //  NSString * count = self.label_serCount.text;
                //  int thiscount = [count intValue];
                NSMutableArray * array = [[EGOCache globalCache] plistForKey:KSingerCount];
                int thiscount = array.count;
                [SVProgressHUD showWithStatus:@"正在处理..."];
                NSDictionary * dict;
                if(currentActive_by > 0)
                {
                    if (cardid) {
                        dict = @{@"mid":@(self.rominfo.mid),@"people_count":@(thiscount),@"hardwareid":openUDID,@"recommend_uid":@(currentActive_by),@"cardid":cardid};
                    }else{
                        dict = @{@"mid":@(self.rominfo.mid),@"people_count":@(thiscount),@"hardwareid":openUDID,@"recommend_uid":@(currentActive_by)};
                    }
                }
                else
                {
                    if (cardid) {
                        dict = @{@"mid":@(self.rominfo.mid),@"people_count":@(thiscount),@"hardwareid":openUDID,@"cardid":cardid};
                    }else{
                        dict = @{@"mid":@(self.rominfo.mid),@"people_count":@(thiscount),@"hardwareid":openUDID};
                    }
                    
                }
                
                [[MLNetworkingManager sharedManager] sendWithAction:action parameters:dict success:^(MLRequest *request, id responseObject) {
                    if (responseObject) {
                        int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
                        if (errnoMesg == 0) {
                            [SVProgressHUD dismiss];                            
                            if (currentActive_by > 0) {
                                // set cache
                                [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%d",currentActive_by] forKey:@"currentActive_by"];
                            }
                            NSDictionary * dict = responseObject[@"result"];
                            NSString * string   = [DataHelper getStringValue: dict[@"gourl"] defaultValue:@""];
                            if (string.length > 0) {
                                
                                DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:string]];
                                webBrowser.showProgress = YES;
                                webBrowser.allowSharing = YES;
                                UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
                                [webBrowserNC pushViewController:webBrowser animated:NO];
                                [self presentViewController:webBrowserNC animated:YES completion:NULL];
                                
                            }else{
                                [UIAlertView showAlertViewWithTitle:@"新订单提醒" message:@"\n提交订单成功，请等待支付结果!\n\n请进入我的订单查看订单详情"];
                            }
                        }
                    }
                } failure:^(MLRequest *request, NSError *error) {
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"处理失败"];
                    
                }];
            }else{
                [UIAlertView showAlertViewWithMessage:@"密码错误"];
            }
        }
<<<<<<< HEAD
    }], nil];
    
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf = [prompt textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [prompt show];
     
=======
    } failure:^(MLRequest *request, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView showAlertViewWithMessage:@"处理失败"];
        
    }];
}


-(void) SavedbData:(NSString * ) uid  withType:(NSString * ) stringName;
{
    // target to chat view
    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",uid];
    Conversation * array =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
    if (array) {
        //系统消息公告
        FCMessage * msg = [FCMessage MR_createInContext:localContext];
        msg.messageType = @(messageType_SystemAD);
        msg.text =stringName;
        msg.sentDate = [NSDate date];
        msg.audioUrl = @"";
        // message did not come, this will be on rigth
        msg.messageStatus = @(NO);
        msg.messageId =  [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
        msg.messageguid = @"";
        msg.messageSendStatus = @0;
        msg.facebookID = array.facebookId;
        msg.read = @YES;
        [array addMessagesObject:msg];
        array.lastMessage = msg.text;
        array.lastMessageDate = [NSDate date];
        array.messageType = @(XCMessageActivity_UserPrivateMessage);
        array.messageStutes = @(messageStutes_incoming);
        array.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
        
        [localContext MR_saveOnlySelfAndWait];
    }else{
        // create new
        Conversation * conversation =  [Conversation MR_createInContext:localContext];
        conversation.lastMessageDate = [NSDate date];
        conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
        conversation.messageStutes = @(messageStutes_incoming);
        conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
//        conversation.facebookName = user.nick;
        conversation.facebookId = uid;
        conversation.badgeNumber = @0;
        {
            //系统消息公告
            FCMessage * msg = [FCMessage MR_createInContext:localContext];
            msg.messageType = @(messageType_SystemAD);
            msg.text = stringName;
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
    }

>>>>>>> FETCH_HEAD
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 90;
        }else if (indexPath.row == 1) {
            return 50;
        }else if (indexPath.row == 2) {
            return 50;
        }else  if (indexPath.row == 3)
        {
            return 151;
        }
    }else  if(indexPath.section == 1 || indexPath.section == 2 )
    {
        return 50;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }else if (section == 1)
    {
        return 2;
    }else if(section == 2)
    {
        return 1;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            //    self.label_phone.text = self.locatinfo.phone[0];
            UIActionSheet * sheet = [[UIActionSheet alloc ] initWithTitle:@"拨打商家客服电话" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            
             [self.locatinfo.phone enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [sheet addButtonWithTitle:obj];
             }];
            [sheet addButtonWithTitle:@"取消"];
            sheet.cancelButtonIndex = self.locatinfo.phone.count;
            [sheet showInView:self.view];
        }else if(indexPath.row == 2)
        {
            /*
             Printing description of self->_TCoordinate.latitude:
             (CLLocationDegrees) latitude = 30.62439918518066
             Printing description of self->_TCoordinate.longitude:
             (CLLocationDegrees) longitude = 104.0722732543945
             */
            XCJSendMapViewController *mapview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSendMapViewController"];
            CLLocationCoordinate2D mylocation = CLLocationCoordinate2DMake(30.62439918518066, 104.0722732543945) ;
            mapview.isSeeTaMap = YES;
            mapview.TCoordinate = mylocation;
            mapview.title = self.locatinfo.addressName;
            mapview.subtitle = @"";
            
            [self.navigationController pushViewController:mapview animated:YES];
        }
    }else if(indexPath.section == 1)
    {
        switch (indexPath.row) {
           
            case 0:
            {
                XCJTableViewMMController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJTableViewMMController"];
                viewcontrs.title = @"K歌指导员";
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
            case 1:
            {
                return;
                XCJSelectLaixinViewController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelectLaixinViewController"];
                viewcontrs.title = @"联系人";
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else if(indexPath.section == 2)
    {
        if (indexPath.row == 0) {
            XCJSeeJiuShuiViewController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSeeJiuShuiViewController"];
            [self.navigationController pushViewController:viewcontrs animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * str = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (![str isEqualToString:@"取消"]) {
        
        NSMutableString * strURL = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",str];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",str]]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                CellIdentifier = @"Cell_0_0";
            }else if (indexPath.row == 1) {
                CellIdentifier = @"Cell_0_1";
            }else if (indexPath.row == 2) {
                CellIdentifier = @"Cell_0_2";
            }else if (indexPath.row == 3) {
                CellIdentifier = @"Cell_0_3";
            }
            break;
        case 1:
            if (indexPath.row == 0)
                CellIdentifier = @"Cell_1_0";
            else if (indexPath.row == 1)
                CellIdentifier = @"Cell_1_1";
            
            break;
        case 2:
            if (indexPath.row == 0)
                CellIdentifier = @"Cell_2_0";
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {

            }else if (indexPath.row == 1) {
                UILabel * label = (UILabel *) [cell.contentView subviewWithTag:1];
                label.text =  self.locatinfo.phone[0];
            }else if (indexPath.row == 2) {
                UILabel * label = (UILabel *) [cell.contentView subviewWithTag:1];
                label.text =   self.locatinfo.addressName;
            }else if (indexPath.row == 3) {
                UILabel * label_sig1 = (UILabel *) [cell.contentView subviewWithTag:2];
                UILabel *label_two = (UILabel *) [cell.contentView subviewWithTag:3];
                UILabel *label_one = (UILabel *) [cell.contentView subviewWithTag:4];
                label_sig1.layer.cornerRadius = 2.0f;
                label_one.layer.cornerRadius = 2.0f;
                label_two.layer.cornerRadius = 2.0f;
                label_one.layer.masksToBounds = YES;
                label_two.layer.masksToBounds = YES;
                label_sig1.layer.masksToBounds = YES;
            }
            break;
        case 1:
            if (indexPath.row == 0)
            {
                self.label_KsongerNum = (UILabel *) [cell.contentView subviewWithTag:1];
                self.view_kSonger = (UILabel *) [cell.contentView subviewWithTag:2];
                
                self.view_kSonger.layer.cornerRadius = 2.0f;
                self.view_kSonger.layer.masksToBounds = YES;
                
                self.cell_1_0 = cell;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
            }
            
            else if (indexPath.row == 1)
            {
                self.image_tuijianPeople = (UIImageView *) [cell.contentView subviewWithTag:1];
                self.cell_1_1 = cell;
                
                if ([LXAPIController sharedLXAPIController].currentUser.active_by > 0) {
                    currentActive_by = [LXAPIController sharedLXAPIController].currentUser.active_by;
                    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                        if (response) {
                            FCUserDescription * user = response;
                            NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
                            [self.image_tuijianPeople setImageWithURL:[NSURL URLWithString:Urlstring]];
                            self.image_tuijianPeople.layer.cornerRadius = self.image_tuijianPeople.height/2;
                            self.image_tuijianPeople.layer.masksToBounds = YES;
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        
                    } withuid:[NSString stringWithFormat:@"%d",[LXAPIController sharedLXAPIController].currentUser.active_by]];
                }
                
            }
            break;
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
