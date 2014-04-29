//
//  XCJRecommendUIDViewContrl.m
//  laixin
//
//  Created by apple on 3/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJRecommendUIDViewContrl.h"
#import "XCAlbumAdditions.h"
#import "PayPellog.h"
#import "UIButton+Bootstrap.h"
#import "XCJPayInfo.h"
#import "UINavigationSample.h"
#import "FCUserDescription.h"
#import "UIButton+WebCache.h"
#import "XCJAddUserTableViewController.h"
#import "XCJShowOrderEcodeImageViewcontroller.h"

@interface XCJRecommendUIDViewContrl ()
{
    NSMutableArray * _datasouces;
    NSMutableDictionary * DictAry;
}
@end

@implementation XCJRecommendUIDViewContrl

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
    self.navigationItem.backBarButtonItem.title = @"返回";
    self.title = @"我是联系人的订单";
    {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        _datasouces = array;
        
    }
    
    NSMutableDictionary * arrayDicy = [[NSMutableDictionary alloc] init];
    DictAry = arrayDicy;
    
    [self.view showIndicatorViewLargeBlue];
    
    NSMutableArray * arrayMID = [[NSMutableArray alloc] init];
    [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.recommendbyme" parameters:@{@"count":@"10000"} success:^(MLRequest *request, id responseObject) {
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

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return  _datasouces.count;
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    PayOrderHistorylog * pay = _datasouces[indexPath.section];
    XCJShowOrderEcodeImageViewcontroller *viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJShowOrderEcodeImageViewcontroller"];
    viewContr.orderID = pay.orderid;
    [self.navigationController pushViewController:viewContr animated:YES];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    PayOrderHistorylog * pay = _datasouces[indexPath.section];
    
    UILabel * labelname = (UILabel*) [cell.contentView subviewWithTag:1];
    [(UIView *)[cell.contentView subviewWithTag:22] setHeight:.5];
    [(UIView *)[cell.contentView subviewWithTag:23] setHeight:.5];
    UILabel * labelBg = (UILabel*) [cell.contentView subviewWithTag:4];
    UILabel * labelBgname = (UILabel*) [cell.contentView subviewWithTag:5];
    
    UILabel * labelDes = (UILabel*) [cell.contentView subviewWithTag:6];
    UILabel * labelFiller = (UILabel*) [cell.contentView subviewWithTag:7];
    UILabel * labelPriceRoom = (UILabel*) [cell.contentView subviewWithTag:8];
    
    UIView * stateView =   [cell.contentView subviewWithTag:15];
    
    UILabel * labelTotalPrice = (UILabel*) [stateView subviewWithTag:9];
    UILabel * labelExCount = (UILabel*) [stateView subviewWithTag:10];
    
    roomInfo * rominfo = DictAry[[NSString stringWithFormat:@"%d",pay.mid]];
    
    UIImageView * image_payStatu = (UIImageView*) [cell.contentView subviewWithTag:30];
    
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
        image_payStatu.hidden = YES;
    }else if (pay.paystate == 1) { //已经支付 消费
        image_payStatu.image = [UIImage imageNamed:@"trip_order_alreadybuy"];
        image_payStatu.hidden = NO;
    }else if (pay.paystate == 2) { //退款 
        image_payStatu.hidden = NO;
        image_payStatu.image = [UIImage imageNamed:@"trip_order_hasfailed"];
    }
    
    UIButton * button_user = (UIButton*) [cell.contentView subviewWithTag:17];
    
    button_user.layer.cornerRadius = button_user.height/2;
    button_user.layer.masksToBounds = YES;
    
    UILabel * label_username = (UILabel*) [cell.contentView subviewWithTag:18];
    UILabel * label_time = (UILabel*) [cell.contentView subviewWithTag:19];
    label_time.text = [tools timeLabelTextOfTime:pay.create_time];
     [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
         if (response) {
             FCUserDescription * useinfo = response;
             
             [button_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:useinfo.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
             label_username.text = useinfo.nick;
             label_username.textColor = [tools colorWithIndex:0];
             [button_user.layer setValue:[NSString stringWithFormat:@"%d",pay.uid] forKey:@"useid"];
             [button_user addTarget:self action:@selector(SeeUseinfoClick:) forControlEvents:UIControlEventTouchUpInside];
         }
         
     } withuid:[NSString stringWithFormat:@"%d",pay.uid]];
    
    return cell;
}

-(IBAction)SeeUseinfoClick:(id)sender
{
    UIButton * button = sender;
    NSString * stringid = [button.layer valueForKey:@"useid"];
//    UITableViewCell * cell = (UITableViewCell *) button.superview.superview.superview;
//    PayOrderHistorylog * pay = _datasouces[[self.tableView indexPathForCell:cell].row];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        if (response) {
            FCUserDescription * useinfo = response;
            XCJAddUserTableViewController *viewcontr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            viewcontr.UserInfo = useinfo;
            [self.navigationController pushViewController:viewcontr animated:YES];
        }
        
    } withuid:stringid];
    
}

@end
