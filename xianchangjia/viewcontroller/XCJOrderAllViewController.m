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

@interface XCJOrderAllViewController ()
{
    NSMutableArray * _datasouces;
}
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray * array = [[NSMutableArray alloc] init];
    _datasouces = array;
    
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
    
    PayPellog * pay = [[PayPellog alloc] init];
    pay.orderid = @"1394161723-366";
    pay.payid = 9;
    pay.mid = 1;
    pay.uid = 1;
    pay.productname = @"至尊公爵";
    pay.amount = 26;
    pay.create_time = 1394161970.0;
    pay.productdesc = @"豪华包间,适合12-15人";
    pay.productcatalog = 1;
    pay.paystate = 1;
    pay.ex_people = 8;
    
    [_datasouces addObject:pay];
    pay.paystate = 0;
    [_datasouces addObject:pay];
    pay.ex_people = 2;
    [_datasouces addObject:pay];
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
    return _datasouces.count;
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
    
    PayPellog * pay = _datasouces[indexPath.section];
    
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
    UILabel * labelTotalPrice = (UILabel*) [cell.contentView subviewWithTag:9];
    UILabel * labelExCount = (UILabel*) [cell.contentView subviewWithTag:10];
    
    UIButton * button_pay = (UIButton*) [cell.contentView subviewWithTag:11];
    UIButton * button_play = (UIButton*) [cell.contentView subviewWithTag:12];
    
    
    int colorindex = indexPath.section % 6 + 1 ;
    labelBg.backgroundColor  = [tools colorWithIndex:colorindex];
    labelname.text = @"乐佰汇-保利店";
    labelBgname.text = pay.productname;
    labelDes.text = pay.productdesc;
    labelFiller.text = @"适合12-15人";
    labelPriceRoom.text = [NSString stringWithFormat:@"￥%d.00",pay.amount * 10 * 10];
    labelExCount.text = [NSString stringWithFormat:@"%d",pay.ex_people];
    labelTotalPrice.text =  [NSString stringWithFormat:@"￥%d.00",pay.amount * 10 * 10 + 1800];
    
    if (pay.paystate == 0) {
        button_pay.hidden = NO;
        button_play.hidden = YES;
    }else if (pay.paystate == 1) {
        button_pay.hidden = YES;
        button_play.hidden = NO;
    }
    
    [button_play primaryStyle];
    [button_pay sendMessageStyle];
    return cell;
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
