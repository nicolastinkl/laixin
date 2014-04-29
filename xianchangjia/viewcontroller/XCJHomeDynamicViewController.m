//
//  XCJHomeDynamicViewController.m
//  laixin
//
//  Created by apple on 14-1-2.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJHomeDynamicViewController.h"
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
#import "XCJSendManySelectedImageViewCOntrooler.h"
#import "XCJErWeiCodeViewController.h"
#import "UINavigationController+SGProgress.h"
#import "SBSegmentedViewController.h"
#import "XCJAddUserTableViewController.h"
#import "PWLoadMoreTableFooterView.h"
#import "UIButton+WebCache.h"
#import "XCJContentTypesCell.h"
#import "IDMPhotoBrowser.h"

#define DISTANCE_BETWEEN_ITEMS  9.0
#define LEFT_PADDING            9.0
#define ITEM_WIDTH              135.0
#define TITLE_HEIGHT            40.0
#define TITLE_jianxi            2.5

#define colNumber 4

#define kAttributedLabelTag 211


@interface XCJHomeDynamicViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,XCJGroupMenuViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UITextFieldDelegate,CTAssetsPickerControllerDelegate,PWLoadMoreTableFooterDelegate>
{

    XCJGroupMenuView  * menuView;
    NSArray * JsonArray;
    PWLoadMoreTableFooterView *_loadMoreFooterView;
    BOOL _datasourceIsLoading;
    bool _allLoaded;
    NSString  *_Currentgid;
    NSString * CurrentUrl;
}


@property (weak, nonatomic) IBOutlet UITableView *tableviewself;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *activities;
@end

@implementation XCJHomeDynamicViewController

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
    
    
    if (!menuView) {
        menuView = [[NSBundle mainBundle] loadNibNamed:@"XCJGroupMenuView" owner:self options:nil][0];
        [self.view addSubview:menuView];
        menuView.alpha = 0;
        menuView.top = -600;
        menuView.delegate =  self;
    }
    
    [self _init];
    
    if ([self.groupInfo.isMute boolValue]) {
        //如果是已经静音  那么就设置接收
        // update imageview
        menuView.muteImageview.image = [UIImage imageNamed:@"threadInfoUnmute"];
        [menuView.muteButton setTitle:@"取消静音" forState:UIControlStateNormal];
    }else{
        // update imageview
        menuView.muteImageview.image = [UIImage imageNamed:@"threadInfoMute"];
        [menuView.muteButton setTitle:@"静音" forState:UIControlStateNormal];
    }
    
    UIBarButtonItem * barOne = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"composeIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(SendPostClick:)];
    UIBarButtonItem * barTwo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonMinified"] style:UIBarButtonItemStyleDone target:self action:@selector(postAction:)];    
    self.navigationItem.rightBarButtonItems = @[barTwo,barOne];
    
    // init data with parent viewcontroller
//    [self.refreshView beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StartPostUploadimages:) name:@"StartPostUploadimages" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StartRefershNewPostInfo:) name:@"StartRefershNewPostInfo" object:nil];
    
    
    //config the load more view
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    self.tableviewself.tableFooterView = _loadMoreFooterView;
    
    /**
     *  MARK: init 0..
     */
    _allLoaded = NO;
    _datasourceIsLoading = YES;
    
    _Currentgid = self.Currentgid;
    /**
     * MARK: init net data.
     */
    [self initDatawithNet:Enum_initData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StartPostUploadimages" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StartRefershNewPostInfo" object:nil];
    
}

-(void) StartRefershNewPostInfo:(NSNotification *) noitfy
{
    if (noitfy.object) {
        [self.activities insertObject:noitfy.object atIndex:0];
        [self.tableviewself reloadData];
    }
}

-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        self.activities = _init_array;
    }
}



