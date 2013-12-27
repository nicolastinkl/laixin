//
//  XCJNearbyHomeViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJNearbyHomeViewController.h"

#import "XCAlbumAdditions.h"
#import "XCJSceneInfo.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "InviteInfo.h"
#import "XCJDyScenceViewController.h"
#import "XCJDomainsViewController.h"
#import "CRGradientNavigationBar.h"
#import "UIImage+ImageEffects.h"
#import "UINavigationController+MHDismissModalView.h"
#import "XCJLoginViewController.h"
#import "XCJMainLoginViewController.h"
#import "XCJAppDelegate.h"
#import "MLNetworkingManager.h"


#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]


@interface XCJNearbyHomeViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    NSMutableArray * _dataSource;
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
    NSArray * JsonArray;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *checkinLocation;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation XCJNearbyHomeViewController
@synthesize locationManager = _locationManager;
@synthesize checkinLocation = _checkinLocation;

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
    
//    [USER_DEFAULT setValue:@"f91ea9e4e0fc4460a38f645dcf8fc93a" forKey:GlobalData_user_session];
//    [USER_DEFAULT setValue:@1 forKey:GlobalData_user_id];
//    [USER_DEFAULT synchronize];
    
    //[USER_DEFAULT removeObjectForKey:GlobalData_user_session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDomainID:) name:@"Notify_changeDomainID" object:nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self // self is a UITableViewController
                       action:@selector(refreshTableView:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull To Refresh"];
    self.refreshControl = refreshControl;
    
    
//    CRGradientNavigationBar *naviBar = (CRGradientNavigationBar*)self.navigationController.navigationBar;
//    naviBar.backItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    //54A7FF
    //NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xFFFFFF).CGColor,UIColorFromRGB(0xFFFFFF).CGColor, nil];
    
    //UIColor *firstColor =  [UIColor colorWithRed:255.0f/255.0f green:42.0f/255.0f blue:104.0f/255.0f alpha:1.0f];
    //UIColor *secondColor = [UIColor colorWithRed:255.0f/255.0f green:90.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
    // NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    //    ///setup 4:
//    [naviBar setBarTintGradientColors:colors];
//    [[self.navigationController navigationBar] setTranslucent:YES];
//    [naviBar setBarTintColor:UIColorFromRGB(0xEE695D)];
    
    [self showIndicatorView];
//    NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"JsonImageurls" ofType:@"json"];
//    NSString *strJson = [NSString stringWithContentsOfFile:strFilePath encoding:NSUTF8StringEncoding error:nil];
//    NSData * jsondata = [strJson  dataUsingEncoding:NSUTF8StringEncoding];
    //JsonArray = [jsondata objectFromJSONData];
    
    if (![USER_DEFAULT objectForKey:KeyChain_Laixin_account_sessionid]) {
        [self OpenLoginview:nil];
    }else{
        [self.refreshControl beginRefreshing];
        [self setupLocationManager];
        
        // SRWebSocket * websocket =  [[MLNetworkingManager sharedManager] webSocket];
        //        SLog(@"state : %d", [websocket readyState]);
        //        NSDictionary * parames = @{@"func":@"session.start",@"parm":@{@"sessionid":sessionid}};
        NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
        NSDictionary * parames = @{@"sessionid":sessionid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
            SLog(@"responseObject :%@",responseObject);
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(uploadDataWithLogin:) name:@"MainappControllerUpdateData" object:nil];
    
    /*
      set title color and title font
     [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor], UITextAttributeTextColor,
     [UIFont boldSystemFontOfSize:16.0f], UITextAttributeFont, [UIColor darkGrayColor], UITextAttributeTextShadowColor, [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)], UITextAttributeTextShadowOffset,
     nil] forState:UIControlStateNormal];
     */
    /*
     {
     "first_signin": "1",
     "sessionid": "7e165302350e4cc58f4b094a2d467042",
     "platform": "ios",
     "access_token": "2.00pV1TBCjn1KFDb6d205521eNWd_AE",
     "version": "167",
     "weibo_user_id": "1854032365"
     }
     
     f91ea9e4e0fc4460a38f645dcf8fc93a
     */
}

-(void) uploadDataWithLogin:(NSNotification *) notify
{
    [self.refreshControl beginRefreshing];
    [self setupLocationManager];
}


-(void)changeDomainID:(NSNotification *) notify
{
    if (notify.object) {
        Nearest_areas_Info * info = (Nearest_areas_Info*)notify.object;
        [self refershCurrentScene:info.area_id];
        self.title = info.area_name;
    }
}

- (void)refreshTableView:(id)sender {
    //UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    SLog(@"Refreshing");
    [self setupLocationManager];
}

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }  
}

