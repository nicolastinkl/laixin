//
//  XCJSelfPrivatePhotoViewController.m
//  laixin
//
//  Created by apple on 3/12/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSelfPrivatePhotoViewController.h"

#import "XCAlbumAdditions.h"
#import "LXAPIController.h"
#import "MLNetworkingManager.h"
#import "XCJGroupPost_list.h"
#import "XCJMessageReplyInfoViewController.h"
#import "FCUserDescription.h"
#import "UIImage+WebP.h"
#import "MLTapGrayView.h"
#import "UITableViewCell+TKCategory.h"
#import "DAImageResizedImageView.h"
#import "UIButton+Bootstrap.h"
#import "PayPellog.h"
#import "UIImage+Resize.h"
#import "IDMPhotoBrowser.h"



#define DISTANCE_BETWEEN_ITEMS  8.0
#define LEFT_PADDING            8.0
#define ITEM_WIDTH              96.0

@interface XCJSelfPrivatePhotoViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSMutableArray * dataSource;
    
    NSMutableArray * dataSource_imageurls;
    
    UIActionSheet * sheetDel;
    
    int deleteIndex;
}
@end

@implementation XCJSelfPrivatePhotoViewController

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
    {
        
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource =array;
    }
    
    {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        dataSource_imageurls =array;
        
    }
    self.title = @"私密相册"; 
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_bottom_up_nor"] style:UIBarButtonItemStyleDone target:self action:@selector(AddPhoto:)];
    
    UIScrollView * scrollview = (UIScrollView *) [self.view subviewWithTag:1];
    if (IS_4_INCH) {
        [scrollview setTop:0];
    }
    
    UIView * viewadd =  [self.view subviewWithTag:2];
    if([self.privateUID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
    {
        [scrollview setHeight:(APP_SCREEN_HEIGHT - 50)];
        UIButton * button = (UIButton *) [viewadd subviewWithTag:3];
        [button sendMessageStyle];
        [button addTarget:self action:@selector(AddPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [viewadd setTop:(APP_SCREEN_HEIGHT - 50)];
    }else{
        [scrollview setHeight:APP_SCREEN_HEIGHT ];
        [viewadd setTop:APP_SCREEN_HEIGHT];
        
        
        /*判断是否已经加入 小妹购货车*/
        
        [self EchorightItem];
        
    }
    
     if([self.privateUID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
     {
         NSString * priKey = [NSString stringWithFormat:@"PrivatePhotoList_%@",self.privateUID];
         NSArray * arrayphoto = nil;//[[EGOCache globalCache] plistForKey:priKey];
         
         if (arrayphoto && arrayphoto.count > 0) {
             dataSource = [arrayphoto mutableCopy];
             [self initScrollview];
         }else{
             [self.view showIndicatorViewLargeBlue];
             
             [[MLNetworkingManager sharedManager] sendWithAction:@"album.read" parameters:@{@"uid":self.privateUID,@"count":@"10000"} success:^(MLRequest *request, id responseObject) {
                 NSDictionary * result = responseObject[@"result"];
                 NSArray * medias = result[@"medias"];
                 if (medias > 0) {
                     [[EGOCache globalCache] setPlist:[medias mutableCopy] forKey:priKey withTimeoutInterval:60*5];
                     dataSource = [NSMutableArray arrayWithArray:medias];
                     [self initScrollview];
                 }else{
                     [self showErrorText:@"没有私密照片"];
                 }
                 [self.view hideIndicatorViewBlueOrGary];
             } failure:^(MLRequest *request, NSError *error) {
                 [self showErrorText:@"网络加载失败,请检查网络设置"];
                 [self.view hideIndicatorViewBlueOrGary];
             }];
             
             
         }
     }else{
         [self.view showIndicatorViewLargeBlue];
         
         [[MLNetworkingManager sharedManager] sendWithAction:@"album.read" parameters:@{@"uid":self.privateUID,@"count":@"10000"} success:^(MLRequest *request, id responseObject) {
             NSDictionary * result = responseObject[@"result"];
             NSArray * medias = result[@"medias"];
             if (medias > 0) {
                 dataSource = [NSMutableArray arrayWithArray:medias];
                 [self initScrollview];
             }else{
                 [self showErrorText:@"没有私密照片"];
             }
             [self.view hideIndicatorViewBlueOrGary];
         } failure:^(MLRequest *request, NSError *error) {
             [self showErrorText:@"网络加载失败,请检查网络设置"];
             [self.view hideIndicatorViewBlueOrGary];
         }];
     }
   
}

-(void) EchorightItem
{
    NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
    self.navigationItem.rightBarButtonItem = nil;
    if (![array containsObject:self.privateUID])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pictureHeartLike_0"] style:UIBarButtonItemStyleDone target:self action:@selector(LikeClick:)];
    }
    else
    {
        
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pictureHeartLike_1"] style:UIBarButtonItemStyleDone target:self action:@selector(unLikeClick:)];
    }
}


-(IBAction)attentClick:(id)sender
{
    NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
    if (array) {
        if ([array containsObject:self.privateUID]) {
            //如果存在 就移除
            [array removeObject:[NSString stringWithFormat:@"%@",self.privateUID]];
            
            [self.navigationItem.rightBarButtonItem.customView showAnimatingLayer];
            
            [[EGOCache globalCache] setPlist:array forKey:KSingerCount];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self EchorightItem];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"remove"];
            });
        }else{
            //如果不存在  就加入
            
            [array addObject:[NSString stringWithFormat:@"%@",self.privateUID]];
            
            [[EGOCache globalCache] setPlist:array forKey:KSingerCount];
            [self.navigationItem.rightBarButtonItem.customView showAnimatingLayer];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self EchorightItem];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
            });
        }
    }else{
        
        //如果不存在  就加入
        [[EGOCache globalCache] setPlist:[NSArray arrayWithObject:self.privateUID] forKey:KSingerCount];
        [self.navigationItem.rightBarButtonItem.customView showAnimatingLayer];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self EchorightItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
        });
        
        
    }
}



