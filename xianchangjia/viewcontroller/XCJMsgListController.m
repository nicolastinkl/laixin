//
//  XCJFriendViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//
#import "XCJMsgListController.h"
#import "XCAlbumAdditions.h"
#import "UserInfo.h"
#import "UIAlertView+AFNetworking.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "DAImageResizedImageView.h"
#import "XCJUserViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MLNetworkingManager.h"
#import "XCJAddressBook.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "FCAccount.h"
#import "FCUserDescription.h"
#import "CoreData+MagicalRecord.h"
#import "XCJUserInfoController.h"
#import "Conversation.h"
#import "FCMessage.h"
#import "LXRequestFacebookManager.h"
#import "ChatViewController.h"
#import "CoreData+MagicalRecord.h"
#import "XCJAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FCHomeGroupMsg.h"
#import "XCJHomeDynamicViewController.h"
#import "XCJGroupPost_list.h"
#import "XCJHomeMenuView.h"
#import "XCJCreateNaviController.h"
#import "XCJAddFriendNaviController.h"
#import "XCJScanViewController.h"
#import "FCFriends.h"
#import "BundleHelper.h"

@interface XCJMsgListController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,XCJHomeMenuViewDelegate>//,UISearchDisplayDelegate,UISearchBarDelegate
{
    int tryCatchCount;
    XCJHomeMenuView * menuView;
    NSArray *allItems;
    
}

@property (nonatomic, copy) NSArray *allReslutItems;

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)showRecipe:(Conversation *) friend animated:(BOOL)animated;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation XCJMsgListController
@synthesize allReslutItems;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController overrides

// because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
// we will see the NSManagedObjectContext set up before any persistent stores are registered
// we will need to fetch again after the persistent store is loaded
- (void)reloadFetchedResults:(NSNotification*)note {
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		SLLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    if (note) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
 
    self.allReslutItems = @[];
    
    // observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefetchAllDatabaseDataConver" object:[[UIApplication sharedApplication] delegate]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(uploadDataWithLogin:) name:@"MainappControllerUpdateData" object:nil];
    
    
    /*NSInteger numberOfRows = 0;
     // Return the number of rows in the section.
     if ([[self.fetchedResultsController sections] count] > 0) {
     id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
     numberOfRows = [sectionInfo numberOfObjects];
     }
     
     if (numberOfRows <= 0) {
     // show info
     [self showErrorText:@"暂时还没有消息"];
     }else{
     [self hiddeErrorText];
     }*/
    
    // The search bar is hidden when the view becomes visible the first time
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchDisplayController.searchBar.bounds));
    // title消息 切换
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidFailWithError:) name:@"webSocketdidFailWithError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketDidOpen:) name:@"webSocketDidOpen" object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(webSocketdidreceingWithMsg:) name:@"webSocketdidreceingWithMsg" object:nil];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![XCJAppDelegate hasLogin]) {
            [self OpenLoginview:nil];
        }else{
            [self initHomeData];
        }
    });
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchbar.frame animated:animated];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.searchbar isFirstResponder]) {
        [self.searchbar resignFirstResponder];
    }

}
#pragma mark – UISearchDisplayController delegate methods
//- (void)filterContentForSearchText:(NSString*)searchText {
////    NSMutableArray * array = [[NSMutableArray alloc] init];
//    self.allReslutItems = [Conversation MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"lastMessage  like[cd] '%@'",[NSString localizedStringWithFormat:@"*%@*",searchText]]];
////     self.allReslutItems = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText]];
//    //[self.tableView reloadData];
//}
//
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//     [self filterContentForSearchText:[self.searchDisplayController.searchBar text]                                  ];
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]                                 ];
//    
//    return YES;
//    
//}