///获取圈子 然后获取圈子内的现场
-(void) loaddata
{
//    {"sessionid":"f57c653a8b55496db0f9abf4e8843524","wave_code":0,"offset":0,"length":10,"location":{"lat":39932130,"lng":116450980}}
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:@0  forKey:@"offset"];
    [params setValue:@1  forKey:@"length"];
    params[@"stopsync"] = @0;
    [self showIndicatorView];
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:params controller:@"domain" Action:@"domains" success:^(id obj) {
        NSArray *near_invite=[obj objectForKey:@"domains"];
        if (near_invite && near_invite.count > 0) {
            
            Nearest_areas_Info* invite=[[Nearest_areas_Info alloc] initWithJSONObject:near_invite[0]];
            if (invite) {
                self.title = invite.area_name;
                [self refershCurrentScene:invite.area_id];
            }
            [self hideIndicatorView];
        }else{
            [self hideIndicatorView:@"没有数据" block:^(SLBlock block) {
                
            }];
        
        }
        
    } error:^(NSInteger index) {
        [self hideIndicatorView:@"加载失败" block:^(SLBlock block) {
            
        }];
        NSLog(@"error .. ..");
    }];
}

-(void) refershCurrentScene:(NSInteger) sceneID
{
    [_dataSource removeAllObjects];
    [self.tableview reloadData];
    [self showIndicatorView];
    //根据圈子拿取所有现场
    NSMutableDictionary * params_two = [[NSMutableDictionary alloc] init];
    [params_two setObject:@0 forKey:@"offset"];
    [params_two setObject:@20 forKey:@"length"];
    [params_two setObject:[NSNumber numberWithInt:sceneID] forKey:@"domain_id"];
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:params_two controller:@"scene" Action:@"scenes_in_domain" success:^(id obj) {
        if([self respondsToSelector:@selector(getSubInviteListFin:)])
        {
            [self performSelector:@selector(getSubInviteListFin:) withObject:obj];
        }
    } error:^(NSInteger index) {
        [self hideIndicatorView:@"加载失败" block:^(SLBlock block) {
            
        }];
    }];
}

-(void) getSubInviteListFin:(NSMutableDictionary*)data
{
    NSMutableArray *newlist=[[NSMutableArray alloc] init];
    NSArray* list=[data objectForKey:@"list"];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Scene_Whole_info *data=[[Scene_Whole_info alloc] initWithJSONObject:obj];
        [newlist addObject:data];
    }];
    _dataSource = newlist;
    [self.tableview reloadData];
    [self.refreshControl endRefreshing];
//  PS: UIRefreshControl在完成之后会与以下代码冲突，导致位置出错。
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    self.tableview.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
//    [UIView commitAnimations];
    if (list && list.count > 0) {
        [self hideIndicatorView];
    }else{
        [self hideIndicatorView:@"没有数据" block:^(SLBlock block) {
            
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    checkinLocation = newLocation;
    //do something else
    NSLog(@"%f",MAX(newLocation.horizontalAccuracy,checkinLocation.horizontalAccuracy));
    if(MAX(newLocation.horizontalAccuracy,checkinLocation.horizontalAccuracy) >= 20)
    {
        //
        [USER_DEFAULT setValue:[NSNumber numberWithInt:newLocation.coordinate.longitude*1e6] forKey:GlobalData_lng];
        [USER_DEFAULT setValue:[NSNumber numberWithInt:newLocation.coordinate.latitude*1e6] forKey:GlobalData_lat];
        [self loaddata];
        [self.locationManager stopUpdatingLocation];

    }else{
        [self loaddata];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSUInteger row = indexPath.row;
    Scene_Whole_info * info  = _dataSource[row];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    /*JsonArray get url*/
    [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",info.sceneinfo.SceneInfo_showcase_image]] ];
//  int index = random()%121;  [imgView setImageWithURL:[NSURL URLWithString:JsonArray[index]] placeholderImage:[UIImage imageNamed:@"default_album.png"]];

    UILabel *label = (UILabel *)[cell.contentView viewWithTag:2];
    label.text = info.sceneinfo.SceneInfo_name;
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.ShowDymaic
    if ([[segue identifier] isEqualToString:@"ShowDymaic"])
    {
        XCJDyScenceViewController *vc = (XCJDyScenceViewController *)[segue destinationViewController];
         NSIndexPath *selectedIndexPath = [self.tableview indexPathForSelectedRow];
        Scene_Whole_info * info  = _dataSource[selectedIndexPath.row];
        vc.scene_id = info.sceneinfo.SceneInfo_id;
        vc.title =info.sceneinfo.SceneInfo_name;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)OpenDomains:(id)sender
{
    XCJDomainsViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJDomainsViewController"];
     UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewContr];
    viewContr.title = @"商圈";
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)OpenLoginview:(id)sender
{ 
    XCJMainLoginViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMainLoginViewController"];
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mainNavigateController pushViewController:viewContr animated:NO];
    [self presentViewController:delegate.mainNavigateController animated:NO completion:^{}];
//    [self presentViewController:viewContr animated:NO completion:nil];
}

@end
