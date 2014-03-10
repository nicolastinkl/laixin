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



@interface XCJRoomInfoViewcontroller () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_0_2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_1_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_0;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell_2_3;


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
    
    self.label_one.layer.cornerRadius = 3.0f;
    self.label_two.layer.cornerRadius = 3.0f;
    self.label_one.layer.masksToBounds = YES;
    self.label_two.layer.masksToBounds = YES; 
    
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
        return 3;
    }else if (section == 1)
    {
        return 1;
    }else if(section ==2)
    {
        return 4;
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
            case 1:
            {
                XCJSeeJiuShuiViewController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSeeJiuShuiViewController"];
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
            case 2:
            {
                XCJTableViewMMController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJTableViewMMController"];
                viewcontrs.title = @"K歌指导员";
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
            case 3:
            {
                
                XCJSelectLaixinViewController * viewcontrs = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelectLaixinViewController"];
                viewcontrs.title = @"选择推荐人";
                [self.navigationController pushViewController:viewcontrs animated:YES];
            }
                break;
                
            default:
                break;
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
            else if (indexPath.row == 2)
                cell= self.cell_2_2;
            else if (indexPath.row == 3)
                cell= self.cell_2_3;
            
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