-(void) uploadDataWithLogin:(NSNotification *) notify
{
    [self initHomeData];  // get all data
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginInReceivingAllMessage" object:nil];
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
        [menuView setButtonLayout];
        
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

-(void)   initHomeData
{
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
        [self reloadFetchedResults:nil];        
 
    NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
    NSDictionary * parames = @{@"sessionid":sessionid};
    [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //首次登陆返回的用户信息
        NSDictionary * userinfo = responseObject[@"result"];
        LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
        if (currentUser) {
            [self  webSocketDidOpen:nil];
            [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
            [USER_DEFAULT setValue:currentUser.uid forKey:KeyChain_Laixin_account_user_id];
            [USER_DEFAULT setObject:currentUser.nick forKey:KeyChain_Laixin_account_user_nick];
            [USER_DEFAULT setObject:currentUser.headpic forKey:KeyChain_Laixin_account_user_headpic];
            [USER_DEFAULT setObject:currentUser.signature forKey:KeyChain_Laixin_account_user_signature];
            [USER_DEFAULT setObject:currentUser.background_image forKey:KeyChain_Laixin_account_user_backgroupbg];
            [USER_DEFAULT setObject:currentUser.position forKey:KeyChain_Laixin_account_user_position];
            [USER_DEFAULT synchronize];
#warning account message
            /*NSPredicate * pres = [NSPredicate predicateWithFormat:@"facebookId == %@",currentUser.uid];
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
             [localContext MR_saveToPersistentStoreAndWait];*/
            //        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
            
            // Return the number of rows in the section.
//            [self  reLoadData]; // 更新群组信息
            [self  runSequucer];  //更新好友信息
            tryCatchCount = 4;
            
            NSString * _devtokenstring =[USER_DEFAULT stringForKey:KeyChain_Laixin_account_devtokenstring];
            //1 debug    ....   0 release
            if (_devtokenstring) {
                
                NSDictionary * paramesss = @{@"device_token":_devtokenstring,@"is_debug":@(NEED_OUTPUT_LOG)};
                [[MLNetworkingManager sharedManager] sendWithAction:@"ios.reg"  parameters:paramesss success:^(MLRequest *request, id responseObject) {
                } failure:^(MLRequest *request, NSError *error) {
                }];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginInReceivingAllMessage" object:nil];
            
        }
       
    } failure:^(MLRequest *request, NSError *error) {
        //         re request login
        tryCatchCount ++ ;
        [self.tableView hideIndicatorViewBlueOrGary];
        if (tryCatchCount <= 2) {
            [self initHomeData];
        }
        
    }];
}

/**
 *  获取我的群组数据
 */
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
                            if(list.type == groupsGroupTextImgShare){
                                // Build the predicate to find the person sought
                                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                // target to chat view
                                NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid]];
                                Conversation * array =  [Conversation MR_findFirstWithPredicate:pre];
                                if (!array) {
                                    // create new
                                    Conversation * conversation =  [Conversation MR_createInContext:localContext];
                                    conversation.lastMessage = list.group_board;
                                    conversation.lastMessageDate = [NSDate date];
                                    conversation.messageType = @(XCMessageActivity_UserGroupMessage);
                                    conversation.messageStutes = @(messageStutes_incoming);
                                    conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,@"0"];
                                    conversation.facebookName = list.group_name;
                                    conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,list.gid];
                                    conversation.badgeNumber = @0;
                                    [localContext MR_saveOnlySelfAndWait];
                                }else{
                                    //更新群信息
                                    if (![array.facebookName isEqualToString:list.group_name]) {
                                        array.facebookName = list.group_name;
                                        [localContext MR_saveOnlySelfAndWait];
                                    }
                                }
                            }
                            
                        }];
                    } failure:^(MLRequest *request, NSError *error) {
                    }];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            
//            [self showErrorInfoWithRetry];
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

    
    if ([[BundleHelper bundleShortVersionString] isEqualToString:@"1.2.7"]) {
        if (![USER_DEFAULT boolForKey:[BundleHelper bundleShortVersionString]]) {
            
            NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"friendID >  %@",@"0"];
            [FCFriends MR_deleteAllMatchingPredicate:pre];
            [localContext MR_saveToPersistentStoreAndWait];
        }
        
    }
    
    FCFriends * friends = [FCFriends MR_findFirst];
    if (friends == nil) {        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([LXAPIController sharedLXAPIController].currentUser.uid ) {
                NSDictionary * parames = @{@"uid":[LXAPIController sharedLXAPIController].currentUser.uid,@"pos":@0,@"count":@1000};
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_list" parameters:parames success:^(MLRequest *request, id responseObject) {
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    NSArray * friends = responseObject[@"result"][@"friend_id"];
                    NSMutableArray * arrayIDS = [[NSMutableArray alloc] init];
                    [friends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [arrayIDS addObject: [tools getStringValue:[obj objectForKey:@"uid"] defaultValue:@""]];
                    }];
                    
                    if (![arrayIDS containsObject:@"24"]) {
                        [arrayIDS addObject:@"24"];
                    }
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
                    [USER_DEFAULT setBool:YES forKey:[BundleHelper bundleShortVersionString]];
                    [USER_DEFAULT synchronize];
                } failure:^(MLRequest *request, NSError *error) {
                }];
                
                
            }
        });
    }
}


