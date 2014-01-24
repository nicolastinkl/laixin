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
#import "FCHomeGroupMsg.h"
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
#import "FDStatusBarNotifierView.h"
#import "XCJErWeiCodeViewController.h"
#import "XCJScanViewController.h"
#import "CoreData+MagicalRecord.h"
#import "ConverReply.h"
#import "XCJMessageReplylistController.h"
#import "FCAccount.h"
#import "MTAnimatedLabel.h"

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]

@interface XCJNearbyHomeViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,XCJHomeMenuViewDelegate,NSFetchedResultsControllerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
    NSArray * JsonArray;
    NSString * Currentgid;
    XCJHomeMenuView * menuView;
    int tryCatchCount;
    FDStatusBarNotifierView *notifierView ;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *ShowMenubutton;
@property (strong, nonatomic) CLLocation *checkinLocation;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)showRecipe:(FCHomeGroupMsg *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation XCJNearbyHomeViewController
@synthesize locationManager = _locationManager;
@synthesize checkinLocation = _checkinLocation;
@synthesize fetchedResultsController = _fetchedResultsController;
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
        [self.view.window addSubview:menuView];
        menuView.alpha = 0;
        menuView.top = -600;
        menuView.delegate =  self;
        float blurred = .5f;
        menuView.Image_bg.alpha = .95f;
        UIImage *blurredImage = [menuView.Image_bg.image blurredImage:blurred];
        menuView.Image_bg.image = blurredImage;
    }
    
    if (menuView.top == 0) {
        // hidden  _arrowImageView.transform = CGAffineTransformMakeRotation( M_PI);
        
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 0;
            menuView.top = -600;
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
        }];
    }else{
        // show
        [self.tableView scrollsToTop];
        menuView.alpha = 0;
        menuView.top = -600;
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 1;
            menuView.top = 0;
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(M_PI/2);
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
      [self ShowMenuClick:nil];
    XCJCreateNaviController * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCreateNaviController"];
            [self presentViewController:navi animated:YES completion:^{
          
    }];
    
}

- (void) addFriendClick
{
    [self ShowMenuClick:nil];
    XCJAddFriendNaviController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddFriendNaviController"];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void) findandfindCodeClick
{
    [self ShowMenuClick:nil];
    // go to erwei code
    XCJScanViewController * view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJScanViewController"];
    view.scanTypeIndex = findAll;
    [self.navigationController pushViewController:view
                                         animated:YES];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:@"刷新在线时间"];
    
    // Uncomment the following line to preserve selection between presentations.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.automaticallyAdjustsScrollViewInsets = NO;

    // observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HomeReloadFetchedResults:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDomainID:) name:@"Notify_changeDomainID" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(uploadDataWithLogin:) name:@"MainappControllerUpdateData" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(MainappControllerUpdateDataReplyMessage:) name:@"MainappControllerUpdateDataReplyMessage" object:nil];
   
    
    /**
     *  title消息 切换
     *
     *  @param webSocketdidFailWithError: <#webSocketdidFailWithError: description#>
     *
     *  @return <#return value description#>
     */
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidFailWithError:) name:@"webSocketdidFailWithError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketDidOpen:) name:@"webSocketDidOpen" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidreceingWithMsg:) name:@"webSocketdidreceingWithMsg" object:nil];
    
    
    tryCatchCount = 0;
    
    ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:21]).height = 0.3f;
    
    ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:5]).textColor = [tools colorWithIndex:0];
    ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:5]).text = @"查看消息列表";
    
    if (![XCJAppDelegate hasLogin]) {
        [self OpenLoginview:nil];
    }else{
        [self.tableView showIndicatorViewLargeBlue];
        
        [self initHomeData];
    }
    
}

-(void) webSocketDidOpen:(NSNotification * ) noty
{
    self.title = @"来信";
    [self.navigationItem.titleView sizeToFit];
    [self.tableView hideIndicatorViewBlueOrGary];
    
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UITabBarItem  *item = delegate.tabBarController.tabBar.items[0] ;
    //    item.title = @"";
    UIView * view = [item valueForKey:@"view"];
    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [self stopAnimation:obj];
        }
    }];
    
}

-(void) webSocketdidFailWithError:(NSNotification * ) noty
{
    self.title = @"来信(未连接)";
    [self.navigationItem.titleView sizeToFit];
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UITabBarItem  *item = delegate.tabBarController.tabBar.items[0] ;
    //    item.title = @"";
    UIView * view = [item valueForKey:@"view"];
    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [self stopAnimation:obj];
        }
    }];
}

