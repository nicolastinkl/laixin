//
//  XCJPayListCardController.m
//  laixin
//
//  Created by tinkl on 23/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJPayListCardController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "UIAlertView+Blocks.h"
 #include "OpenUDID.h"
#import "DZWebBrowser.h"
#import "UINavigationSample.h"

@interface XCJPayListCardController ()
{
    NSMutableArray * _datascoures;
}
@end

@implementation XCJPayListCardController

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
    self.title = @"我的银行卡";
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _datascoures = array;
    
    UIButton * button =(UIButton *)[self.tableView.tableFooterView subviewWithTag:1];
    [button infoStyle];
    [button addTarget:self action:@selector(addBankCard:) forControlEvents:UIControlEventTouchUpInside];
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.cards" parameters:@{} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * reultDict = responseObject[@"result"];
            NSArray * array = reultDict[@"cards"];
            if (array && array.count > 0) {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [_datascoures addObject:obj];
                }];
            }else{
                
            }
            [self.tableView reloadData];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"网络请求失败,请检查网络设置"];
    }];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(IBAction)addBankCard:(id)sender
{
    [self SurePayClick:@"merchandise.createorder" withCardid:nil];
}

//确认支付
-(void) SurePayClick:(NSString * )action withCardid:(NSString * ) cardid
{    
    NSString* openUDID = [OpenUDID value];
    [SVProgressHUD showWithStatus:@"正在处理..."];
    NSDictionary * dict;
    //mid 23  绑定银行卡
    dict = @{@"mid":@(23),@"people_count":@(0),@"hardwareid":openUDID};
    
    [[MLNetworkingManager sharedManager] sendWithAction:action parameters:dict success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            int errnoMesg = [DataHelper getIntegerValue:responseObject[@"errno"] defaultValue:0];
            if (errnoMesg == 0) {
                [SVProgressHUD dismiss];
           
                NSDictionary * dict = responseObject[@"result"];
                NSString * string   = [DataHelper getStringValue: dict[@"gourl"] defaultValue:@""];
                if (string.length > 0) {
                    
                    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:[NSURL URLWithString:string]];
                    webBrowser.showProgress = YES;
                    webBrowser.allowSharing = YES;
                    UINavigationSample *webBrowserNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationSample"];
                    [webBrowserNC pushViewController:webBrowser animated:NO];
                    [self presentViewController:webBrowserNC animated:YES completion:NULL];
                    
                }
            }
        }
    } failure:^(MLRequest *request, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView showAlertViewWithMessage:@"处理失败"];
        
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
    return _datascoures.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"payCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary* obj = _datascoures[indexPath.section];
    UILabel * label_name =  (UILabel *)[cell.contentView subviewWithTag:1];
    UILabel * label_payinfo =  (UILabel *)[cell.contentView subviewWithTag:2];
    NSString * cardName = [DataHelper getStringValue:obj[@"card_name"] defaultValue:@""];
    NSString * cardNumberlast = [DataHelper getStringValue:obj[@"card_last"] defaultValue:@""];
    label_name.text = cardName;
    label_payinfo.text = [NSString stringWithFormat:@"尾号%@",cardNumberlast];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* obj = _datascoures[indexPath.section];
    NSString * cardid = [DataHelper getStringValue:obj[@"cardid"] defaultValue:@""];
    [[[UIAlertView alloc] initWithTitle:@"是否解绑银行卡" message:@"" cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"] otherButtonItems:[RIButtonItem itemWithLabel:@"解绑" action:^{
        [SVProgressHUD showWithStatus:@"正在解绑"];
        [[MLNetworkingManager sharedManager] sendWithAction:@"merchandise.unbind" parameters:@{@"cardid":cardid} success:^(MLRequest *request, id responseObject) {
            [_datascoures removeObject:obj];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"解绑失败，请重新操作"];
        }];
    }], nil] show];
    
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