-(IBAction)OpenLoginview:(id)sender
{
    UINavigationController * XCJLoginNaviController =  [self.storyboard instantiateViewControllerWithIdentifier:@"XCJLoginNaviController"];
    [self presentViewController:XCJLoginNaviController animated:NO completion:nil];
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



#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        self.fetchedResultsController = [Conversation MR_fetchAllSortedBy:@"lastMessageDate" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    }
	return _fetchedResultsController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /* receive websocket message
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(webSocketDidReceivePushMessage:)
     name:MLNetworkingManagerDidReceivePushMessageNotification
     object:nil];
     */
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:showErrorInfoWithRetryNotifition object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    NSDictionary * MsgContent  = notification.userInfo;
    SLLog(@"MsgContent :%@",MsgContent);
    if ([MsgContent[@"push"] intValue] == 1) {
        NSString *requestKey = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        if ([requestKey isEqualToString:@"newmsg"]) {
            /*
             {"push": true, "data": {"message": {"toid": 14, "msgid": 5, "content": "\u6211\u6765\u4e86sss", "fromid": 2, "time": 1388477804.0}}, "type": "newmsg"}
             */
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"message"];
            
            NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
            
            //out view
            NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];

            // Build the predicate to find the person sought
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
            Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
            if(conversation == nil)
            {
                conversation =  [Conversation MR_createInContext:localContext];
            }
                
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            if ([content isNilOrEmpty]) {
                content = @"";
            }
            msg.text = content;
            NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            msg.sentDate = date;
            // message did come, this will be on left
            msg.messageStatus = @(YES);
            
            if (imageurl.length > 5)
            {
                msg.messageType = @(messageType_image);
                conversation.lastMessage = @"[图片]";
            }
            else
            {
                msg.messageType = @(messageType_text);
                conversation.lastMessage = content;
            }
            msg.imageUrl = imageurl;
            msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
            conversation.lastMessageDate = date;
            conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
            conversation.messageStutes = @(messageStutes_incoming);
            conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
            conversation.facebookName = @"";
            conversation.facebookId = facebookID;
            // increase badge number.
            int badgeNumber = [conversation.badgeNumber intValue];
            badgeNumber ++;
            conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
            
            [conversation addMessagesObject:msg];
            [localContext MR_saveOnlySelfAndWait];// MR_saveOnlySelfAndWait];
            
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
            
            SystemSoundID id = 1007; //声音
            AudioServicesPlaySystemSound(id);
            
        } else if([requestKey isEqualToString:@"newpost_error"]){
            
            NSDictionary * dicResult = MsgContent[@"data"];
            
            NSDictionary * dicMessage = dicResult[@"post"];
            NSString * gid = [tools getStringValue:dicMessage[@"gid"] defaultValue:@""];
            NSString * uid = [tools getStringValue:dicMessage[@"uid"] defaultValue:@""];
            NSString * facebookID = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
            
            //获取群组消息类型 然后做相关写入操作
            NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"gid == %@ ",gid];
            FCHomeGroupMsg * groupMessage = [FCHomeGroupMsg MR_findFirstWithPredicate:parCMDss];
            if ([groupMessage.gType isEqualToString: @"2"]) {
                
                if([uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
                {
                    return;
                }
                
                //out view
                NSString * content = dicMessage[@"content"];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                
                // Build the predicate to find the person sought
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookID];
                Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
                if(conversation == nil)
                {
                    conversation =  [Conversation MR_createInContext:localContext];
                }
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                msg.sentDate = date;
                if (imageurl.length > 5)
                {
                    msg.messageType = @(messageType_image);
                    conversation.lastMessage = @"[图片]";
                }
                else
                {
                    msg.messageType = @(messageType_text);
                    conversation.lastMessage = content;
                }
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                msg.messageId = [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                    if (response) {
                        
                        FCUserDescription * localdespObject = response;
                        conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
                    }
                } withuid:uid];
                conversation.lastMessageDate = date;
                conversation.messageStutes = @(messageStutes_incoming);
                // increase badge number.
                int badgeNumber = [conversation.badgeNumber intValue];
                badgeNumber ++;
                conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                
                [conversation addMessagesObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
                [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
            }
           
        }
    }
    
}


