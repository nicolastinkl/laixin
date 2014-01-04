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
#import "InviteInfo.h"

#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "XCJDyScenceViewController.h"
#import "XCJDomainsViewController.h"
#import "CRGradientNavigationBar.h"
#import "UIImage+ImageEffects.h"
#import "UINavigationController+MHDismissModalView.h"
#import "XCJLoginViewController.h"
#import "XCJMainLoginViewController.h"
#import "XCJAppDelegate.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "Sequencer.h"
#import "LXChatDBStoreManager.h"
#import "XCJLoginNaviController.h"
#import "UIView+Additon.h"
#import "XCJGroupPost_list.h"
#import "XCJHomeMenuView.h"
#import "XCJHomeDynamicViewController.h"
#import "XCJCreateNaviController.h"
#import "XCJAddFriendNaviController.h"

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]

@interface XCJNearbyHomeViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,XCJHomeMenuViewDelegate>
{
    NSMutableArray * _dataSource;
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
    NSArray * JsonArray;
    NSString * Currentgid;
    XCJHomeMenuView * menuView;
    int tryCatchCount;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *ShowMenubutton;
@property (strong, nonatomic) CLLocation *checkinLocation;
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

- (IBAction)ShowMenuClick:(id)sender {
    
    if (!menuView) {
        menuView = [[NSBundle mainBundle] loadNibNamed:@"XCJHomeMenuView" owner:self options:nil][0];
        [self.view addSubview:menuView];
        menuView.alpha = 0;
        menuView.top = -600;
        menuView.delegate =  self;
    }
    
    if (menuView.top == 0) {
        // hidden  _arrowImageView.transform = CGAffineTransformMakeRotation( M_PI);
        
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 0;
            menuView.top = -600;
            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL finished) {
        }];
    }else{
        // show
        menuView.alpha = 0;
        menuView.top = -600;
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 1;
            menuView.top = 0;
            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
        }];
        
    }
}

- (void) hiddenSelfViewClick;
{
    [self ShowMenuClick:nil];
}

- (void) createGroupClick
{
    XCJCreateNaviController * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCreateNaviController"];
            [self presentViewController:navi animated:YES completion:^{
            [self ShowMenuClick:nil];
    }];
    
}

- (void) addFriendClick
{
    XCJAddFriendNaviController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddFriendNaviController"];
    [self presentViewController:navi animated:YES completion:^{
        [self ShowMenuClick:nil];
    }];
}

- (void) findandfindCodeClick
{
    [self ShowMenuClick:nil];
}

SINGLETON_GCD(XCJNearbyHomeViewController)

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _dataSource = array;
    // Uncomment the following line to preserve selection between presentations.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDomainID:) name:@"Notify_changeDomainID" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(uploadDataWithLogin:) name:@"MainappControllerUpdateData" object:nil];
    
    tryCatchCount = 0;
    if (![USER_DEFAULT objectForKey:KeyChain_Laixin_account_sessionid]) {
        [self OpenLoginview:nil];
    }else{
        [self initHomeData];
        [self.tableView showIndicatorViewLargeBlue];
    }
    
    /**
     
     
     //    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
     //    [refreshControl addTarget:self // self is a UITableViewController
     //                       action:@selector(refreshTableView:)
     //             forControlEvents:UIControlEventValueChanged];
     //    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull To Refresh"];
     //    self.refreshControl = refreshControl;
     
     *  16 group.create(name,board,type) 创建群
        Result={“gid”:1}
     */
