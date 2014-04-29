//
//  XCJOrderAllViewController.m
//  laixin
//
//  Created by apple on 3/7/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJOrderAllViewController.h"
#import "XCAlbumAdditions.h"
#import "PayPellog.h"
#import "UIButton+Bootstrap.h"
#import "XCJPayInfo.h"
#import "UINavigationSample.h"
#import "XCJRecommendUIDViewContrl.h"
#include "OpenUDID.h"
#import "DZWebBrowser.h"
#import "SJAvatarBrowser.h"
#import "QRCodeGenerator.h"
#import "NSString+Addition.h"
#import "XCJShowOrderEcodeImageViewcontroller.h"
#import "NSData+SRB64Additions.h"

@interface XCJOrderAllViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray * _datasouces;
    NSMutableArray * _datasouces_Used;
    NSMutableArray * _datasouces_canntrefund;
    NSMutableDictionary * DictAry;
    int pagetype;
    
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@end

@implementation XCJOrderAllViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)SegemvalueChange:(id)sender {
    UISegmentedControl * control = sender;
    pagetype =  control.selectedSegmentIndex;
    [self.tableView reloadData];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.searchbar isFirstResponder]) {
        [self.searchbar resignFirstResponder];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        _datasouces = array;
        
    }
    
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        _datasouces_Used = array;
        
    }
    
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        _datasouces_canntrefund = array;
        
    }
    
    pagetype = 0;
    
    
    NSMutableDictionary * arrayDicy = [[NSMutableDictionary alloc] init];
    DictAry = arrayDicy;
    
    
//    self.title = @"订单详情";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
     "orderid":"1394161723-366",
     "payid":9,
     "uid":1,
     "mid":1,
     "productname":"测试商品",
     "amount":26,
     "create_time":1394161970,
     "productdesc":"测试商品介绍",
     "ex_people":8,
     "productcatalog":1,
     "paystate":1*/
    [self.view showIndicatorViewLargeBlue];
    //@"before":@0,
    NSMutableArray * arrayMID = [[NSMutableArray alloc] init];
    //财付通 merchandise.ten_history
    [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.history" parameters:@{@"count":@(10000)} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"result"];
            NSArray * jsonArray = dict[@"history"];
            [jsonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PayOrderHistorylog * log = [PayOrderHistorylog turnObject:obj];
                if (log) {
                    [_datasouces addObject:log];
                    if (![arrayMID containsObject:@(log.mid)]) {
                        [arrayMID addObject:@(log.mid)];
                    }
                    if (log.paystate == 1) {
                        [_datasouces_Used addObject:log]; //已消费
                    }else if (log.paystate == 2) {
                        [_datasouces_canntrefund addObject:log]; //已退款
                    }
                }
            }];
            
            if (jsonArray.count == 0) {
                [self showErrorText:@"没有订单"];
                [self.view hideIndicatorViewBlueOrGary];
            }else{
                [self resquestData:arrayMID];
            }
            
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        [self showErrorText:@"加载出错,请检查网络设置"];
        [self.view hideIndicatorViewBlueOrGary];
    }];
    
    UIBarButtonItem * baritem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonMinified"] style:UIBarButtonItemStyleBordered target:self action:@selector(showActionClick:)];
    
    self.navigationItem.rightBarButtonItem = baritem;
    
}

-(IBAction)showActionClick:(id)sender
{
    //查看 我被推荐的订单
    //merchandise.recommendbyme
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"查看我是联系人的订单" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"查看" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        XCJRecommendUIDViewContrl * viewtrol = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJRecommendUIDViewContrl"];
        viewtrol.navigationItem.backBarButtonItem.title = @"返回";
        [self.navigationController pushViewController:viewtrol animated:YES];
    }
}