// clean up our new observers
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
   
    NSInteger numberOfRows = [[Conversation  MR_findAll] count];
    if (numberOfRows <= 0) {
        // show info
        [self showErrorText:@"暂时还没有消息"];
    }else{
        [self hiddeErrorText];
    }
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
    // update unread message badge number
    if ([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]) {
        NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"badgeNumber > %d",0];
        //        NSInteger  inter =  [Conversation MR_countOfEntitiesWithPredicate:preCMD];
        NSArray * array = [Conversation MR_findAllWithPredicate:preCMD];
        __block int badgeNumber = 0;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation * con = obj;
            badgeNumber += [con.badgeNumber intValue];
        }];
        SLLog(@"badgeNumber %d   ",badgeNumber);
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        if (badgeNumber > 0) {
            [delegate.tabBarController.tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%d",badgeNumber]];
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
            
        }else{
            [delegate.tabBarController.tabBar.items[0] setBadgeValue:nil];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatebadageNumber:) object:[NSString stringWithFormat:@"%d",badgeNumber]];
        [self performSelector:@selector(updatebadageNumber:) withObject:[NSString stringWithFormat:@"%d",badgeNumber] afterDelay:1];
        
    }
}

-(void) updatebadageNumber:(NSString *) badgeNumber
{
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"ios.set_badge" parameters:@{@"badge":badgeNumber} success:^(MLRequest *request, id responseObject) {
    } failure:^(MLRequest *request, NSError *error) {
    }];
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
- (void)showRecipe:(Conversation *) friend animated:(BOOL)animated
{
    // private or group
    switch ([friend.messageType intValue]) {
        case XCMessageActivity_UserGroupMessage:
        {
            NSString * gid =[friend.facebookId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",XCMessageActivity_User_GroupMessage] withString:@""];
//            chatview.gid = gid;
            XCJHomeDynamicViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJHomeDynamicViewController"];
            vc.Currentgid = gid;
            vc.title = friend.facebookName;
            vc.groupInfo = friend;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case XCMessageActivity_UserPrivateMessage:
        {
            
            ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatview.title = friend.facebookName;
            
            chatview.conversation = friend;
            //[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
            
            [self.navigationController pushViewController:chatview animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView * imageIcon = (UIImageView *)[cell.contentView viewWithTag:4];  //icon
    
    Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    switch ([conver.messageType intValue]) {
        case XCMessageActivity_UserPrivateMessage:
        {
            //check user info
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                if (response) {
                    FCUserDescription * localdespObject = response;
                    ((UILabel *)[cell.contentView viewWithTag:1]).text  = localdespObject.nick;  //nick
                    [imageIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[NSString stringWithFormat:@"%@",localdespObject.headpic] Size:100]]];
                }else{
                    // from network
                    
                     [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesByNetCompletion:^(id userinfo , NSError *error) {
                         FCUserDescription * localdespObject = userinfo;
                         ((UILabel *)[cell.contentView viewWithTag:1]).text  = localdespObject.nick;  //nick
                         [imageIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[NSString stringWithFormat:@"%@",localdespObject.headpic] Size:100]]];
                     } withuid:conver.facebookId];
                }
            } withuid:conver.facebookId];
        }
            break;
        default:
            // ok
            
            break;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView * imageIcon = (UIImageView *)[cell.contentView viewWithTag:4];  //icon
    imageIcon.backgroundColor = [UIColor lightGrayColor];
    UIImageView * imageStuts = (UIImageView *)[cell.contentView viewWithTag:5];  //status
    ((UILabel *)[cell.contentView viewWithTag:2]).text  = conver.lastMessage;  // description
    ((UILabel *)[cell.contentView viewWithTag:3]).text  = [tools FormatStringForDate:conver.lastMessageDate];  //time
    
//    UIImageView * imageFrame = (UIImageView *)[cell.contentView viewWithTag:6]; // frame
    switch ([conver.messageType intValue]) {
        case XCMessageActivity_UserPrivateMessage:
        {// 私信
             switch ([conver.messageStutes intValue]) {
                case messageStutes_incoming:
                    [imageStuts setImage:[UIImage imageNamed:@"inboxRepliedIcon"]];
                    break;
                case messageStutes_outcoming:
                    [imageStuts setImage:[UIImage imageNamed:@"inboxSeenIcon"]];
                    break;
                case messageStutes_error:
                    [imageStuts setImage:[UIImage imageNamed:@"inboxErrorIcon"]];
                    break;
                default:
                    break;
            }
        }
            break;
        case XCMessageActivity_UserGroupMessage:
        {
            [imageIcon setImage:[UIImage imageNamed:@"buddy_header_icon_group"]];
            ((UILabel *)[cell.contentView viewWithTag:1]).text  = conver.facebookName;
            
            if ([conver.isMute boolValue]) {
                [imageStuts setImage:[UIImage imageNamed:@"inboxMutedIcon"]];
            }else{
                [imageStuts setImage:nil];
            }
        }
            break;
        default:
            // ok
            
            break;
    }
    
    UITabBar *tabBar =(UITabBar*) [cell.contentView viewWithTag:12];
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if (![strClassName isEqualToString:@"_UIBadgeView"]) {
                [subview removeFromSuperview];
            }
        }
    }
    if ([conver.badgeNumber intValue] > 0) {
         [tabBar.items[0] setBadgeValue:[NSString stringWithFormat:@"%@",conver.badgeNumber]];
        //[self showBadgeValue:[NSString stringWithFormat:@"%d",[conver.badgeNumber intValue]] inView:imageFrame];
    }else{
         [tabBar.items[0] setBadgeValue:nil];
        //[self removeBadgeValueInView:imageFrame];
    }
    ((UILabel *)[cell.contentView viewWithTag:11]).height = 0.5f;
    
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITabBar *tabBar =(UITabBar*) [cell.contentView viewWithTag:12];
//    for (UIView *viewTab in tabBar.subviews) {
//        for (UIView *subview in viewTab.subviews) {
//            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
//            SLog(@"strClassName %@",strClassName);
//            if (![strClassName isEqualToString:@"_UIBadgeView"]) {
//                [subview setHidden: YES];
//                [subview removeFromSuperview];
//            }
//        }
//    }
//}

