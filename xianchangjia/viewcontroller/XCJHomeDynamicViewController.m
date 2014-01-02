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


@interface XCJHomeDynamicViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    NSArray * JsonArray;
    NSString * Currentgid;
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
	// Do any additional setup after loading the view.
    
    
    if (![USER_DEFAULT objectForKey:KeyChain_Laixin_account_sessionid]) {
        [self OpenLoginview:nil];
    }else{
        [self initHomeData];
        //        [self.view showIndicatorViewLargeBlue];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(uploadDataWithLogin:) name:@"MainappControllerUpdateData" object:nil];
    [self runSequucer];
   
}
-(void) uploadDataWithLogin:(NSNotification *) notify
{
    [self initHomeData];
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

-(void)   initHomeData
{
    //    [self.refreshControl beginRefreshing];
    //    [self setupLocationManager];
 
    /**
     *  gid,content
     */
    NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
    NSDictionary * parames = @{@"sessionid":sessionid};
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.my"  parameters:parames success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * groups = responseObject[@"result"];
            NSArray * groupsDict =  groups[@"groups"];
            if (groupsDict && groupsDict.count > 0 ) {
                [groupsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Currentgid = [tools getStringValue:obj[@"gid"] defaultValue:@""];
                    
                    /*  add group
                     NSDictionary * parames = @{@"content":@"来上班5天迟到4次然后人就不见了",@"gid":gid};
                     [[MLNetworkingManager sharedManager] sendWithAction:@"post.add"  parameters:parames success:^(MLRequest *request, id responseObject) {
                     //    postid = 12;
                     } failure:^(MLRequest *request, NSError *error) {
                     }];*/
                }];
            }
        }
    } failure:^(MLRequest *request, NSError *error) {
    }];
     
    [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //首次登陆返回的用户信息
        NSDictionary * userinfo = responseObject[@"result"];
        LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
        [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
        [USER_DEFAULT setObject:currentUser.uid forKey:KeyChain_Laixin_account_user_id];
        [USER_DEFAULT setObject:currentUser.headpic forKey:KeyChain_Laixin_account_user_headpic];
        [USER_DEFAULT setObject:currentUser.nick forKey:KeyChain_Laixin_account_user_nick];
        [USER_DEFAULT setObject:currentUser.signature forKey:KeyChain_Laixin_account_user_signature];
        [USER_DEFAULT synchronize];
        
    } failure:^(MLRequest *request, NSError *error) {
    }];
    
    [self runSequucer];
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


-(IBAction)postAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
        photoLibrary.allowsEditing = YES;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}


#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Button at index: %d clicked\nIt's title is '%@'", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
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

- (void)postGetActivitiesWithLastID:(NSInteger)lastID
{
    if (Currentgid == nil) {
        Currentgid  = @"2";
    }
    if (Currentgid == nil) {
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
            parames = @{@"gid":Currentgid,@"pos":@0,@"count":@"20"};
        }else{
            parames = @{@"gid":Currentgid,@"pos":@(self.activities.count),@"count":@"20"};
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
     } withuid:uid];
    infoview.title = @"详细资料";
    [self.navigationController pushViewController:infoview animated:YES];
    
}

//点击当前activity的发布者头像
- (void)clickAvatarButton:(UIButton *)avatarButton onActivity:(XCJGroupPost_list *)activity
{
    XCJUserInfoController * infoview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJUserInfoController"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id result, NSError * error) {
        infoview.UserInfo = result;
    } withuid:activity.uid];
    infoview.title = @"详细资料";
    [self.navigationController pushViewController:infoview animated:YES];
    
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    PostActivityViewController *postVC = [[PostActivityViewController alloc]init];
//    postVC.sceneID = self.sceneID;
//    postVC.postImage = [theInfo objectForKey:UIImagePickerControllerEditedImage];
//    postVC.needRefreshViewController = self;
//    [self.navigationController pushViewController:postVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
