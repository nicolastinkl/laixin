//
//  XCJFriendGroupViewController.m
//  laixin
//
//  Created by apple on 14-2-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJFriendGroupViewController.h"

#import "XCJGroupPost_list.h"
#import "Comment.h"
#import "XCAlbumAdditions.h"
#import "LXAPIController.h"
#import "MLNetworkingManager.h"
#import "UIAlertViewAddition.h"
#import "NSString+Addition.h"
#import "DataHelper.h"
#import "XCJUserInfoController.h"
#import "LXRequestFacebookManager.h"
#import "XCJGroupMenuView.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "XCJCreateChatViewController.h"
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
#import "PostActivityViewController.h"
#import "LXChatDBStoreManager.h"
#import "MLScrollRefreshHeader.h"
#import "XCJGroupUsersTableViewController.h"
#import "CoreData+MagicalRecord.h"
#import "XCJPostTextNaviController.h"
#import "XCJPostTextViewController.h"
#import "XCJCreateChatNaviController.h"
#import "CTAssetsPickerController.h"
#import "XCJErWeiCodeViewController.h"
#import "XCJFriendGroupNewmsg.h"
#import "LKBadgeView.h"
#import "FCUserDescription.h"
#import "XCJMessageReplylistController.h"
#import "UIButton+Bootstrap.h"
#import "XCJSendManySelectedImageViewCOntrooler.h"
#import "XCJSelfPhotoViewController.h"
#import "UINavigationController+SGProgress.h"
#import "Conversation.h"

@interface XCJFriendGroupViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate>
{
    NSString * _Currentgid;
    XCJFriendGroupNewmsg * tablehead;
    UIButton * button;
    UIImageView * newIcon;
    UIImageView * newIcon_sign;
    NSMutableArray * arrayGroup ;

}
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation XCJFriendGroupViewController
 
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
    self.title = @"群组动态";
    tablehead = [[NSBundle mainBundle] loadNibNamed:@"XCJFriendGroupNewmsg" owner:self options:nil][0];
    
    if ([self.conversation.badgeNumber intValue] > 0) {
        [tablehead setHeight:340.0f];
    }else{
        [tablehead setHeight:300.0f];
    }
    
    NSPredicate *predicatesss = [NSPredicate predicateWithFormat:@"postid > %@", @"0"];
    ConverReply * con = [ConverReply MR_findFirstWithPredicate:predicatesss];
    if ([con.content isEqualToString:@"新朋友圈消息"]) {
        con.content = @"";
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    }
    
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString * jsonData = [[EGOCache globalCache] stringForKey:@"MyFriendGroupPhotoCache"];
        if (jsonData.length > 150) {
            // parse
            NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];            
            NSDictionary * responseObject =[data  objectFromJSONData] ;
            NSDictionary * dicreult = responseObject[@"result"];
            NSArray * postsDict = dicreult[@"posts"];
            __block NSInteger lasID = 0;
            [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                lasID = [post.postid integerValue]; 
                [self.activities addObject:post];
            }];
            [self successGetActivities:self.activities withLastID:lasID];
        }else{
            [self.refreshView beginRefreshing];
        }
    });
   
    UILabel * label_name = (UILabel *) [tablehead subviewWithTag:1];
    UIImageView * label_bg = (UIImageView *) [tablehead subviewWithTag:2];
    UIImageView * label_icon = (UIImageView *) [tablehead subviewWithTag:3];
    label_icon.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(targettoPhotoView:)];
    [label_icon addGestureRecognizer:tapGes];
    
    button = (UIButton *) [tablehead subviewWithTag:4];
    newIcon = (UIImageView *) [tablehead subviewWithTag:5];
    newIcon_sign = (UIImageView *) [tablehead subviewWithTag:7];
    label_name.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    
    UIImage  *chacheImage = [[EGOCache globalCache] imageForKey:@"myphotoBgImage"];
    if (chacheImage) {
        [label_bg setImage:chacheImage];
    }else{
        //[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick] [LXAPIController sharedLXAPIController].currentUser.background_image
           [label_bg setImageWithURL:[NSURL URLWithString:[DataHelper getStringValue:[LXAPIController sharedLXAPIController].currentUser.background_image defaultValue:@""]] placeholderImage:[UIImage imageNamed:@"opengroup_profile_cover"]];
    }
    
    [label_icon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:160]]];
    [label_bg setHeight:270.0f];
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id  response, NSError *error) {
        FCUserDescription * localdespObject  = response;
        [newIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:localdespObject.headpic Size:100]]];
    } withuid:self.conversation.uid];
    
    [button setTitle:[NSString stringWithFormat:@"%d条新消息",[self.conversation.badgeNumber  intValue]] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"%d条新消息",[self.conversation.badgeNumber  intValue]] forState:UIControlStateHighlighted];