#pragma mark  - bragenumber

- (UIView *)showBadgeValue:(NSString *)strBadgeValue inView:(UIView*)view
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    tabBar.items = @[item];
    //寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //从原视图上移除
                [subview removeFromSuperview];
                //添加到新视图右上角
                [view addSubview:subview];
                subview.frame = CGRectMake(view.frame.size.width-subview.frame.size.width/2-4, -4+4,
                                           subview.frame.size.width, subview.frame.size.height);
                return subview;
            }
        }
    }
    return nil;
}

- (void)removeBadgeValueInView:(UIView*)view
{
    for (UIView *subview in view.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
            [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            SLLog(@"            [subview removeFromSuperview];");
            break;
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if ([self.tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        return 1;
    }
    
    NSInteger count = [[self.fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        return self.allReslutItems.count;
    }
    
    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView * tableviewSearch = self.searchDisplayController.searchResultsTableView;
    if ([tableView isEqual:tableviewSearch]){
         NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
        }
        if (self.allReslutItems && self.allReslutItems.count > 0) {
            Conversation * conver =  self.allReslutItems[indexPath.row];
            
            cell.textLabel.text  = conver.facebookName;
            cell.detailTextLabel.text = conver.lastMessage;
        }
        return  cell;
    }
    static NSString *CellIdentifier = @"ChatUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Conversation *recipe = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showRecipe:recipe animated:YES];
    //    UserInfo_default * info = _dataSource[indexPath.row];
    //
    //    XCJUserViewController *viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserViewController"];
    //    viewcon.userinfo = info;
    //    viewcon.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:viewcon animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    switch ([conver.messageType intValue]) {
        case XCMessageActivity_UserPrivateMessage:
        {
            return YES;
        }
            break;
        case XCMessageActivity_UserGroupMessage:
        {
            return YES;
        }
            break;
            
        default:
            break;
    }
    return YES;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    switch ([conver.messageType intValue]) {
        case XCMessageActivity_UserPrivateMessage:
        {
            return @"删除";
        }
            break;
        case XCMessageActivity_UserGroupMessage:
        {
            return @"退出群组";
        }
            break;
            
        default:
            break;
    }
    return @"删除";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Conversation * conver = (Conversation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        switch ([conver.messageType intValue]) {
            case XCMessageActivity_UserPrivateMessage:
            {
                id managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
                [managedObject MR_deleteEntity];
                [[managedObject managedObjectContext] MR_saveToPersistentStoreAndWait];
            }
                break;
            case XCMessageActivity_UserGroupMessage:
            {
                // 退出群聊
                if ([conver.facebookId containString:XCMessageActivity_User_GroupMessage]) {
                    NSString * gid = conver.facebookId;
                    gid = [gid stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",XCMessageActivity_User_GroupMessage] withString:@""];
                    [SVProgressHUD showWithStatus:@"正在退出..."];
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.leave" parameters:@{@"gid":gid} success:^(MLRequest *request, id responseObject) {
                        if (responseObject) {
                            id managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
                            [managedObject MR_deleteEntity];
                            [[managedObject managedObjectContext] MR_saveToPersistentStoreAndWait];
                            [SVProgressHUD dismiss];
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                        [UIAlertView showAlertViewWithMessage:@"退出失败"];
                    }];
                }
                
               
            }
                break;
                
            default:
            {
                id managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
                [managedObject MR_deleteEntity];
                [[managedObject managedObjectContext] MR_saveToPersistentStoreAndWait];
            }
                break;
        }

         //[[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageTabBarItemBadge" object:nil];
	}
}


@end