-(IBAction)LikeClick:(id)sender
{
    [self attentClick:nil];
}

-(IBAction)unLikeClick:(id)sender
{
    [self attentClick:nil];
}



-(void) initScrollview
{
    if (dataSource.count  == 0) {
        [self showErrorText:@"还没有照片"];
    }else{
        [self showErrorText:@""];
    }
    
    [dataSource_imageurls removeAllObjects];
    UIScrollView * scrollview = (UIScrollView *) [self.view subviewWithTag:1];
    for (UIView * view in scrollview.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeAllSubViews];
            [view removeFromSuperview];
        }
    }
    //add
    [scrollview reloadInputViews];
    scrollview.contentSize = CGSizeMake(0, 0);
//    scrollview.showsVerticalScrollIndicator = YES;
//    __block NSUInteger page = dataSource.count;
    // add view
//    CGSize pageSize = CGSizeMake(scrollview.width, 0);
    [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        privatePhotoListInfo * photoinfo =  [privatePhotoListInfo turnObject:obj];
        if (photoinfo) {
            [dataSource_imageurls addObject:photoinfo.picture];
            int row = idx/3;
            UIImageView* imageview = [[UIImageView alloc] init];
            [imageview setFrame:CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1),LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row, ITEM_WIDTH, ITEM_WIDTH)];
            imageview.contentMode = UIViewContentModeScaleAspectFill;
            
//            [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, ITEM_WIDTH, ITEM_WIDTH)];
            
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
            [recognizer setNumberOfTapsRequired:1];
            [recognizer setNumberOfTouchesRequired:1];
            [imageview addGestureRecognizer:recognizer];
            
            if([self.privateUID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
            {
                UILongPressGestureRecognizer * longizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longnicger:)];
                longizer.numberOfTouchesRequired = 1;
                [imageview addGestureRecognizer:longizer];
            }
            imageview.tag = idx;
            
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:photoinfo.picture Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
            [scrollview addSubview:imageview];
        }
    }];
    
    int row = dataSource.count/3 ;
    
    scrollview.contentSize = CGSizeMake(scrollview.width,LEFT_PADDING + (ITEM_WIDTH + DISTANCE_BETWEEN_ITEMS) * (row +1 ) );
    
}

-(IBAction)longnicger:(id)sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    deleteIndex = buttonSender.tag;    
    if (sheetDel == nil) {
        sheetDel = [[UIActionSheet alloc] initWithTitle:@"删除照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
        sheetDel.tag = 1;
        [sheetDel showInView:self.view];
    }
}

-(IBAction)tagSelected:(id)sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    if (dataSource_imageurls.count > 0) {
        NSArray * arrayPhotos  = [IDMPhoto photosWithURLs:dataSource_imageurls];
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arrayPhotos animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        //        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:buttonSender.tag];
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)takePhotoClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
        camera.delegate = self;
        camera.allowsEditing = YES;
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:camera animated:YES completion:nil];
    }
}

- (void)choseFromGalleryClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
        photoLibrary.allowsEditing = YES;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    
    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerEditedImage];
    //upload image
    
    [self performSelector:@selector(uploadImage:) withObject:postImage];
}

-(void) uploadImage:(UIImage * ) image
{
    [SVProgressHUD showWithStatus:@"正在上传..."];
 
    NSString * keyID =[NSString stringWithFormat:@"uploadtoken_privatePhoto_%@",self.privateUID];
    NSString  * oldToken = [[EGOCache globalCache] stringForKey:keyID];
    if (oldToken && oldToken.length > 0) {
        //success
        [self uploadimagewithImage:image token:oldToken];
    }else{
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
            if (response) {
                NSString * token =  response[@"token"];
                if (token) {
                    [[EGOCache globalCache] setString:token forKey:keyID withTimeoutInterval:60*60];
                    //success
                    [self uploadimagewithImage:image token:token];
                }else{
                    //fail
                    [self taskMethodDidFailed];
                }
            }
        } withParems:[NSString stringWithFormat:@"upload/UserExMedia?sessionid=%@&userid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid],self.privateUID]];
    }

}