-(void) webSocketdidreceingWithMsg:(NSNotification * ) noty
{
    self.title = @"来信(收取中...)";
    
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UITabBarItem  *item = delegate.tabBarController.tabBar.items[0] ;
//    item.title = @"";
     UIView * view = [item valueForKey:@"view"];
    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [self startAnimation:obj];
        }
    }];

    
    [self.navigationItem.titleView sizeToFit];
}

- (void)startAnimation:(UIView *)button{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];///* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    
    [button.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation:(UIView *) indicator{
    
    if (indicator) {
        [indicator.layer removeAllAnimations];
//        indicator.hidden = YES;
//        [indicator removeFromSuperview];
//        indicator = nil;
    }
}



-(void) MainappControllerUpdateDataReplyMessage:(NSNotification * ) noty
{
    NSPredicate * pre = [NSPredicate predicateWithFormat:@" badgeNumber > %@",@"0"];
    
    ConverReply * contr =   [ConverReply MR_findFirstWithPredicate:pre];
    
    UITabBar *tabBar =(UITabBar*) [self.tableView.tableHeaderView viewWithTag:12];
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if (![strClassName isEqualToString:@"_UIBadgeView"]) {
                [subview removeFromSuperview];
            }
        }
    }
    
//    UIButton * button = (UIButton *) [self.tableView.tableHeaderView subviewWithTag:1];
    if (contr) {
        if ([contr.content containString:@"评论"]) {
//           [button setTitle:@"新评论" forState:UIControlStateNormal];
            ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:5]).text = @"查看新评论";
        }else{
//           [button setTitle:@"新赞" forState:UIControlStateNormal];
            ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:5]).text = @"查看新赞";
        }
         if ([contr.badgeNumber intValue ] > 0) {
              [tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%@",contr.badgeNumber]];
         }else{
             [tabBar.items[0] setBadgeValue:nil];
         }
    }else{
//        [button setTitle:@"查看消息列表" forState:UIControlStateNormal];
        ((UILabel *)[self.tableView.tableHeaderView subviewWithTag:5]).text = @"查看消息列表";
        [tabBar.items[0] setBadgeValue:nil];
    }
    
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    {
        [delegate.tabBarController.tabBar.items[0] setBadgeValue:nil];
    }
    
    /*
     if (contr) {
     UIButton * button = (UIButton *) [self.tableView.tableHeaderView subviewWithTag:1];
     UIImage *originalImage = [UIImage imageNamed:@"fbc_specialbutton_28_3_3_3_3_normal_ios7"];
     UIEdgeInsets insets = UIEdgeInsetsMake(3,3,3,3);
     UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
     [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
     
     
     if ([contr.content containString:@"评论"]) {
     [button setImage:[UIImage imageNamed:@"ufi-overlay-comment"] forState:UIControlStateNormal];
     }else{
     [button setImage:[UIImage imageNamed:@"ufi-overlay-liked"] forState:UIControlStateNormal];
     }
     
     if ([contr.badgeNumber intValue ] > 0) {
     [button setTitle: [NSString stringWithFormat:@"%@(%@)",contr.content,contr.badgeNumber] forState:UIControlStateNormal];
     }else{
     [button setTitle: contr.content forState:UIControlStateNormal];
     }
     [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     }else{
     
     UIButton * button = (UIButton *) [self.tableView.tableHeaderView subviewWithTag:1];
     UIImage *originalImage = [UIImage imageNamed:@"fbc_regularbutton_28_3_3_3_3_normal_ios7"];
     UIEdgeInsets insets = UIEdgeInsetsMake(3,3,3,3);
     UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
     [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
     [button setTitle:@"查看消息列表" forState:UIControlStateNormal];
     [button setImage:nil forState:UIControlStateNormal];
     [button setTitleColor:ios7BlueColor forState:UIControlStateNormal];
     }
     */
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self MainappControllerUpdateDataReplyMessage:nil];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        /*
         http://stackoverflow.com/questions/14690681/nsfetchedresultschangeupdate-fired-instead-of-nsfetchedresultschangedelete#new-answer
         
         If I update this property to [NSNumber numberWithBool:YES] the NSFetchedResultsControllerDelegate calls didChangeObject but firing NSFetchedResultsChangeUpdate instead of NSFetchedResultsChangeDelete.
         
     MARK:     [NSPredicate predicateWithFormat:@" gType = 1"];  get error
         
         */
        
        NSPredicate * parCMD = [NSPredicate predicateWithFormat:@" gType == %@ ",@"1"];
        self.fetchedResultsController = [FCHomeGroupMsg MR_fetchAllSortedBy:@"gbadgeNumber" ascending:NO withPredicate:parCMD groupBy:nil delegate:self]; //@"gbadgeNumber"
    }
	return _fetchedResultsController;
}

