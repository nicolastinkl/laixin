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
#import "XCJCreateChatNaviController.h"

@interface XCJHomeDynamicViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,XCJGroupMenuViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{

    XCJGroupMenuView  * menuView;
    NSArray * JsonArray;
}
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
    
    
    
	// Do any additional setup after loading the view.
    [self initHomeData];
    
    [self.refreshView beginRefreshing];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.groupInfo.gbadgeNumber intValue] > 0) {
        self.groupInfo.gbadgeNumber = @(0);
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
    }
}

- (IBAction)openGroupClick:(id)sender {
    XCJDomainsViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJDomainsViewController"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewContr];
    viewContr.title = @"我的群组";
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)   initHomeData
{
    //    [self.refreshControl beginRefreshing];
    //    [self setupLocationManager];
 
    /**
     *  gid,content
     */
    if (_Currentgid == nil) {
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.my"  parameters:@{} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * groupsDict =  groups[@"groups"];
                if (groupsDict && groupsDict.count > 0 ) {
                    [groupsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        _Currentgid = [tools getStringValue:obj[@"gid"] defaultValue:@""];
                        
                        /*  add group
                         NSDictionary * parames = @{@"content":@"来上班5天迟到4次然后人就不见了",@"gid":gid};
                         [[MLNetworkingManager sharedManager] sendWithAction:@"post.add"  parameters:parames success:^(MLRequest *request, id responseObject) {
                         //    postid = 12;
                         } failure:^(MLRequest *request, NSError *error) {
                         }];*/
                    }];
//                    [self postGetActivitiesWithLastID:0];
                }

            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }else
    {
//        [self postGetActivitiesWithLastID:0];
    }
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
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出群组"
                                               otherButtonTitles:@"设置群组名称", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
}

-(IBAction)postAction:(id)sender
{
    
   
    if (menuView.top == 0) {
        // hidden  _arrowImageView.transform = CGAffineTransformMakeRotation( M_PI);
        
        [UIView animateWithDuration:.3f animations:^{
            menuView.alpha = 0;
            menuView.top = -600;
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(M_PI/2);
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
//            self.ShowMenubutton.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
        }];
        
    }
    /*
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
     UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
     photoLibrary.delegate = self;
     photoLibrary.allowsEditing = YES;
     photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
     [self presentViewController:photoLibrary animated:YES completion:nil];
     }
     */
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
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.delete" parameters:@{@"gid":self.Currentgid} success:^(MLRequest *request, id responseObject) {
                        if (responseObject) {
                            [self.groupInfo MR_deleteEntity];
                            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                            [SVProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                        [SVProgressHUD dismiss];
                        [SVProgressHUD showErrorWithStatus:@"退出失败"];
                    }];
                });
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
                    [SVProgressHUD showErrorWithStatus:@"设置失败"];
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
                    [SVProgressHUD showErrorWithStatus:@"设置失败"];
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
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case 3:
        {
            //拍照
            
            switch (buttonIndex) {
                case 0:{
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                        camera.delegate = self;
                        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                        camera.allowsEditing = YES;
                        [self presentViewController:camera animated:YES completion:nil];
                    }
                }
                    break;
                case 1:{
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
                        photoLibrary.delegate = self;
                        photoLibrary.allowsEditing = YES;
                        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        [self presentViewController:photoLibrary animated:YES completion:nil];
                    }
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

- (void)postGetActivitiesWithLastID:(NSInteger)lastID
{
    if (_Currentgid == nil) {
        _Currentgid  = @"2";
    }
    if (_Currentgid == nil) {
        [self failedGetActivitiesWithLastID:0];
        return;
    }
    //put here to GCD
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
       
        /* get all list data*/
        NSDictionary * parames ;
        if(lastID == 0)
        {
            parames = @{@"gid":_Currentgid,@"pos":@0,@"count":@"20"};
        }else{
            parames = @{@"gid":_Currentgid,@"pos":@(self.activities.count),@"count":@"20"};
        }
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
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
            }else{
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    });
    
}


//点击赞按钮
- (void)clickLikeButton:(UIButton *)likeButton onActivity:(XCJGroupPost_list *)activity{

    likeButton.enabled = NO;
    //赞
    if (!activity.ilike) {
      
        
        NSDictionary * parames = @{@"postid":activity.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
            [activity.likeUsers addObject:[[LXAPIController sharedLXAPIController] currentUser]];
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
                    [activity.likeUsers removeObject:aUser];
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

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL * url = [self uploadContent:theInfo];
    PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
    if (_Currentgid == nil) {
        _Currentgid = @"2";
    }
    postVC.gID = _Currentgid;
    postVC.filePath = [url copy];
    postVC.uploadKey = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@",url]];
    postVC.postImage = [theInfo objectForKey:UIImagePickerControllerEditedImage];
    
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
        NSLog(@"Upload Path: %@", filePath);
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
