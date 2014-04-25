//
//  XCJSendManySelectedImageViewCOntrooler.m
//  laixin
//
//  Created by apple on 14-2-12.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJSendManySelectedImageViewCOntrooler.h"

#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import "UIButton+Bootstrap.h"
#import "CTAssetsPickerController.h"
#import "XCAlbumAdditions.h"
#import "XCJGroupPost_list.h"
#import "MinroadOperation.h"
#import "MMLocationManager.h"
#import "UINavigationController+SGProgress.h"

#define DISTANCE_BETWEEN_ITEMS  5.0
#define LEFT_PADDING            5.0
#define ITEM_WIDTH              65.0
#define TITLE_HEIGHT            40.0

@interface XCJSendManySelectedImageViewCOntrooler ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate,UITextViewDelegate>
{
    UIImageView * removeImageview;
}
@end

@implementation XCJSendManySelectedImageViewCOntrooler

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
    self.title = @"发表动态";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.TextMsg.textColor = [UIColor lightGrayColor];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(SendPhoto:)];
     self.navigationItem.rightBarButtonItem = item;
    
    __block NSUInteger page = 1;
    CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollPhotos.frame.size.height);
    [self.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ALAsset *asset =  obj;
        if (asset) {
            UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
            
            UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
            
            [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, 65, 65)];
            
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
            [recognizer setNumberOfTapsRequired:1];
            [recognizer setNumberOfTouchesRequired:1];
            [imageview addGestureRecognizer:recognizer];
            imageview.tag = idx;
            
            [self.scrollPhotos addSubview:imageview];
            
        }
    }];
    
    self.scrollPhotos.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * ([self.array count] + 1), pageSize.height);
    [self.button sendMessageStyle];
    
    [self.button addTarget:self action:@selector(locationClick:) forControlEvents:UIControlEventTouchUpInside];
    self.TextMsg.delegate = self;
}


-(void) tagSelected:(UITapGestureRecognizer * ) tap
{
    UIView * view = tap.view;
    removeImageview = (UIImageView *) view;
    UIActionSheet * alertalertss= [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"移除图片" otherButtonTitles:nil, nil];
    alertalertss.tag = 1;
    [alertalertss showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (removeImageview) {
            [self.array removeObjectAtIndex:(removeImageview.tag)];
            for (UIView * view in self.scrollPhotos.subviews) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    [view removeAllSubViews];
                    [view removeFromSuperview];
                }
            }
            //add
            [self.scrollPhotos reloadInputViews];
            self.scrollPhotos.contentSize = CGSizeMake(0, 0);
            
            __block NSUInteger page =  1;
            // add view
            CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollPhotos.frame.size.height);
            [self.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *asset =  obj;
                if (asset) {
                    UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
                    UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
                    
                    [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, 65, 65)];
                    imageview.userInteractionEnabled = YES;
                    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
                    [recognizer setNumberOfTapsRequired:1];
                    [recognizer setNumberOfTouchesRequired:1];
                    [imageview addGestureRecognizer:recognizer];
                    imageview.tag = idx;
                    [self.scrollPhotos addSubview:imageview];
                }
            }];
            self.scrollPhotos.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * ([self.array count] +1), pageSize.height);
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"说点什么吧"]) {
        textView.text = @"";
        self.TextMsg.textColor = [UIColor blackColor];
    }
    return YES;
}

-(IBAction)locationClick:(id)sender
{
    [self.button setImage:[UIImage imageNamed:@"ComposerLocationOn-flat"] forState:UIControlStateNormal];
    [self.button showIndicatorViewBlue];
    self.button.enabled = NO;
    
    [self.button setTitle:@"正在获取..." forState:UIControlStateNormal];
    [self.button setWidth:120.0f];
    
    [[MMLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
       NSString *  string = [NSString stringWithFormat:@"%f %f",locationCorrrdinate.latitude,locationCorrrdinate.longitude];
        self.button.enabled = YES;
        SLog(@"string :%@",string);
        
        if (string.length > 20) {
            NSString * straddress = [string substringToIndex:20];
            [self.button setTitle:straddress forState:UIControlStateNormal];
              [self.button setWidth:( straddress.length * 15.0f)];
        }else{
            [self.button setTitle:string forState:UIControlStateNormal];
              [self.button setWidth:( string.length * 15.0f)];
        }
      
        [self.button hideIndicatorViewBlueOrGary];
    } withAddress:^(NSString *addressString) {
        SLog(@"addressString :%@",addressString);
        self.button.enabled = YES;
        
        if (addressString.length > 29) {
            NSString * straddress = [addressString substringToIndex:29];
            [self.button setTitle:[NSString stringWithFormat:@"%@...",straddress] forState:UIControlStateNormal];
            [self.button setWidth:( straddress.length * 15.0f)];
        }else{
            [self.button setTitle:addressString forState:UIControlStateNormal];
            [self.button setWidth:( addressString.length * 15.0f)];
        }
        [self.button hideIndicatorViewBlueOrGary];
    }];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.TextMsg isFirstResponder]) {
        [self.TextMsg resignFirstResponder];
    }
}