-(void) StartPostUploadimages:(NSNotification * ) notify
{
    if (notify.object) {
          [self.navigationController showSGProgressWithDuration:[notify.object intValue] andTintColor:[UIColor redColor]];
    }
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    /*if (assets.count == 1) {
        //单图模式
       ALAsset *asset =  [assets firstObject];
        if (asset) {            
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = [assetRep fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:imgRef
                                                 scale:assetRep.scale
                                           orientation:(UIImageOrientation)assetRep.orientation];
            NSURL * url = [asset.defaultRepresentation url];
            PostActivityViewController *postVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostActivityViewController"];
            // [[PostActivityViewController alloc]init];
            postVC.gID = _Currentgid;
            postVC.filePath = [url copy];
            postVC.uploadKey = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@",url]];
            postVC.postImage = image;
            postVC.needRefreshViewController = self;
            [self.navigationController pushViewController:postVC animated:YES];
        }
    }else*/
    
    if(assets.count > 0){
        //多图模式
        XCJSendManySelectedImageViewCOntrooler * contr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSendManySelectedImageViewCOntrooler"];
        contr.array = [assets mutableCopy];
        contr.gID = _Currentgid;
        contr.needRefreshViewController = self;
        [self.navigationController pushViewController:contr animated:YES];
    }
//            UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail] ;
//            UIImage * image  = [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]];
    
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:[self indexPathOfNewlyAddedAssets:assets]
//                          withRowAnimation:UITableViewRowAnimationBottom];
//    
//    [self.assets addObjectsFromArray:assets];
//    [self.tableView endUpdates];
}

- (NSArray *)indexPathOfNewlyAddedAssets:(NSArray *)assets
{
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    
//    for (NSUInteger i = self.assets.count; i < self.assets.count + assets.count ; i++)
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//    
//    return indexPaths;
    return  nil;
}


#pragma mark  sendpost

-(IBAction)SendPostClick:(id)sender
{
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:@"发表新动态" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"纯文字" otherButtonTitles:@"拍照+文字",@"相册+文字", nil];
    action.tag = 3;
    [action showInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.groupInfo.badgeNumber intValue] > 0) {
        self.groupInfo.badgeNumber = @(0);
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    }
    if (self.activities.count > 0) {
        XCJGroupPost_list * post = [self.activities firstObject];
        if (post) {
            if (![self.groupInfo.lastMessage isEqualToString: post.content]) {
                self.groupInfo.lastMessage = post.content;
                SLog(@"post.time: %f",post.time);
                if(post.time < 0)
                {
                    self.groupInfo.lastMessageDate = [NSDate date];
                }else{
                    self.groupInfo.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:post.time];
                }
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
            }
        }
    }
    
}

- (IBAction)openGroupClick:(id)sender {
    XCJDomainsViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJDomainsViewController"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewContr];
    viewContr.title = @"我的群组";
    [self presentViewController:nav animated:YES completion:nil];
}



- (void) hiddenSelfViewClick
{
    [self postAction:nil];
}
/**
 *  添加成员
 */