// clean up our new observers
- (void)viewDidUnload {
    self.fetchedResultsController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - fetchedResultsController
#pragma mark UIViewController overrides

// because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
// we will see the NSManagedObjectContext set up before any persistent stores are registered
// we will need to fetch again after the persistent store is loaded
- (void)HomeReloadFetchedResults:(NSNotification*)note {
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    if (note) {
        [self.tableView reloadData];
    }
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
#pragma mark  NSFetchedResultsController to respond to additions, removals and so on.
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    // select all unread bradge number
    
    NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"gbadgeNumber > %d",0];
    NSInteger  inter =  [FCHomeGroupMsg MR_countOfEntitiesWithPredicate:preCMD];
    
    XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
    if (inter > 0) {
        [delegate.tabBarController.tabBar.items[0] setBadgeValue:@"新"];
    }else{
        [delegate.tabBarController.tabBar.items[0] setBadgeValue:nil];
    }
    
    
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case NSFetchedResultsChangeUpdate:
        {
        
			[self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
           
        }
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark - table fetchview

- (void)showRecipe:(FCHomeGroupMsg *) info animated:(BOOL)animated
{
    XCJHomeDynamicViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJHomeDynamicViewController"];
    vc.Currentgid = info.gid;
    vc.title = info.gName;
    vc.groupInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FCHomeGroupMsg *info = (FCHomeGroupMsg *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:3];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:2];
    label.text = info.gName;
    
    label.textColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"med-name-bg-0"]];
//    [label stopAnimating]; //MTAnimatedLabel
//    [label startAnimating];
    if ([info.gbadgeNumber intValue] > 0)
        imgView.hidden = NO;
    else
        imgView.hidden = YES;
    
    UIImageView *imgViewMute = (UIImageView *)[cell.contentView viewWithTag:4];
    if ([info.isMute boolValue])
        imgViewMute.hidden = NO;
    else
        imgViewMute.hidden = YES;
}

-(void) showErrorInfoWithRetryNot:(NSNotification * ) notify
{
    [self hiddeErrorInfoWithRetry];
    // start retry
    [self.tableView showIndicatorViewLargeBlue];
    [self reLoadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:showErrorInfoWithRetryNotifition object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition object:nil];
    
    if ([self.tableView isIndicatorViewLargeBlueRunning]) {
        [self.tableView showIndicatorViewLargeBlue];
    }
}

-(void)   initHomeData
{
//    [self.refreshControl beginRefreshing];
    [self setupLocationManager];
    
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext]; //init DB context
    [self HomeReloadFetchedResults:nil];
    
    NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
    NSDictionary * parames = @{@"sessionid":sessionid};
    [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //首次登陆返回的用户信息
        NSDictionary * userinfo = responseObject[@"result"];
        LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
        [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
        
        [USER_DEFAULT setValue:currentUser.uid forKey:KeyChain_Laixin_account_user_id];
        [USER_DEFAULT setObject:currentUser.nick forKey:KeyChain_Laixin_account_user_nick];
        [USER_DEFAULT setObject:currentUser.headpic forKey:KeyChain_Laixin_account_user_headpic];
        [USER_DEFAULT setObject:currentUser.signature forKey:KeyChain_Laixin_account_user_signature];
        [USER_DEFAULT setObject:currentUser.position forKey:KeyChain_Laixin_account_user_position];
        [USER_DEFAULT synchronize];
        
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:LaixinSetupDBMessageNotification object:currentUser.uid]; // setup db
            
        }
        
        NSPredicate * pres = [NSPredicate predicateWithFormat:@"facebookId == %@",currentUser.uid];
        FCAccount * account = [FCAccount MR_findFirstWithPredicate:pres];
        NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
        if (account == nil) {
            account = [FCAccount MR_createInContext:localContext];
            account.facebookId = currentUser.uid;
        }
        account.sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
        account.websocketURL = [USER_DEFAULT stringForKey:KeyChain_Laixin_systemconfig_websocketURL];
        account.time = @"";
        account.userJson = userinfo;
        [localContext MR_saveToPersistentStoreAndWait];