-(void) uploadimagewithImage:(UIImage*) image token:(NSString*) token  {
    
//    int Wasy = image.size.width/APP_SCREEN_WIDTH;
//    int Hasy = image.size.height/APP_SCREEN_HEIGHT;
//    int quality = Wasy/2;
//    UIImage * newimage = [[image copy] resizedImage:CGSizeMake(APP_SCREEN_WIDTH*Wasy/quality, APP_SCREEN_HEIGHT*Hasy/quality) interpolationQuality:kCGInterpolationDefault];
    UIImage * newimage = [[image copy] resizedImage:CGSizeMake(640,640) interpolationQuality:kCGInterpolationDefault];
    NSData * FileData = UIImageJPEGRepresentation(newimage, 0.5);
    if (!FileData) {
        FileData = UIImageJPEGRepresentation(image, 0.5);
    }
    if (FileData) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
        [parameters setValue:token  forKey:@"token"];
        [parameters setValue:@(1) forKey:@"x:filetype"];
        [parameters setValue:@"" forKey:@"x:length"];
        [parameters setValue:@"" forKey:@"x:text"];
//        [parameters setValue:postid forKey:@"x:postid"];
        AFHTTPRequestOperation * operation =  [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // 1是图片，2是声音，3是视频
            // 图片压缩处理
            //                NSData *FileData  =  [UIImage imageToWebP:newimage quality:75.0];
            [formData appendPartWithFileData:FileData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SLog(@"responseObject :%@",responseObject);
            if ([responseObject[@"errno"] intValue] == 0) {
                //成功调用
                [self taskMethodDidFinish:responseObject];
            }else{
                //失败调用
                [self taskMethodDidFailed];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //失败调用
            [self taskMethodDidFailed];
        }];
        [operation start];
    }else{
        [self taskMethodDidFailed];
    }
}

-(void) taskMethodDidFinish:(id)responseObject
{
    [SVProgressHUD dismiss];
    //,"result":{"did":16,"url":"http://kidswant.u.qiniudn.com/FkLv25QuevBwCnXyIoIrKD-S2IHx"}
    
    if (responseObject) {
        NSDictionary * result =  responseObject[@"result"];
        NSString * did = [DataHelper getStringValue:result[@"did"] defaultValue:@""];
        NSString * url = [DataHelper getStringValue:result[@"url"] defaultValue:@""];
//        privatePhotoListInfo * photoinfo =  [[privatePhotoListInfo alloc] init];
//        photoinfo.did = did;
//        photoinfo.picture = url;
//        photoinfo.uid = self.privateUID;
//        photoinfo.text = @"";
//        photoinfo.type = @"1";
        
        /*
         "picture":"http://kidswant.u.qiniudn.com/FpjyuFcobuiOCziqNptk1vZV7MOW",
         "uid":5,
         "did":5,
         "text":"b6RZt0MXicse7o9",
         "height":1504,
         "width":2256,
         "time":1394591837.0,
         "type":"pic"*/
        NSDictionary * jsondict = @{@"picture":url,@"did":did,@"uid":self.privateUID,@"text":@"",@"height":@"",@"width":@"",@"time":@"1394591837.0",@"type":@"pic"};
        
        [dataSource insertObject:jsondict atIndex:0];
        [self initScrollview];
        
    }
    
}

-(void) taskMethodDidFailed
{
    [UIAlertView showAlertViewWithMessage:@"上传失败"];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            //delete
            //album.delete(did)
            NSDictionary * obj = [dataSource objectAtIndex:deleteIndex];
            if (obj) {
                
                privatePhotoListInfo * photoinfo =  [privatePhotoListInfo turnObject:obj];
                [SVProgressHUD showWithStatus:@"正在删除中..."];
                [[MLNetworkingManager sharedManager] sendWithAction:@"album.delete" parameters:@{@"did":photoinfo.did} success:^(MLRequest *request, id responseObject) {
                    [dataSource removeObjectAtIndex:deleteIndex];
                    [self initScrollview];
                    [UIAlertView showAlertViewWithMessage:@"删除成功"];
                } failure:^(MLRequest *request, NSError *error) {
                    [UIAlertView showAlertViewWithMessage:@"删除失败"];
                }];
            }else{
                [UIAlertView showAlertViewWithMessage:@"删除失败"];
            }
            
        }
        sheetDel = nil;
    }else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [self takePhotoClick];
        }else if(buttonIndex == 1)
        {
            [self choseFromGalleryClick];
        }
    }
   
}

-(IBAction)AddPhoto:(id)sender
{
    UIActionSheet *  sheet = [[UIActionSheet alloc] initWithTitle:@"添加私密照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选取", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