-(IBAction)SendPhoto:(id)sender
{
    
    if ([self.TextMsg isFirstResponder]) {
        [self.TextMsg resignFirstResponder];
    }
    
    [SVProgressHUD showWithStatus:@"正在发表..."];
    
    NSDictionary * parames = @{@"gid":self.gID,@"content":self.TextMsg.text};
    //nick, signature,sex, birthday, marriage, height
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.add"  parameters:parames success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * result = responseObject[@"result"];
            [SVProgressHUD dismiss];
            NSString *postID = [tools getStringValue:result[@"postid"] defaultValue:@""];
            if ([postID intValue ] > 0) {
                [tools SetMaxPostID:postID];
                XCJGroupPost_list *glist = [[XCJGroupPost_list alloc] init];
                glist.postid = postID;
                glist.imageURL = @"";
                glist.content = self.TextMsg.text;
                glist.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
                glist.ilike = NO;
                glist.like = 0;
                glist.excount = self.array.count;
                glist.replycount = 0;
                glist.group_id = self.gID;
                glist.time = [[NSDate date] timeIntervalSinceNow];// [NSDate
                {
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    glist.comments = array;
                }
                {
                    
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    [self.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        ALAsset *asset =  obj;
                        if (asset) {
                            NSURL * url = [asset.defaultRepresentation url];
//                            UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
                            [array addObject:[NSString stringWithFormat:@"%@",url]];
//                            [array addObject:image];
                            /**
                             *  添加到上传队列
                             */
                            [[MinroadOperation sharedMinroadOperation] addOperation:@{@"url":url,@"postid":postID,@"asset":asset}];
                        }                        
                    }];
                    glist.excountImages = array;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartPostUploadimages" object:@([array count])];

                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StartRefershNewPostInfo" object:glist];
                
//                [_needRefreshViewController.activities insertObject:glist atIndex:0];
//                [_needRefreshViewController.cellHeights insertObject:@0 atIndex:0];
//                [_needRefreshViewController reloadSingleActivityRowOfTableView:0 withAnimation:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [UIAlertView showAlertViewWithMessage:@"发送失败"];

            }
        }
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"发送失败"];
    }];
}

- (IBAction)addPhotoClick:(id)sender {
    
    if ([self.TextMsg isFirstResponder]) {
        [self.TextMsg resignFirstResponder];
    }
    
    if (self.array.count >= 21) {
        [UIAlertView showAlertViewWithMessage:@"最多只能选21张照片"];
        return;
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.navigationBar.barTintColor  = [UIColor colorWithRed:48.0/255.0 green:167.0/255.0 blue:255.0/255.0 alpha:1.0];
    picker.navigationBar.translucent = YES;
    picker.navigationBar.tintColor  = [UIColor whiteColor];
    picker.navigationBarHidden = NO;
    
    picker.maximumNumberOfSelection = 21-self.array.count;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    // only allow video clips if they are at least 5s
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 1;
        } else {
            return YES;
        }
    }];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
//    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"添加照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
//    [sheet showInView:self.view];
}

/*- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.array.count >= 21) {
        [UIAlertView showAlertViewWithMessage:@"最多只能选21张照片"];
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                camera.delegate = self;
                camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:camera animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.navigationBar.barStyle = UIBarStyleBlack;
            picker.navigationBar.barTintColor  = [UIColor colorWithRed:48.0/255.0 green:167.0/255.0 blue:255.0/255.0 alpha:1.0];
            picker.navigationBar.translucent = YES;
            picker.navigationBar.tintColor  = [UIColor whiteColor];
            picker.navigationBarHidden = NO;
            
            picker.maximumNumberOfSelection = 20-self.array.count;
            picker.assetsFilter = [ALAssetsFilter allAssets];
            // only allow video clips if they are at least 5s
            picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
                if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                    NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
                    return duration >= 1;
                } else {
                    return YES;
                }
            }];     
            
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
}*/


- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        __block NSUInteger page = self.array.count + 1;
        [self.array addObjectsFromArray:assets];
        // add view
        CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollPhotos.frame.size.height);
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *asset =  obj;
            if (asset) {
                UIImage * image  = [UIImage imageWithCGImage:asset.thumbnail];
                UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
                
                [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, 65, 65)];
                
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
                [recognizer setNumberOfTapsRequired:1];
                [recognizer setNumberOfTouchesRequired:1];
                [imageview addGestureRecognizer:recognizer];
                imageview.tag = idx;
                
                [self.scrollPhotos addSubview:imageview];
            }
        }];
        self.scrollPhotos.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) *  ([self.array count] +1), pageSize.height);
    }
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    
   /* UIImage *image = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NSURL *imageRefURL = [theInfo valueForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
    void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset)
    {
        if (asset != nil)
        {
            NSDictionary *metadata = [[asset defaultRepresentation] metadata];
            SLog(@"metadata = %@",metadata);
            NSDictionary *exif = [metadata objectForKey:@"{Exif}"];
            SLog(@"exif = %@",exif);
            
        } else
        {
            SLog(@"ASSET was nil");
        }
    };
    
    [assetLibrary assetForURL:imageRefURL
                  resultBlock:ALAssetsLibraryAssetForURLResultBlock
                 failureBlock:^(NSError *error){
                     SLog(@"[ERROR] error: %@",error);
                 }];*/
    [picker dismissViewControllerAnimated:NO completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
