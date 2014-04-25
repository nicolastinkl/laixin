//
//  XCJDomainsViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-18.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJDomainsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DAImageResizedImageView.h"
#import "UIViewController+Indicator.h"
#import "UIAlertView+AFNetworking.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "XCJGroupPost_list.h"


@interface XCJDomainsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * _dataSource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation XCJDomainsViewController

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
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _dataSource = array;
	// Do any additional setup after loading the view.
    [self.navigationController installMHDismissModalViewWithOptions:[[MHDismissModalViewOptions alloc] initWithScrollView:self.tableview theme:MHModalThemeWhite]];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    [self reload:nil];
}


- (void)reload:(id)sender
{
    [_dataSource removeAllObjects];
    [self.tableview reloadData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    /**
     *  gid,content
     */
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.my"  parameters:@{} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * groups = responseObject[@"result"];
            NSArray * groupsDict =  groups[@"groups"];
            NSMutableArray * array = [[NSMutableArray alloc] init];
            [groupsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                /*  add group
                 
                 “gid”:
                 “type”:
                 “time”:
                 
                 */
                NSString * str = [tools getStringValue:obj[@"gid"] defaultValue:@""];
                [array addObject:str];
            }];
            if (array.count > 0) {
                //group.info (gid<群id或者id数组>)
                NSDictionary * paramess = @{@"gid":array};
                [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                    NSDictionary * groupsss = responseObjects[@"result"];
                    NSArray * groupsDicts =  groupsss[@"groups"];
                    [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                        [_dataSource addObject:list];
                    }];
                    [self.tableview reloadData];
                } failure:^(MLRequest *request, NSError *error) {
                }];
            }
        }
       

    } failure:^(MLRequest *request, NSError *error) {
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DomainsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSUInteger row = indexPath.row;
    XCJGroup_list * info  = _dataSource[row];
    DAImageResizedImageView *image = (DAImageResizedImageView*)[cell.contentView viewWithTag:1];
    NSString * strUrl;
    switch (row) {
        case 0:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_11_24_6de00b934e71fc73a32f19e5031ba578.jpg?imageView/2/w/960/q/85";
            break;
        case 1:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_10_11_ed358cca1012f077ee89e90da9c5b8e8.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 2:
            strUrl  = @"http://breadtripimages.qiniudn.com/photo_2013_07_22_ae40a8c7b07988c19ad8ec6c6fc5876d.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 3:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_11_23_c35904196bacca56091f261b245f1491.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 4:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_10_11_ed358cca1012f077ee89e90da9c5b8e8.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 5:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_10_11_ed358cca1012f077ee89e90da9c5b8e8.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 6:
            strUrl = @"http://media.breadtrip.com/photos/2013/02/10/5b4cd8bc68fd765e9ca9e68313c8030f.jpg";
            break;
        case 7:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_10_03_b1d71dc78f28d120c983dfae13fc8140.jpg?imageView/1/w/640/h/480/q/85";
            break;
        case 8:
            strUrl = @"http://media.breadtrip.com/photos/2013/06/16/101c80eb156d11d5ef9b6c7cef623bc8.jpg";
            break;
        case 9:
            strUrl = @"http://media.breadtrip.com/photos/2013/03/29/aa92866e13f76d0bcc5198330c28c457.jpg";
            break;
        default:
            strUrl = @"http://breadtripimages.qiniudn.com/photo_2013_09_25_75f0413a221ad8a5a28804ca757681cd.jpg?imageView/1/w/640/h/480/q/75";
            break;
    }
    [image setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",strUrl]] placeholderImage:nil];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:2];
    label.text = info.group_name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    XCJGroup_list * info  = _dataSource[row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_changeDomainID" object:info];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