- (void) addFriendClick
{
    [self postAction:nil];
    
    XCJCreateChatNaviController * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCreateChatNaviController"];
    XCJCreateChatViewController * viewContr =  (XCJCreateChatViewController*)navi.visibleViewController;
    viewContr.title = @"添加更多人员";
    viewContr.Currentgid = self.Currentgid;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

/**
 *  查看成员
 */
- (void) findandfindCodeClick
{
    [self postAction:nil];
    
    XCJGroupUsersTableViewController * groupView = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJGroupUsersTableViewController"];
    groupView.gid = self.Currentgid;
    
    [self.navigationController pushViewController:groupView animated:YES];
    
}

/**
 *  静音
 */
- (void) MuteMusicClick
{
    NSString * strtitle;
    NSString * messageContent;
    if ([self.groupInfo.isMute boolValue]) {
        //如果是已经静音  那么就设置接收
        // update imageview
        strtitle = @"取消静音";
        messageContent = @"此群组将收到推送通知";
    }else{
        // update imageview
        strtitle = @"静音";
        messageContent = @"静音此群组,将不再收到推送通知";
    }
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:messageContent delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:strtitle otherButtonTitles:nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

/**
 *  更多
 */
- (void) moreClick
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出群组" otherButtonTitles:@"设置群组名称",@"查看群组二维码", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
}

-(IBAction)postAction:(id)sender
{
    if (menuView.top == 64) {
        // hidden  _arrowImageView.transform = CGAffineTransformMakeRotation( M_PI);
        
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 0;
            menuView.top = -600;
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL finished) {
        }];
    }else{
        // show
        //[self.tableviewself scrollsToTop];
        menuView.alpha = 0;
        menuView.top = -600;
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 1;
            menuView.top = 64;
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
        }];
        
    }
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            //退出群组
            if (buttonIndex == 1) {
                //MARK SURE OUT THIS GROUP
                //17 group.delete(gid) 删除群，必须是创建者
                [SVProgressHUD showWithStatus:@"正在退出"];
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.leave" parameters:@{@"gid":self.Currentgid} success:^(MLRequest *request, id responseObject) {
                        if (responseObject) {
                            [self.groupInfo MR_deleteEntity];
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                            [SVProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                        [UIAlertView showAlertViewWithMessage:@"退出失败"];
                    }];
                });
            }
        }
            break;
        case 2:
        {
            if (buttonIndex == 1) {
//                alertView.inputView.
                NSString * str = [alertView textFieldAtIndex:0].text;
                if (str.length > 0) {
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.update" parameters:@{@"gid":self.Currentgid,@"name":str} success:^(MLRequest *request, id responseObject) {
                        if (responseObject) {
                            self.title = str;
                            self.groupInfo.facebookName = str;
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                        [UIAlertView showAlertViewWithMessage:@"修改失败"];
                    }];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Button at index: %d clicked\nIt's title is '%@'", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    switch (actionSheet.tag) {
        case 1:
        {
            if(buttonIndex == 1){
                return;
            }
                
            if (![self.groupInfo.isMute boolValue]) {
                //如果是已经静音  那么就设置接收
                // 注册群的消息更新
                [[MLNetworkingManager sharedManager] sendWithAction:@"group.regupdate" parameters:@{@"gid":self.Currentgid} success:^(MLRequest *request, id responseObject) {
                    //静音
                    self.groupInfo.isMute = @YES;
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                    // update imageview
                    menuView.muteImageview.image = [UIImage imageNamed:@"threadInfoUnmute"];
                    [menuView.muteButton setTitle:@"取消静音" forState:UIControlStateNormal];
                } failure:^(MLRequest *request, NSError *error) {
                    [UIAlertView showAlertViewWithMessage:@"设置失败"];
                }];
            }
            else{
                //如果是已经接收  那么就设置静音
                //group.unregupdate(gid) 取消群消息更新
                [[MLNetworkingManager sharedManager] sendWithAction:@"group.unregupdate" parameters:@{@"gid":self.Currentgid} success:^(MLRequest *request, id responseObject) {
                    //静音
                    self.groupInfo.isMute = @NO;
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                    // update imageview
                    menuView.muteImageview.image = [UIImage imageNamed:@"threadInfoMute"];
                    [menuView.muteButton setTitle:@"静音" forState:UIControlStateNormal];
                } failure:^(MLRequest *request, NSError *error) {
                    [UIAlertView showAlertViewWithMessage:@"设置失败"];
                }];
                
            }
            
            
        }
            break;
        case 2:
        {
            //更多
            switch (buttonIndex) {
                case 0:
                {
                    //退出群组
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"退出群组?" message:@"确定退出小组吗?你将不会再收到此群组的新消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"离开", nil];
                    alert.tag = 1;
                    [alert show];
                    
                }
                    break;
                    
                case 1:
                {
                    //设置名称
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"修改群组名称" message:self.title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", nil];
                    alert.tag = 2;
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [[alert textFieldAtIndex:0] setDelegate:self];
                    [alert show];
                }
                    break;
                case 2:
                {
                    //二维码
                    XCJErWeiCodeViewController * viewcontr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJErWeiCodeViewController"];
                    viewcontr.gid = self.Currentgid;
                    [self.navigationController pushViewController:viewcontr animated:YES];
                    
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 3:
        {
            switch (buttonIndex) {
                case 0:
                {
                    //纯文字
                    XCJPostTextNaviController * postNavi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJPostTextNaviController"];
                    XCJPostTextViewController *view = (XCJPostTextViewController*)postNavi.visibleViewController;
                    view.gID = _Currentgid;
                    view.needRefreshViewController = self;
                    [self presentViewController:postNavi animated:YES completion:^{
                        
                    }];
                }
                    break;
                case 1:{   //拍照
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
            break;
        case 4:
        {
            //1  朋友圈
            //0   好友
            
            XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
            UIImage * image = [self.tableviewself  viewToImage:self.tableviewself];
            NSData * data = UIImageJPEGRepresentation(image, .5);
            switch (buttonIndex) {
                case 0:
                {
                    [delegate sendImageContent:0 withImageData:data];
                }
                    break;
                case 1:
                {
                    [delegate sendImageContent:1 withImageData:data];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
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



- (void)initDatawithNet:(NSInteger) typeIndex
{
    
    switch (typeIndex) {
        case Enum_initData:
        {
            NSDictionary * parames = @{@"gid":_Currentgid,@"pos":@0,@"count":@"20"};
            
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //    postid = 12;
                /*
                 Result={
                 “posts”:[*/
                if (responseObject) {
                    NSDictionary * groups = responseObject[@"result"];
                    NSArray * postsDict =  groups[@"posts"];
                    [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                        [self.activities addObject:post];
                        
                    }];
                    if (postsDict.count >= 20) {
                        _allLoaded = NO;
                    }else{
                        _allLoaded = YES;
                    }
                }else{
                    [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                }
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                
            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
            
        }
            break;
        case Enum_UpdateTopData:
        {
            //group.get_new_post(gid,frompos) 取得新消息，从某个位置开始，用于掉线后重新连上的情况
            //                Result=同11
            NSString * lastID = 0;
            if (self.activities.count  > 0) {
                XCJGroupPost_list * post =[self.activities firstObject];
                lastID = post.postid;
            }else{
                lastID = @"0";
            }
            NSDictionary* parames = @{@"gid":_Currentgid,@"frompos":lastID};
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.get_new_post" parameters:parames success:^(MLRequest *request, id responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"posts"];
                __block NSInteger lasID = 0;
                if (postsDict &&  postsDict.count > 0) {
                    [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                        if (post) {
                            lasID = [post.postid integerValue];
                            [self.activities insertObject:post atIndex:0];
                        }
                    }];
                    _datasourceIsLoading = NO;
                    [self doneLoadingTableViewData];
                }
                
            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
        }
            break;
        case Enum_MoreData:
        {
            NSInteger postid ;
            if (self.activities.count >= 20) {
                XCJGroupPost_list * post =[self.activities lastObject];
                postid = [post.postid intValue];
            }else{
                postid = 0;
            }
            NSDictionary* parames = @{@"gid":_Currentgid,@"pos":@(postid),@"count":@"20"};
            
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //    postid = 12;
                /*
                 Result={
                 “posts”:[*/
                if (responseObject) {
                    NSDictionary * groups = responseObject[@"result"];
                    NSArray * postsDict =  groups[@"posts"];
                    if (postsDict && postsDict.count > 0) {
                        [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                            [self.activities addObject:post];
                        }];
                        if (postsDict.count >= 20) {
                            _allLoaded = NO;
                        }else{
                            _allLoaded = YES;
                        }
                    }
                    _datasourceIsLoading = NO;
                    [self doneLoadingTableViewData];
                }
                
            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark -
#pragma mark PWLoadMoreTableFooterDelegate Methods

- (void)pwLoadMore {
    //just make sure when loading more, DO NOT try to refresh your data
    //Especially when you do your work asynchronously
    //Unless you are pretty sure what you are doing
    //When you are refreshing your data, you will not be able to load more if you have pwLoadMoreTableDataSourceIsLoading and config it right
    //disable the navigationItem is only demo purpose
    
    _datasourceIsLoading = YES;
    [self initDatawithNet:Enum_MoreData];
    
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData {
	//  model should call this when its done loading
	[_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
    [self.tableviewself reloadData];
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _datasourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.activities.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    XCJGroupPost_list * post = self.activities[section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        return 4;
    }
    
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = self.activities[indexPath.section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        switch (indexPath.row) {
            case 0:
                return 40;
                break;
            case 1:
            {
                if (post.excount > 0) {
                    
                    float imageviewHeight = (post.excount/colNumber)*65 +(post.excount/colNumber)*TITLE_jianxi;
                    if (post.excount%colNumber>0) {
                        imageviewHeight += TITLE_jianxi+65;
                    }
                    return imageviewHeight + 10; //content
                }else{
                    return 320.0f;
                }
            }
                break;
            case 2:
                return [self textHeight:post.content];//text
                break;
            case 3:
                return 44.0f;
                break;
                
            default:
                break;
        }
    }
    switch (indexPath.row) {
        case 0:
            return 44.0f;
            break;
        case 1:
            return [self textHeight:post.content];//text
            break;
        case 2:
            return 44.0f;
            break;
            
        default:
            break;
    }
    return 0.0f;
}

-(float) textHeight:(NSString *) text
{
    CGFloat maxWidth = 300.0f;//[UIScreen mainScreen].applicationFrame.size.width * 0.70f;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 20.0f );
}

-(IBAction)commentClick:(id)sender
{
    UIButton * button = sender;
    UITableViewCell * cell = (UITableViewCell *)button.superview.superview.superview;
    XCJGroupPost_list * post = self.activities[ [self.tableviewself indexPathForCell:cell].section];
    if (post) {
        
        SBSegmentedViewController *segmentedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSegmentedCommentController"];
        segmentedViewController.position = SBSegmentedViewControllerControlPositionNavigationBar;
        [segmentedViewController addStoryboardSegments:@[@"SegmentComment", @"SegmentLikes"]];
        segmentedViewController.someobject = post;
        [self.navigationController pushViewController:segmentedViewController animated:YES];
        
    }
}

-(IBAction)likeClick:(id)sender
{
    UIButton * likeButton = sender;
    UITableViewCell * cell = (UITableViewCell *)likeButton.superview.superview.superview;
    XCJGroupPost_list * post = self.activities[ [self.tableviewself indexPathForCell:cell].section];
    
    
    likeButton.enabled = NO;
    //赞
    if (!post.ilike) {
        NSDictionary * parames = @{@"postid":post.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
            post.ilike = YES;
            post.like ++;
            likeButton.enabled = YES;
            [self refreshbutton:likeButton withdata:post];
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"操作失败"];
        }];
    }else{
        NSDictionary * parames = @{@"postid":post.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.dislike"  parameters:parames success:^(MLRequest *request, id responseObject) {
            post.like -- ;
            post.ilike = NO;
            likeButton.enabled = YES;
            [self refreshbutton:likeButton withdata:post];
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"操作失败"];
        }];
    }
    
    //执行赞图标放大的动画
    likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
    [UIView animateWithDuration:.50f
                     animations:^{
                         likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void) refreshbutton:(UIButton *) likeButton withdata:(XCJGroupPost_list * ) post
{
    if (!post.ilike)
        [likeButton setImage:[UIImage imageNamed:@"home_tl_ic_like_nor"] forState:UIControlStateNormal];
    else
        [likeButton setImage:[UIImage imageNamed:@"home_tl_ic_liked_nor"] forState:UIControlStateNormal];
    
    [likeButton setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
}

-(IBAction)shareClick:(id)sender
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"分享该动态给好友" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友",@"微信朋友圈", nil];
    actionsheet.tag = 4;
    [actionsheet showInView:self.view];
}

#pragma mark cellfor

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    XCJGroupPost_list * post = self.activities[indexPath.section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        switch (indexPath.row) {
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKCONTENTCELL" forIndexPath:indexPath];
                
            }
                break;
            case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKREICKTEXTCELL" forIndexPath:indexPath];
                
                UILabel* labelContent = (UILabel*)[cell viewWithTag:kAttributedLabelTag];
                if (labelContent == nil) {
                    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
                    labelContent.tag = kAttributedLabelTag;
                    labelContent.numberOfLines = 0;
                    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
                    labelContent.font = [UIFont systemFontOfSize:16.0f];
                    [cell addSubview:labelContent];
                    //  labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
                }
                labelContent.text = [NSString stringWithFormat:@"%@",post.content];
                [labelContent sizeToFit];
                
                [labelContent setWidth:300.0f];
                [labelContent setHeight:[self textHeight:[NSString stringWithFormat:@"%@",post.content]]];
                
                [labelContent setTop:0.0f];
                [labelContent setLeft:10.0f];
            }
                break;
            case 3:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKOPERATIONCELL" forIndexPath:indexPath];
                
                UIButton * buttonComment =(UIButton *)  [cell.contentView subviewWithTag:1];
                UIButton * buttonLike =(UIButton *)  [cell.contentView subviewWithTag:2];
                UIButton * buttonHSare =(UIButton *)  [cell.contentView subviewWithTag:3];
                UIView * lineView =[cell.contentView subviewWithTag:5];
                [lineView setHeight:0.5];
                [buttonComment setTitle:[NSString stringWithFormat:@"%d",post.replycount] forState:UIControlStateNormal];
                [buttonLike setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
                [self refreshbutton:buttonLike withdata:post];
                [buttonComment addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonLike addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonHSare addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
                
                
            }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKREICKTEXTCELL" forIndexPath:indexPath];
                UILabel* labelContent = (UILabel*)[cell viewWithTag:kAttributedLabelTag];
                if (labelContent == nil) {
                    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
                    labelContent.tag = kAttributedLabelTag;
                    labelContent.numberOfLines = 0;
                    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
                    labelContent.font = [UIFont systemFontOfSize:16.0f];
                    [cell addSubview:labelContent];
                    //  labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
                }
                labelContent.text = [NSString stringWithFormat:@"%@",post.content];
                [labelContent sizeToFit];
                
                [labelContent setWidth:300.0f];
                [labelContent setHeight:[self textHeight:[NSString stringWithFormat:@"%@",post.content]]];
                
                [labelContent setTop:0.0f];
                [labelContent setLeft:10.0f];
            }
                break;
            case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKOPERATIONCELL" forIndexPath:indexPath];
                UIButton * buttonComment =(UIButton *)  [cell.contentView subviewWithTag:1];
                UIButton * buttonLike =(UIButton *)  [cell.contentView subviewWithTag:2];
                UIButton * buttonHSare =(UIButton *)  [cell.contentView subviewWithTag:3];
                [buttonComment setTitle:[NSString stringWithFormat:@"%d",post.replycount] forState:UIControlStateNormal];
                [buttonLike setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
                [self refreshbutton:buttonLike withdata:post];
                [buttonComment addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonLike addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonHSare addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
                
            default:
                break;
        }
    }
    
    //TKUSERCELL TKCONTENTCELL  TKREICKTEXTCELL TKOPERATIONCELL
    
    /**
     *  row  0
     */
    if(indexPath.row == 0){ //通用
        cell = [tableView dequeueReusableCellWithIdentifier:@"TKUSERCELL" forIndexPath:indexPath];
        UIButton * _avatarButton = (UIButton *) [cell.contentView subviewWithTag:1];
        _avatarButton.layer.cornerRadius = 35/2;
        _avatarButton.layer.masksToBounds = YES;
        _avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarButton.layer.borderWidth = 2.0f;
        [_avatarButton addTarget:self action:@selector(seeUseinfoClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    // Configure the cell...
    cell.backgroundColor = [UIColor colorWithHex: 0xffefefef];
    return cell;
}

-(IBAction)seeUseinfoClick:(id)sender
{
    UIButton *buttonSender = (UIButton *)sender;
    UITableViewCell * cell = (UITableViewCell *)buttonSender.superview.superview.superview;
    XCJGroupPost_list * post = self.activities[ [self.tableviewself indexPathForCell:cell].section];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        
        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
        addUser.UserInfo = response;
        [self.navigationController pushViewController:addUser animated:YES];
        
    } withuid:post.uid];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = self.activities[indexPath.section];
    if (indexPath.row == 0) {
        UIButton * _avatarButton = (UIButton *) [cell.contentView subviewWithTag:1];
        UILabel * useName = (UILabel *) [cell.contentView subviewWithTag:2];
        UILabel * sendTime = (UILabel *) [cell.contentView subviewWithTag:3];
        sendTime.text = [tools timeLabelTextOfTime:post.time];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            if (response) {
                FCUserDescription * user = response;
                //内容
                if (user.headpic) {
                    [_avatarButton setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                }else{
                    [_avatarButton setImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
                }
                [useName setText:user.nick];
                [useName setTextColor:[tools colorWithIndex:[user.actor_level intValue]]];
                
            }
        } withuid:post.uid];
        
    }
    
    if (post.imageURL.length > 4 || post.excount > 0) {
        switch (indexPath.row) {
            case 1:
            {
                XCJContentTypesCell *contentCell = (XCJContentTypesCell *) cell;
                if (post.excount > 0) {
                    if (post.excountImages.count <= 0 && !contentCell.isloadingphotos) {
                        //check from networking
                        //查看是否有缓存
                        NSString * cacheKey = [NSString stringWithFormat:@"post.readex.%@",post.postid];
                        NSArray * cahceArray = [[EGOCache globalCache] plistForKey:cacheKey];
                        //            SLog(@"cahceArray :%@",cahceArray);
                        if (cahceArray && cahceArray.count > 0) {
                            NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                            [[cahceArray mutableCopy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                                [arrayURLS addObject:stringurl];
                            }];
                            post.excountImages = arrayURLS ;
                            contentCell.isloadingphotos = NO;
                        }else{
                            contentCell.isloadingphotos = YES;
                            //             [cell.imageListScroll showIndicatorViewBlue];
                            [[MLNetworkingManager sharedManager] sendWithAction:@"post.readex" parameters:@{@"postid":post.postid} success:^(MLRequest *request, id responseObject) {
                                if (responseObject) {
                                    NSDictionary  * result = responseObject[@"result"];
                                    NSArray * array = result[@"exdata"];
                                    if (array.count > 0) {
                                        [[EGOCache globalCache]  setPlist:[array mutableCopy] forKey:cacheKey];
                                    }
                                    NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                                        [arrayURLS addObject:stringurl];
                                    }];
                                    [post.excountImages removeAllObjects];
                                    [post.excountImages addObjectsFromArray:arrayURLS];
                                    //    [_tableView reloadData];
                                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                }
                                contentCell.isloadingphotos = NO;
                            } failure:^(MLRequest *request, NSError *error) {
                                contentCell.isloadingphotos = NO;
                            }];
                        }
                        
                    }
                }
                
                UIView * imageListScroll = [cell.contentView subviewWithTag:1];
                /*
                 *  多图模式
                 */
                if (post.excount > 0) {
                    [imageListScroll.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        ((UIView *)obj).hidden = YES;
                    }];
                    if (post.excountImages.count <= 0 ) {//&& !self.isloadingphotos
                        
                    }else{
                        //有数据
                        [post.excountImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString * stringurl = obj;
                            int row = idx/colNumber;
                            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(65*(idx%colNumber)+TITLE_jianxi*(idx%colNumber+1), (65+TITLE_jianxi) * row, 65, 65)];
                            iv.contentMode = UIViewContentModeScaleAspectFill;
                            iv.clipsToBounds = YES;
                            iv.tag = idx;
                            if([stringurl containString:@"assets-library://asset/"])
                            {
                                //系统图片
                                [iv setImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                                
                                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                                [library assetForURL:[NSURL URLWithString:stringurl]
                                         resultBlock:^(ALAsset *asset) {
                                             
                                             // Here, we have the asset, let's retrieve the image from it
                                             
                                             CGImageRef imgRef = asset.thumbnail;// [[asset defaultRepresentation] fullResolutionImage];
                                             
                                             /* Instead of the full res image, you can ask for an image that fits the screen
                                              CGImageRef imgRef  = [[asset defaultRepresentation] fullScreenImage];
                                              */
                                             // From the CGImage, let's build an UIImage
                                             UIImage *  imatgetemporal = [UIImage imageWithCGImage:imgRef];
                                             [iv setImage:imatgetemporal];
                                             
                                         } failureBlock:^(NSError *error) {
                                             
                                             // Something wrong happened.
                                             
                                         }];
                            }else {
                                [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                            }
                            iv.userInteractionEnabled = YES;
                            UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewmulitClick:)];
                            [iv addGestureRecognizer:tapges];
                            //                [iv setFullScreenImageURL:[NSURL URLWithString:stringurl]];
                            // add self view
                            [imageListScroll addSubview:iv];
                        }];
                        //            [self.imageListScroll layoutIfNeeded];
                    }
                    float imageviewHeight = (post.excount/colNumber)*65 +(post.excount/colNumber)*TITLE_jianxi;
                    if (post.excount%colNumber>0) {
                        imageviewHeight += TITLE_jianxi+65;
                    }
                    imageListScroll.frame = CGRectMake(10, 5, 255.0, imageviewHeight);
                    imageListScroll.hidden = NO;
                }else{
                    //单图模式
                    [imageListScroll.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        ((UIView *)obj).hidden = YES;
                    }];
                    int idx = 0 ;
                    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(TITLE_jianxi, 0, 300-TITLE_jianxi, 320)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    if([post.imageURL containString:@"assets-library://asset/"])
                    {
                        //系统图片
                        [iv setImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                        [library assetForURL:[NSURL URLWithString:post.imageURL]
                                 resultBlock:^(ALAsset *asset) {
                                     
                                     // Here, we have the asset, let's retrieve the image from it
                                     
                                     CGImageRef imgRef = asset.thumbnail;// [[asset defaultRepresentation] fullResolutionImage];
                                     
                                     /* Instead of the full res image, you can ask for an image that fits the screen
                                      CGImageRef imgRef  = [[asset defaultRepresentation] fullScreenImage];
                                      */
                                     // From the CGImage, let's build an UIImage
                                     UIImage *  imatgetemporal = [UIImage imageWithCGImage:imgRef];
                                     [iv setImage:imatgetemporal];
                                     
                                 } failureBlock:^(NSError *error) {
                                     
                                     // Something wrong happened.
                                     
                                 }];
                    }else {
                     [iv setImageWithURL:[NSURL URLWithString:post.imageURL] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    }
                    iv.userInteractionEnabled = YES;
                    UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewmulitClick:)];
                    [iv addGestureRecognizer:tapges];
                    [imageListScroll addSubview:iv];
                    imageListScroll.frame = CGRectMake(10, 5, 300-TITLE_jianxi, 320);
                    imageListScroll.hidden = NO;
                    
                    
                }
            }
                break;
            case 3:
            {
                
            }
                break;
            default:
                break;
        }
        
    }
}

-(void) SeeBigImageviewmulitClick:(id) sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    UITableViewCell * cell = (UITableViewCell *)buttonSender.superview.superview.superview.superview;
    XCJGroupPost_list * post = self.activities[ [self.tableviewself indexPathForCell:cell].section];
    if (post.excount > 0) {
        NSArray * arrayPhotos  = [IDMPhoto photosWithURLs:post.excountImages];
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arrayPhotos animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        //        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:buttonSender.tag];
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        
        [self presentViewController:browser animated:YES completion:nil];
    }else
    {
       IDMPhoto * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:post.imageURL]];
        photo.caption = [NSString stringWithFormat:@"%@",post.content];
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        //        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