//    UIImage *originalImage = [UIImage imageNamed:@"fbc_actionbar_44_background_0_0_0_5_normal"];
//    UIEdgeInsets insets = UIEdgeInsetsMake(0,0,0,5);
//    UIImage *stretchableImage = [originalImage resizableImageWithCapInsets:insets];
//    [button setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(targetToNewView:) forControlEvents:UIControlEventTouchUpInside];
    [button dangerStyle];
    
    self.tableView.tableHeaderView = tablehead;
    
    if ([self.conversation.badgeNumber intValue] > 0) {
         button.hidden = NO;
         newIcon.hidden = NO;
         newIcon_sign.hidden = NO;
     }else{
         button.hidden = YES;
         newIcon.hidden = YES;
         newIcon_sign.hidden = YES;
    }
    
    UIBarButtonItem * baritem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonMinified"] style:UIBarButtonItemStyleBordered target:self action:@selector(showActionClick:)];
     UIBarButtonItem * takebaritem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"blue_publisherBar_Icon_Photo_Highlighted"] style:UIBarButtonItemStylePlain target:self action:@selector(SendImgActionClick:)];
 
    self.navigationItem.rightBarButtonItems = @[baritem,takebaritem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StartPostUploadimages:) name:@"StartPostUploadimages" object:nil];
}

-(void) StartPostUploadimages:(NSNotification * ) notify
{
    if (notify.object) {
        [self.navigationController showSGProgressWithDuration:[notify.object intValue] andTintColor:[UIColor redColor]];
    }
}

-(IBAction)SendImgActionClick:(id)sender
{
    //查看是否有加入群组
    if ( arrayGroup == nil) {
        
        NSMutableArray * auy = [[NSMutableArray alloc] init];
        arrayGroup = auy;
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSArray * array = [Conversation MR_findAllWithPredicate:nil inContext:localContext];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation  * conver = obj;
            if ([conver.messageType intValue] == XCMessageActivity_UserGroupMessage) {
                [arrayGroup addObject:conver];
            }
        }];
    }
    
    if (arrayGroup.count == 0) {
        [UIAlertView showAlertViewWithTitle:@"提示" message:@"您还没有加入任何群组,还不能发表群组动态."];
    }else{
    
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"请选择群组" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        alert.tag =  1;
        [arrayGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Conversation  * conver = obj;
            if ([conver.messageType intValue] == XCMessageActivity_UserGroupMessage) {
                [alert addButtonWithTitle:conver.facebookName];
            }
        }];
        [alert addButtonWithTitle:@"取消"];
        alert.cancelButtonIndex = arrayGroup.count;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == 1) {
        if (buttonIndex == arrayGroup.count) {
            //dismiss
        }else{
             Conversation  * conver = arrayGroup[buttonIndex];
             NSString * gid =[conver.facebookId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",XCMessageActivity_User_GroupMessage] withString:@""];
             _Currentgid = gid;
             UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:@"发表新动态" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"纯文字" otherButtonTitles:@"拍照+文字",@"相册+文字", nil];
             action.tag = 3;
            [action showInView:self.view];
        }
    }
}

-(IBAction)targettoPhotoView:(id)sender
{
    XCJSelfPhotoViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPhotoViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void) hasNewPostInfo
{
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        XCJGroupPost_list * post = [self.activities firstObject];
        if (post) {
        [self postGetActivitiesWithLastID:[post.postid intValue] withType:Enum_UpdateTopData];
        }
    });
}