-(void) resquestData:(NSArray * )arrayMID
{
    [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.get" parameters:@{@"mid":arrayMID} success:^(MLRequest *request, id responseObjects) {
        if (responseObjects) {
            NSDictionary * dicts =  responseObjects[@"result"];
            NSArray * merchandisesArray = dicts[@"merchandises"];
            [merchandisesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                roomInfo * rominfo = [[roomInfo alloc] initWithJSONObject:obj];
                if (rominfo) {
                    [DictAry setValue:rominfo forKey:[NSString stringWithFormat:@"%d",rominfo.mid]];
                }
            }];
        }
        [self.view hideIndicatorViewBlueOrGary];
        [self.tableView reloadData];
    } failure:^(MLRequest *request, NSError *error) {
        [self showErrorText:@"加载出错,请检查网络设置"];
        [self.view hideIndicatorViewBlueOrGary];
    }];
    
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
    if (pagetype == 0) {
        return _datasouces.count;
    }else     if (pagetype == 1) {
        return _datasouces_Used.count;
    }else     if (pagetype == 2) {
        return _datasouces_canntrefund.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 196.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    PayOrderHistorylog * pay ;
    if (pagetype == 0) {
        pay = _datasouces[indexPath.section];
    }else     if (pagetype == 1) {
        pay = _datasouces_Used[indexPath.section];
    }else     if (pagetype == 2) {
        pay = _datasouces_canntrefund[indexPath.section];
    }
    
    UILabel * labelname = (UILabel*) [cell.contentView subviewWithTag:1];
//    UILabel * labelOne = (UILabel*) [cell.contentView subviewWithTag:2];
//    UILabel * labeltwo = (UILabel*) [cell.contentView subviewWithTag:3];
//    [labelOne setHeight:0.5];
//    [labeltwo setHeight:0.5]; 
    UILabel * labelBg = (UILabel*) [cell.contentView subviewWithTag:4];
    UILabel * labelBgname = (UILabel*) [cell.contentView subviewWithTag:5];
    
    UILabel * labelDes = (UILabel*) [cell.contentView subviewWithTag:6];
    UILabel * labelFiller = (UILabel*) [cell.contentView subviewWithTag:7];
    UILabel * labelPriceRoom = (UILabel*) [cell.contentView subviewWithTag:8];
    
    UIButton * button_pay = (UIButton*) [cell.contentView subviewWithTag:11];
    UIButton * button_play = (UIButton*) [cell.contentView subviewWithTag:12];
    
    UIView * stateView =   [cell.contentView subviewWithTag:15];
    
    UILabel * labelTotalPrice = (UILabel*) [stateView subviewWithTag:9];
    UILabel * labelExCount = (UILabel*) [stateView subviewWithTag:10];
    
    roomInfo * rominfo = DictAry[[NSString stringWithFormat:@"%d",pay.mid]];
    
    UIImageView * image_payStatu = (UIImageView*) [cell.contentView subviewWithTag:30];
    UILabel * label_time = (UILabel*) [cell.contentView subviewWithTag:19];
    label_time.text = [tools timeLabelTextOfTime:pay.create_time];
    int colorindex = indexPath.section % 6 + 1 ;
    labelBg.backgroundColor  = [tools colorWithIndex:colorindex];
    labelname.text = rominfo.productname;
    labelBgname.text = rominfo.name;
    labelDes.text = rominfo.productdesc;
    labelFiller.text = [NSString stringWithFormat:@"适合%@人",rominfo.parensNumber];
    labelPriceRoom.text = [NSString stringWithFormat:@"￥%@.00",rominfo.lowprice];
    labelExCount.text = [NSString stringWithFormat:@"%d",pay.ex_people];
    
    if (pay.remain >= 100) {
        labelTotalPrice.text =  [NSString stringWithFormat:@"￥%d.00",pay.remain/100];
    }else{
        if (pay.remain >=10) {
            labelTotalPrice.text =  [NSString stringWithFormat:@"￥0.%d",pay.remain];
        }else{
            labelTotalPrice.text =  [NSString stringWithFormat:@"￥0.0%d",pay.remain];
        }
    }
    
    if (pay.paystate == 0) {
        button_pay.hidden = YES;
        button_play.hidden = YES;
        image_payStatu.hidden = YES;
        [stateView setLeft:15];
    }else if (pay.paystate == 1) { //已经支付 消费
        button_pay.hidden = YES;
        button_play.hidden = YES;
        image_payStatu.image = [UIImage imageNamed:@"trip_order_alreadybuy"];
        image_payStatu.hidden = NO;
        [stateView setLeft:160];
    }else if (pay.paystate == 2) { //退款
        button_pay.hidden = YES;
        button_play.hidden = YES;
        image_payStatu.hidden = YES;
         [stateView setLeft:160];
    }
    
    [button_play primaryStyle];
    [button_pay sendMessageStyle];
    
    [button_pay addTarget:self action:@selector(payClick:) forControlEvents:UIControlEventTouchUpInside];
    [button_play addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

/**
 *  支付
 *
 *  @param sender <#sender description#>
 */
-(IBAction)payClick:(id)sender
{
    
    UIButton * button  = sender;
    UITableViewCell * cell = (UITableViewCell *) button.superview.superview.superview;
    NSIndexPath *  indexPath =  [self.tableView indexPathForCell:cell];
    PayOrderHistorylog * pay ;
    if (pagetype == 0) {
        pay = _datasouces[indexPath.section];
    }else     if (pagetype == 1) {
        pay = _datasouces_Used[indexPath.section];
    }else     if (pagetype == 2) {
        pay = _datasouces_canntrefund[indexPath.section];
    }
    NSString* openUDID = [OpenUDID value];
    
    [SVProgressHUD showWithStatus:@"正在处理..."];
    //,@"cardid":pay.orderid
    [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.tenpay" parameters:@{@"mid":@(pay.mid),@"people_count":@(pay.ex_people),@"hardwareid":openUDID} success:^(MLRequest *request, id responseObject) {
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PayOrderHistorylog * pay ;
    if (pagetype == 0) {
        pay = _datasouces[indexPath.section];
    }else     if (pagetype == 1) {
        pay = _datasouces_Used[indexPath.section];
    }else     if (pagetype == 2) {
        pay = _datasouces_canntrefund[indexPath.section];
    }
    
    XCJShowOrderEcodeImageViewcontroller *viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJShowOrderEcodeImageViewcontroller"];
    viewContr.orderID = pay.orderid;
    [self.navigationController pushViewController:viewContr animated:YES];
    
    
}

/**
 *  消费
 *
 *  @param sender <#sender description#>
 */
-(IBAction)playClick:(id)sender
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否标记为已消费?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