//        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
        
        // Return the number of rows in the section.
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            // find
//            [_dataSource addObjectsFromArray:array];
//            [self.tableView reloadData];
            [self.tableView hideIndicatorViewBlueOrGary];
            
        }else{
            [self  reLoadData]; // load data
        }
        [self runSequucer];
        
        tryCatchCount = 4;
    } failure:^(MLRequest *request, NSError *error) {
//         re request login
         tryCatchCount ++ ;
          [self.tableView hideIndicatorViewBlueOrGary];
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
                    /*  add group */
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
                            // Build the predicate to find the person sought
                            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                            FCHomeGroupMsg * msg = [FCHomeGroupMsg MR_createInContext:localContext];
                            msg.gid = list.gid;
                            msg.gCreatorUid = list.creator;
                            msg.gName = list.group_name;
                            msg.gBoard = list.group_board;
                            msg.gDate = [NSDate dateWithTimeIntervalSinceNow:list.time];
                            msg.gbadgeNumber = @0;
                            msg.gType = [NSString stringWithFormat:@"%d",list.type];
                            [localContext MR_saveToPersistentStoreAndWait];
                        }];
//                        [self HomeReloadFetchedResults:nil];
//                        [self.tableView reloadData];
                        [self.tableView hideIndicatorViewBlueOrGary];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                }else{
                    [self.view hideIndicatorViewBlueOrGary];
                    // no one more
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
//             [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:@"群组获取失败 请点击重试"];
//            [self.tableView reloadData];
            [self.view hideIndicatorViewBlueOrGary];
            [self showErrorInfoWithRetry];
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
    double delayInSeconds = 1.0;
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
                        
                        // [[[LXAPIController sharedLXAPIController] chatDataStoreManager] differenceOfFriendsIdWithNewConversation:friends withCompletion:^(id response, NSError * error) {        }];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                }
            } failure:^(MLRequest *request, NSError *error) {
            }];
            
            NSString * _devtokenstring =[USER_DEFAULT stringForKey:KeyChain_Laixin_account_devtokenstring];
            //1 debug    ....   0 release
            if (_devtokenstring) {
                
                NSDictionary * paramesss = @{@"device_token":_devtokenstring,@"is_debug":@(NEED_OUTPUT_LOG)};
                [[MLNetworkingManager sharedManager] sendWithAction:@"ios.reg"  parameters:paramesss success:^(MLRequest *request, id responseObject) {
                } failure:^(MLRequest *request, NSError *error) {
                }];
            }
        }
    });
}



-(void) uploadDataWithLogin:(NSNotification *) notify
{
    [self initHomeData];  // get all data
    [self.tableView showIndicatorViewLargeBlue];
}

-(void)changeDomainID:(NSNotification *) notify
{
    if (notify.object) {
        [self hiddeErrorInfoWithRetry];

        FCHomeGroupMsg * list = (FCHomeGroupMsg*)notify.object;
        if (list) {
//            [self HomeReloadFetchedResults:nil];
//            [self.tableView reloadData];
//            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
//            [self reloadFetchedResults:nil];
            // Build the predicate to find the person sought
//            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
//            FCHomeGroupMsg * msg = [FCHomeGroupMsg MR_createInContext:localContext];
//            msg.gid = list.gid;
//            msg.gCreatorUid = list.creator;
//            msg.gName = list.group_name;
//            msg.gBoard = list.group_board ;
//            msg.gDate = [NSDate dateWithTimeIntervalSinceNow:list.time];
//            msg.gbadgeNumber = @1;
//            msg.gType = @"1";
//            [localContext MR_saveOnlySelfAndWait];
        }
    }
}

- (void)refreshTableView:(id)sender {
    //UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    SLLog(@"Refreshing");
    [self setupLocationManager];
}

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        SLLog( @"Starting CLLocationManager" );
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    } else {
        SLLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
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
      //  [self loaddata];
        [self.locationManager stopUpdatingLocation];
        
//        geo.user.report(lat,long) 上报当前坐标,如lat=35.233334 long=134.556743
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSDictionary * parames = @{@"lat":[NSNumber numberWithFloat:newLocation.coordinate.latitude],@"long":[NSNumber numberWithFloat:newLocation.coordinate.longitude]};
            [[MLNetworkingManager sharedManager] sendWithAction:@"geo.user.report" parameters:parames success:^(MLRequest *request, id responseObject) {
                
            } failure:^(MLRequest *request, NSError *error) {
                
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
    NSInteger count = [[self.fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    if (numberOfRows > 0) {
        return  @"我加入的群组";
    }
    return @"";

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.ShowDymaic
    /* NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
     FCHomeGroupMsg * info   = _dataSource[selectedIndexPath.row];
     vc.Currentgid = info.gid;
     vc.title =info.gName;
     if ([info.gbadgeNumber intValue] > 0) {
     info.gbadgeNumber = @0;
     [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
     }
     info.gbadgeNumber = @0;*/
//    if ([[segue identifier] isEqualToString:@"ShowMessageList"])
//    {
//        XCJMessageReplylistController *vc = (XCJMessageReplylistController *)[segue destinationViewController];
//        
//    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FCHomeGroupMsg *recipe = (FCHomeGroupMsg *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
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