-(IBAction)showActionClick:(id)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:Nil otherButtonTitles:@"查看消息列表", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    
    if(assets.count > 0){
        //多图模式
        XCJSendManySelectedImageViewCOntrooler * contr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSendManySelectedImageViewCOntrooler"];
        contr.array = [assets mutableCopy];
        contr.gID = _Currentgid;
        contr.needRefreshViewController = self;
        [self.navigationController pushViewController:contr animated:YES];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            XCJMessageReplylistController * viewcontr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMessageReplylistController"];
            viewcontr.conversation = self.conversation;
            [self.navigationController pushViewController:viewcontr animated:YES];
        }
    } else if(actionSheet.tag == 3)
    {
        switch (buttonIndex) {
            case 0:
            {
                XCJPostTextNaviController * postNavi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJPostTextNaviController"];
                XCJPostTextViewController *view = (XCJPostTextViewController*)postNavi.visibleViewController;
                view.gID = _Currentgid;
                view.needRefreshViewController = self;
                [self presentViewController:postNavi animated:YES completion:^{
                    
                }];
            }
                break;
            case 1:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                    camera.delegate = self;
                    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:camera animated:YES completion:nil];
                }
            }
                break;
            case 2:{
                [self pickAssets:21];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];    
    NSURL * url = [self uploadContent:theInfo];
    PostActivityViewController *postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostActivityViewController"];
    postVC.gID = _Currentgid;
    postVC.filePath = [url copy];
    postVC.uploadKey = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@",url]];
    postVC.postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    postVC.needRefreshViewController = self;
    [self.navigationController pushViewController:postVC animated:YES];
}

- (NSURL * )uploadContent:(NSDictionary *)theInfo {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
    
    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
        NSString * namefile =  [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@",timeDesc,_Currentgid]];
        NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        SLLog(@"Upload Path: %@", filePath);
        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 1);
        [webData writeToFile:filePath atomically:YES];
        return [NSURL URLWithString:filePath];
    }
    return nil;
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}


- (void)pickAssets:(int )sender
{
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.navigationBar.barTintColor  = [UIColor colorWithRed:48.0/255.0 green:167.0/255.0 blue:255.0/255.0 alpha:1.0];
    picker.navigationBar.translucent = YES;
    picker.navigationBar.tintColor  = [UIColor whiteColor];
    //[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];    //
    picker.navigationBarHidden = NO;
    //    picker.navigationBar.backgroundColor = [UIColor whiteColor];
    
    picker.maximumNumberOfSelection = sender;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    // only allow video clips if they are at least 5s
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            //            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            return NO;
        } else {
            return YES;
        }
    }];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    if (tablehead) {
        if ([self.conversation.badgeNumber intValue] > 0) {
        [tablehead setHeight:340.0f];
            button.hidden = NO;
            newIcon.hidden = NO;
            newIcon_sign.hidden = NO;
        }else{
            button.hidden = YES;
            newIcon.hidden = YES;
            newIcon_sign.hidden = YES;
             [tablehead setHeight:300.0f];
        }
        [self.tableView.tableHeaderView layoutIfNeeded];
        [self.tableView reloadData];
    }
}

-(IBAction)targetToNewView:(id)sender
{
    XCJMessageReplylistController * viewcontr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMessageReplylistController"];
    viewcontr.conversation = self.conversation;
    [self.navigationController pushViewController:viewcontr animated:YES];
}