//    NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
//    NSDictionary * parames = @{@"name":@"乐百汇公馆",@"board":@"成都好玩的都市圈子",@"type":@1};
//    [[MLNetworkingManager sharedManager] sendWithAction:@"group.create"  parameters:parames success:^(MLRequest *request, id responseObject) {
//        
//    } failure:^(MLRequest *request, NSError *error) {
//    }];
    

}
-(void)   initHomeData
{
//    [self.refreshControl beginRefreshing];
//    [self setupLocationManager];
    
    NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
    NSDictionary * parames = @{@"sessionid":sessionid};
    [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //首次登陆返回的用户信息
        NSDictionary * userinfo = responseObject[@"result"];
        LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
        [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
        
        int userid =  [[tools getStringValue:userinfo[@"uid"] defaultValue:@""] intValue];
        [USER_DEFAULT setInteger:userid forKey:KeyChain_Laixin_account_user_id];
        [USER_DEFAULT synchronize];
        [self  reLoadData]; // load data
        [self runSequucer];
        tryCatchCount = 4;
    } failure:^(MLRequest *request, NSError *error) {
//         re request login
         tryCatchCount ++ ;
        if (tryCatchCount <= 2) {
            [self initHomeData];
        }

    }];
}

- (void ) reLoadData
{
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
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
                        [self.tableView reloadData];
                        [self.tableView hideIndicatorViewBlueOrGary];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            [self.tableView reloadData];
            [self.tableView hideIndicatorViewBlueOrGary];
        }];
    });
}

-(void) runSequucer
{
//    Sequencer *sequencer = [[Sequencer alloc] init];
//    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
////        NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
//        
//    }];
//    
//    [sequencer run];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([LXAPIController sharedLXAPIController].currentUser.uid ) {
            NSDictionary * parames = @{@"uid":[LXAPIController sharedLXAPIController].currentUser.uid,@"pos":@0,@"count":@100};
            [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_list" parameters:parames success:^(MLRequest *request, id responseObject) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                NSArray * friends = responseObject[@"result"][@"friend_id"];
                NSMutableArray * arrayIDS = [[NSMutableArray alloc] init];
                [friends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [arrayIDS addObject: [tools getStringValue:[obj objectForKey:@"uid"] defaultValue:@""]];
                }];
                if (arrayIDS.count > 0) {
                    NSDictionary * parameIDS = @{@"uid":arrayIDS};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parameIDS success:^(MLRequest *request, id responseObject) {
                        // "users":[....]
                        NSDictionary * userinfo = responseObject[@"result"];
                        NSArray * userArray = userinfo[@"users"];
                        [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            LXUser * luser = [[LXUser alloc] initWithDict:obj];
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFriendsObject:luser];
                        }];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                }
                
                // [[[LXAPIController sharedLXAPIController] chatDataStoreManager] differenceOfFriendsIdWithNewConversation:friends withCompletion:^(id response, NSError * error) {        }];
                
                
            } failure:^(MLRequest *request, NSError *error) {
                
            }];
        }
        

    });
    
//    
//    NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
//    NSDictionary * parames = @{@"uid":userid,@"pos":@0,@"count":@100};
//    [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_list" parameters:parames success:^(MLRequest *request, id responseObject) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//        
//        
//    } failure:^(MLRequest *request, NSError *error) {
//        
//    }];
}

-(void) uploadDataWithLogin:(NSNotification *) notify
{
    [self initHomeData];
}


-(void)changeDomainID:(NSNotification *) notify
{
    if (notify.object) {
        XCJGroup_list * info = (XCJGroup_list*)notify.object;
        [_dataSource addObject:info];
        [self.tableView reloadData];
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
    [self.tableView reloadData];
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
    [self.tableView reloadData];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_dataSource.count > 0) {
        return @"我加入的群组";
    }
    return  @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSUInteger row = indexPath.row;
    XCJGroup_list * info  = _dataSource[row];
//    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:2];
    label.text = info.group_name;
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
    if ([[segue identifier] isEqualToString:@"showDynamic"])
    {
        XCJHomeDynamicViewController *vc = (XCJHomeDynamicViewController *)[segue destinationViewController];
         NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        XCJGroup_list * info  = _dataSource[selectedIndexPath.row];
        vc.Currentgid = info.gid;
        vc.title =info.group_name;
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
    UINavigationController * XCJLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"XCJLoginNaviController"];
    //XCJMainLoginViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMainLoginViewController"];
   // XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;

//    [delegate.mainNavigateController pushViewController:viewContr animated:NO];
//    [self presentViewController:delegate.mainNavigateController animated:NO completion:^{}];
    [self presentViewController:XCJLoginNaviController animated:NO completion:nil];
}

@end
