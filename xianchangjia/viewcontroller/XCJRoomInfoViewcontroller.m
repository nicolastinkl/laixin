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


@interface XCJRoomInfoViewcontroller () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    int currentActive_by;
}
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_1_0;

@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_3_0;

@property (weak, nonatomic) IBOutlet UILabel *label_sig1;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *image_button;
@property (weak, nonatomic) IBOutlet UILabel *label_address;
@property (weak, nonatomic) IBOutlet UILabel *label_phone;
@property (weak, nonatomic) IBOutlet UILabel *label_one;
@property (weak, nonatomic) IBOutlet UILabel *label_two;
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
    self.label_sig1.layer.cornerRadius = 2.0f;
    self.label_sig1.layer.masksToBounds = YES;
    self.label_one.layer.cornerRadius = 2.0f;
    self.label_two.layer.cornerRadius = 2.0f;
    self.label_one.layer.masksToBounds = YES;
    self.label_two.layer.masksToBounds = YES; 
    
    self.view_kSonger.layer.cornerRadius = 2.0f;
    self.view_kSonger.layer.masksToBounds = YES;
    
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
    
    self.label_phone.text = self.locatinfo.phone[0];
    
    self.label_address.text = self.locatinfo.addressName;
    
    self.label_serCount.text = @"0";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLaixin:) name:@"changeLaixinMMID" object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyKSonger:) name:@"updateMyKSonger" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
    
    if ([LXAPIController sharedLXAPIController].currentUser.active_by > 0) {
        currentActive_by = [LXAPIController sharedLXAPIController].currentUser.active_by;
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
            FCUserDescription * user = response;
            NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
            [self.image_tuijianPeople setImageWithURL:[NSURL URLWithString:Urlstring]];
            self.image_tuijianPeople.layer.cornerRadius = self.image_tuijianPeople.height/2;
            self.image_tuijianPeople.layer.masksToBounds = YES;
            self.cell_2_1.accessoryType = UITableViewCellAccessoryCheckmark;
        } withuid:[NSString stringWithFormat:@"%d",[LXAPIController sharedLXAPIController].currentUser.active_by]];
    }
    
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
            self.cell_2_0.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }else{
            self.label_KsongerNum.text = @"";
            
            self.view_kSonger.backgroundColor = [UIColor clearColor];
            [self.view_kSonger.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [((UIView * )obj) removeAllSubViews];
                [((UIView * )obj) setHidden:YES];
            }];
            [self.view_kSonger layoutIfNeeded];
            self.cell_2_0.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
                FCUserDescription * user = response;
                NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
                [iv setImageWithURL:[NSURL URLWithString:Urlstring] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
            } withuid:userid];
        }];
        
        [self.cell_2_0 reloadInputViews];
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
            self.cell_2_1.accessoryType = UITableViewCellAccessoryCheckmark;
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
    
}


- (IBAction)buyClick:(id)sender {
    
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"确定提交订单吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"提交" otherButtonTitles:nil, nil];
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
        UIImage * image = [self.tableview  viewToImage:self.tableview];
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
            
            NSString* openUDID = [OpenUDID value];
            
            NSString * count = self.label_serCount.text;
            int thiscount = [count intValue];
            [SVProgressHUD showWithStatus:@"正在处理..."];
            [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.createorder" parameters:@{@"mid":@(self.rominfo.mid),@"people_count":@(thiscount),@"hardwareid":openUDID} success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
                    if (errnoMesg == 0) {
                        [SVProgressHUD dismiss];
                        NSDictionary * dict = responseObject[@"result"];
                        NSString * string   = [DataHelper getStringValue: dict[@"gourl"] defaultValue:@""];
                        DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:string]];
                        webBrowser.showProgress = YES;
                        webBrowser.allowSharing = YES;
                        //
                        UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
                        [webBrowserNC pushViewController:webBrowser animated:NO];
                        
                        //[[UINavigationSample alloc] initWithRootViewController:webBrowser];
                        [self presentViewController:webBrowserNC animated:YES completion:NULL];
                        
                        
                        /* XCJBuySurityViewController * surView = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJBuySurityViewController"];
                         
                         surView.BuyUrl      = [NSURL URLWithString:string];
                         [self.navigationController pushViewController:surView animated:YES];
                         */
                    }
                }
            } failure:^(MLRequest *request, NSError *error) {
                [SVProgressHUD dismiss];
                [UIAlertView showAlertViewWithMessage:@"处理失败"];
                
            }];

        }
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 90;
        }
        return 44.0f;
    }else if (indexPath.section == 1)
    {
        return 151;
    }else if(indexPath.section == 2)
    {
        return 50;
    } else if(indexPath.section == 3)
    {
        return 50;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }else if (section == 1)
    {
        return 1;
    }else if(section ==2)
    {
        return 2;
    }else if(section ==3)
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
    }else if(indexPath.section == 2)
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
                XCJSelectLaixinViewController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelectLaixinViewController"];
                viewcontrs.title = @"选择推荐人";
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else if(indexPath.section == 3)
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",str]]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell = self.cell_0_0;
            }else if (indexPath.row == 1) {
                cell= self.cell_0_1;
            }else if (indexPath.row == 2) {
                cell= self.cell_0_2;
            }
            break;
        case 1:
            if (indexPath.row == 0)
            cell= self.cell_1_0;
            break;
        case 2:
            if (indexPath.row == 0)
                cell= self.cell_2_0;
            else if (indexPath.row == 1)
                cell= self.cell_2_1;
            
            break;
        case 3:
            if (indexPath.row == 0)
                
                cell= self.cell_3_0;
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