- (void)postGetActivitiesWithLastID:(NSInteger)lastID withType:(NSInteger) typeIndex
{
    //put here to GCD
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        /* get all list data*/
        
        switch (typeIndex) {
            case Enum_initData:
            {
                NSDictionary * parames = @{@"count":@"20"};                
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_timeline"  parameters:parames success:^(MLRequest *request, id responseObject) {
                    //    postid = 12;
                    /*
                     Result={
                     “posts”:[*/
                    if (responseObject) {
                        __block NSInteger lasID = 0;
                        NSDictionary * groups = responseObject[@"result"];
                        NSArray * postsDict =  groups[@"posts"];
                        [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                            lasID = [post.postid integerValue];
                            [self.activities addObject:post];
                        }];
                        [self successGetActivities:self.activities withLastID:lasID];
                        
                        [[EGOCache globalCache] setString:[responseObject JSONString] forKey:@"MyFriendGroupPhotoCache" withTimeoutInterval:60*60];
                    }else{
                        [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                    }
                } failure:^(MLRequest *request, NSError *error) {
                    [self failedGetActivitiesWithLastID:0];
                    [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                }];
            }
                break;
            case Enum_UpdateTopData:
            {
                //group.get_new_post(gid,frompos) 取得新消息，从某个位置开始，用于掉线后重新连上的情况
                //                Result=同11
                NSDictionary* parames = @{@"after":@(lastID)};
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_timeline_new" parameters:parames success:^(MLRequest *request, id responseObject) {
                    NSDictionary * groups = responseObject[@"result"];
                    NSArray * postsDict =  groups[@"posts"];
                    __block NSInteger lasID = 0;
                    if (postsDict &&  postsDict.count > 0) {
                        
                        [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                            if (post) {
                                lasID = [post.postid integerValue];
                                [self.activities insertObject:post atIndex:0];
                                [self.cellHeights insertObject:@0 atIndex:0];
                                [self reloadSingleActivityRowOfTableView:0 withAnimation:YES];
                            }
                        }];
                        
                        // update cache
                        NSString * jsonData = [[EGOCache globalCache] stringForKey:@"MyFriendGroupPhotoCache"];
                        if (jsonData.length > 150) {
                            // parse
                            NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary * responseObjectold =[data  objectFromJSONData] ;
                            NSDictionary * dicreultold = responseObjectold[@"result"];
                            NSArray * postsDictOld = dicreultold[@"posts"];
                            NSMutableArray * array = [[NSMutableArray alloc] initWithArray:postsDict];
                            [array addObjectsFromArray:postsDictOld];
                            
                             [[EGOCache globalCache] setString:[@{@"result":@{@"posts":array}} JSONString] forKey:@"MyFriendGroupPhotoCache" withTimeoutInterval:60*60];
                            
                        }
                        
                        [self successGetActivities:self.activities withLastID:lasID];
                    }else{
                        [self failedGetActivitiesWithLastID:0];
                    }
                    
                } failure:^(MLRequest *request, NSError *error) {
                    [self failedGetActivitiesWithLastID:0];
                    [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                }];
            }
                break;
            case Enum_MoreData:
            {
                NSString * postid ;
                if (self.activities.count >= 20) {
                    XCJGroupPost_list * post =[self.activities lastObject];
                    postid = post.postid;
                }else{
                    postid = [NSString stringWithFormat:@"%d",self.activities.count];
                }
                NSDictionary* parames = @{@"before":postid,@"count":@"20"};
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.friend_timeline"  parameters:parames success:^(MLRequest *request, id responseObject) {
                    //    postid = 12;
                    /*
                     Result={
                     “posts”:[*/
                    if (responseObject) {
                        __block NSInteger lasID = 0;
                        NSDictionary * groups = responseObject[@"result"];
                        NSArray * postsDict =  groups[@"posts"];
                        if (postsDict && postsDict.count > 0) {
                            [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                                lasID = [post.postid integerValue];
                                [self.activities addObject:post];
                            }];
                            [self successGetActivities:self.activities withLastID:lasID];
                        }else{
                            [self failedGetActivitiesWithLastID:0];
                        }
                    }else{
                        [self failedGetActivitiesWithLastID:0];
                    }
                } failure:^(MLRequest *request, NSError *error) {
                    [self failedGetActivitiesWithLastID:0];
                    [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                }];
            }
                break;
                
            default:
                break;
        }
    });
    
}

