//
//  XCJAddNearByUsersViewController.m
//  laixin
//
//  Created by apple on 14-1-11.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAddNearByUsersViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import <CoreLocation/CoreLocation.h>
#import "XCJAddUserTableViewController.h"

@interface XCJAddNearByUsersViewController ()<CLLocationManagerDelegate,UIActionSheetDelegate>
{
    NSMutableArray * _datasource;
}


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *checkinLocation;

@end

@implementation XCJAddNearByUsersViewController

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
    NSMutableArray  * array = [[NSMutableArray alloc] init];
    _datasource = array;
    
     [SVProgressHUD showWithStatus:@"正在查找附近的人..."];
    
    [self setupLocationManager];
 
}

-(IBAction)MoreClick:(id)sender
{
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除位置信息并退出"  otherButtonTitles:@"只看帅哥",@"只看美女",@"查看全部", nil];
    [action showInView:self.view];
}

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
        
        [SVProgressHUD dismiss];
        [self showErrorText:@"请开启位置信息"];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.checkinLocation = newLocation;
    //do something else
    NSLog(@"%f",MAX(newLocation.horizontalAccuracy,self.checkinLocation.horizontalAccuracy));
    if(MAX(newLocation.horizontalAccuracy,self.checkinLocation.horizontalAccuracy) >= 20)
    {
        //
        [USER_DEFAULT setValue:[NSNumber numberWithInt:newLocation.coordinate.longitude*1e6] forKey:GlobalData_lng];
        [USER_DEFAULT setValue:[NSNumber numberWithInt:newLocation.coordinate.latitude*1e6] forKey:GlobalData_lat];
        //  [self loaddata];
        [self.locationManager stopUpdatingLocation];
        
        //        geo.user.report(lat,long) 上报当前坐标,如lat=35.233334 long=134.556743
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSDictionary * parames = @{@"lat":[NSNumber numberWithFloat:newLocation.coordinate.latitude],@"long":[NSNumber numberWithFloat:newLocation.coordinate.longitude]};
            
            [[MLNetworkingManager sharedManager] sendWithAction:@"geo.user.search" parameters:parames success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    NSDictionary * resultDict = responseObject[@"result"];
                    NSArray * array = resultDict[@"users"];
                    NSMutableArray * uidArray = [[NSMutableArray alloc] init];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [uidArray addObject:[DataHelper getStringValue:obj[@"uid"] defaultValue:@""]];
                        
                    }];
                    
                    NSDictionary * parames = @{@"uid":uidArray};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
                        // "users":[....]
                        NSDictionary * userinfo = responseObject[@"result"];
                        NSArray * userArray = userinfo[@"users"];
                        if (userArray && userArray.count > 0) {
                            [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                                [_datasource addObject:currentUser];
                                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
                                }];
                            }];
                            [self.tableView reloadData];
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                    
                    
                   
                }
                [SVProgressHUD dismiss];
            } failure:^(MLRequest *request, NSError *error) {
                [SVProgressHUD dismiss];
                [self showErrorText:@"网络请求失败"];
            }];
        });
        
    }else{
        //  [self loaddata];
    }
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
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"nearcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    LXUser * user = _datasource[indexPath.row];
    // Configure the cell...
    
    UIImageView * image = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelNick = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelLocation = (UILabel *) [cell.contentView subviewWithTag:3];
    [image setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:160]]];
    labelNick.text = user.nick;
    labelLocation.text = @"1000米以内";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXUser * currentUser = _datasource[indexPath.row];
    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
        if (response) {
            //FCUserDescription
            [SVProgressHUD dismiss];
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
//            addUser.UserInfoJson = currentUser;
            [self.navigationController pushViewController:addUser animated:YES];
        }
    }];

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