//点击赞按钮
- (void)clickLikeButton:(UIButton *)likeButton onActivity:(XCJGroupPost_list *)activity{
    
    likeButton.enabled = NO;
    //赞
    if (!activity.ilike) {
        NSDictionary * parames = @{@"postid":activity.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //            [activity.likeUsers addObject:[[LXAPIController sharedLXAPIController] currentUser]];
            activity.ilike = YES;
            activity.like ++;
            likeButton.enabled = YES;
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"点赞失败 请重试!"];
        }];
    }else{
        NSDictionary * parames = @{@"postid":activity.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.dislike"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //如果有则删除，没有则不动啊
            for (LXUser *aUser in activity.likeUsers) {
                if ([aUser.uid isEqualToString:[[LXAPIController sharedLXAPIController] currentUser].uid]) {
                    //                    [activity.likeUsers removeObject:aUser];
                    break;
                }
            }
            activity.like -- ;
            activity.ilike = NO;
            likeButton.enabled = YES;
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"取消赞失败 请重试!"];
        }];
    }
    
    //执行赞图标放大的动画
    likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
    [UIView animateWithDuration:.50f
                     animations:^{
                         likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                         //刷新对应行
                         [self reloadSingleActivityRowOfTableView:[self.activities indexOfObject:activity] withAnimation:NO];
                     }];
    
}

- (void)clickDeleteButton:(UIButton *)commentButton onActivity:(XCJGroupPost_list *)activity
{
    if (activity) {
        [SVProgressHUD show];
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.delete" parameters:@{@"postid":activity.postid} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                // delete ok
                [SVProgressHUD dismiss];
                @try {
                    int index = [self.activities indexOfObject:activity];
                    [self.cellHeights removeObjectAtIndex:index];
                    [self.activities removeObject:activity];
                    NSIndexPath  * indexpath = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationTop];
                }
                @catch (NSException *exception) {
                    [UIAlertView showAlertViewWithMessage:@"删除失败"];
                }
                @finally {
                    
                }
                
            }
            
            
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"删除失败"];
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)sendCommentContent:(NSString*)content ToActivity:(XCJGroupPost_list*)currentOperateActivity atCommentIndex:(NSInteger)commentIndex
{
    if ([content isNilOrEmpty]||commentIndex>=(NSInteger)currentOperateActivity.comments.count) {
        return;
    }
    
    NSDictionary * parames = @{@"postid":currentOperateActivity.postid,@"content":content};
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"replyid":1}
        
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            NSString * repID = [DataHelper getStringValue:result[@"replyid"] defaultValue:@""];
            
            int localreplyid = [USER_DEFAULT integerForKey:KeyChain_Laixin_Max_ReplyID];
            if (localreplyid < [repID intValue]) {
                [USER_DEFAULT setInteger:[repID intValue] forKey:KeyChain_Laixin_Max_ReplyID];
                [USER_DEFAULT synchronize];
            }
            
            Comment  *comment = [[Comment alloc] init];
            comment.replyid = repID;
            comment.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
            comment.postid = currentOperateActivity.postid;
            comment.time = [[NSDate date] timeIntervalSince1970];
            comment.content = content;
            [currentOperateActivity.comments addObject:comment];
            //刷新此cell
            [self reloadSingleActivityRowOfTableView:[self.activities indexOfObject:currentOperateActivity] withAnimation:NO];
        }
        //        //升序排序
        //        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_time" ascending:YES];
        //        [currentOperateActivity.comments sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"回复失败 请重试!"];
    }];
    
}

#pragma mark - ActivityTableViewCellDelegate
//点击某用户名
- (void)clickUserID:(NSString *)uid onActivity:(XCJGroupPost_list *)activity
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id result, NSError * error) {
        infoview.UserInfo = result;
        infoview.title = @"详细资料";
        [self.navigationController pushViewController:infoview animated:YES];
    } withuid:uid];
}

//点击当前activity的发布者头像
- (void)clickAvatarButton:(UIButton *)avatarButton onActivity:(XCJGroupPost_list *)activity
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id result, NSError * error) {
        infoview.UserInfo = result;
        infoview.title = @"详细资料";
        [self.navigationController pushViewController:infoview animated:YES];
    } withuid:activity.uid];
}


@end
