//
//  XCJSelfPhotoViewController.m
//  laixin
//
//  Created by apple on 14-2-8.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJSelfPhotoViewController.h"
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

@interface XCJSelfPhotoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray * dataSource;
    UIImage * ImageFile;
    NSString * TokenAPP;
    
    AFHTTPRequestOperation *  operation;
}

@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL isDontNeedLazyLoad;

@end

@implementation XCJSelfPhotoViewController

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
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    dataSource =array;
    self.isDontNeedLazyLoad = NO;
    UILabel * label_name = (UILabel *)[self.tableView.tableHeaderView viewWithTag:1];
    UILabel * label_sign = (UILabel *)[self.tableView.tableHeaderView viewWithTag:2];
    UIImageView * imageIcon = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:3];
    UIImageView * imagebg = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:4];

    
    
    if (!self.userID || [self.userID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]) {
        self.userID           = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
        label_name.text       = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
        //[LXAPIController sharedLXAPIController].currentUser.nick;
        label_sign.text       = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];

        UIImage  *chacheImage = [[EGOCache globalCache] imageForKey:@"myphotoBgImage"];
        if (chacheImage) {
            [imagebg setImage:chacheImage];
        }else{
            //[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick] [LXAPIController sharedLXAPIController].currentUser.background_image
            [imagebg setImageWithURL:[NSURL URLWithString:[DataHelper getStringValue:[LXAPIController sharedLXAPIController].currentUser.background_image defaultValue:@""]] placeholderImage:[UIImage imageNamed:@"opengroup_profile_cover"]];
        }
        [imageIcon setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        NSString  * plistKeyName =[NSString stringWithFormat:@"user.posts_%@", self.userID];
//        [[EGOCache globalCache] removeCacheForKey:plistKeyName];
        if ([[EGOCache globalCache] plistForKey:plistKeyName] != nil) {
            NSArray *array = [[EGOCache globalCache] plistForKey:plistKeyName];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                //是当前用户
                [dataSource addObject:post];
            }];

        } else{
            // get json data from networking
            [self initDataSourcewithBeforeID:@""];
        }
        
//        NSString * jsonData = [[EGOCache globalCache] stringForKey:@"MyPhotoCache"];
//        if (jsonData.length > 150) {
//            // parse
//            NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSDictionary * responseObject =[data  objectFromJSONData] ;
//            NSDictionary * dicreult = responseObject[@"result"];
//            NSArray * array = dicreult[@"posts"];
//            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
//                //是当前用户
//                [dataSource addObject:post];
//            }];
//            
//        }
   
    }
    else{
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id userdes, NSError *error) {
            FCUserDescription * localdespObject = userdes;
            label_name.text = localdespObject.nick;
            label_sign.text = localdespObject.signature;
            [imagebg setImageWithURL:[NSURL URLWithString:[DataHelper getStringValue:localdespObject.background_image defaultValue:@""]] placeholderImage:[UIImage imageNamed:@"opengroup_profile_cover"]];
             [imageIcon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:localdespObject.headpic Size:160]]];
        } withuid:self.userID];
        NSString  * plistKeyName =[NSString stringWithFormat:@"user.posts_%@", self.userID];

        if ([[EGOCache globalCache] plistForKey:plistKeyName] != nil) {
            NSArray *array = [[EGOCache globalCache] plistForKey:plistKeyName];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                //是当前用户
                [dataSource addObject:post];
            }];

        }else
            [self initDataSourcewithBeforeID:@""];
    }
}

-(void) initDataSourcewithBeforeID:(NSString *) beforeid
{
    __block Boolean ISNewData = NO;
    NSDictionary * parems = @{@"uid":self.userID,@"count":@"50",@"before":beforeid};
    if (beforeid.length <=0) {
        parems = @{@"uid":self.userID,@"count":@"50"};
        ISNewData = YES;
    }
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.posts" parameters:parems success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * dicreult = responseObject[@"result"];
            NSArray * array = dicreult[@"posts"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                [dataSource addObject:post];
            }];
            [self.tableView reloadData];
            if (array.count < 50) {
                self.isDontNeedLazyLoad = YES;
            }
            self.isLoading = NO;
            if (array.count > 0) {
                if ([self.userID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]) {
                    if(beforeid.length <= 0)
                        [[EGOCache globalCache] setString:[responseObject JSONString] forKey:@"MyPhotoCache" withTimeoutInterval:60 ];
                    // init with that...
                }
                
                NSString  * plistKeyName =[NSString stringWithFormat:@"user.posts_%@", self.userID];
                SLog(@"plistKeyName :%@",plistKeyName);
                if ([[EGOCache globalCache] plistForKey:plistKeyName] == nil) {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:array];
                    [[EGOCache globalCache] setPlist:arr forKey:plistKeyName withTimeoutInterval:60*5];
                     SLog(@"not  arr     %d" ,arr.count);
                }
                else {
                    NSArray *arrayss = [[EGOCache globalCache] plistForKey:plistKeyName];

                    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:arrayss];
                    [arr addObjectsFromArray:array];
                     SLog(@" have  arr    %d" ,arr.count);
                    [[EGOCache globalCache] setPlist:arr forKey:plistKeyName withTimeoutInterval:60*5];
                }
            }
        }
    } failure:^(MLRequest *request, NSError *error) {
        self.isLoading = NO;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{   //拍照
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
                photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                photoLibrary.allowsEditing = YES;
                [self presentViewController:photoLibrary animated:YES completion:nil];
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self performSelectorInBackground:@selector(uploadContent:) withObject:theInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)uploadContent:(NSDictionary *)theInfo {
    UIImage * image = [theInfo objectForKey:UIImagePickerControllerEditedImage];
    UIImageView * imagebg = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:4];
    [imagebg setImage:image];
    ImageFile  = image;
    [[EGOCache globalCache] setImage:image forKey:@"myphotoBgImage"];
    
    [SVProgressHUD showWithStatus:@"正在上传背景..."];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
        if (response) {
            NSString * token = response[@"token"];//  [response objectForKey:@"token"];
            if (token && token.length > 10) {
                TokenAPP = token;
                [self uploadImage:ImageFile token:token];
            }else{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
                [alert show];
            }
        }
    } withParems:[NSString stringWithFormat:@"upload/BackgroundImg?sessionid=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    
}


-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    NSData * formDataddd = [UIImage imageToWebP:filePath quality:75];
    operation  = [manager POST:@"http://up.qiniu.com" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        [formData appendPartWithFileData:formDataddd name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            
            NSString * stringURL =  [tools getStringValue:[responseObject objectForKey:@"url"] defaultValue:@""];
            [USER_DEFAULT setObject:stringURL forKey:KeyChain_Laixin_account_user_backgroupbg];
            [USER_DEFAULT synchronize];
            [SVProgressHUD dismiss];
            //nick, signature,sex, birthday, marriage, height
            //            NSDictionary * parames = @{@"headpic":stringURL};
            //            [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //
            //            } failure:^(MLRequest *request, NSError *error) {
            //            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { 
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [SVProgressHUD showWithStatus:@"正在上传头像..."];
        [self uploadImage:ImageFile token:TokenAPP];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"selfphotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel * label_time = (UILabel *) [cell.contentView subviewWithTag:3];
    UILabel * label_address = (UILabel *) [cell.contentView subviewWithTag:4];

    
    // Configure the cell...
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelimage_text = (UILabel *) [cell.contentView subviewWithTag:2];
    
    UILabel * label_text = (UILabel *) [cell.contentView subviewWithTag:5];
    UILabel * label_photoNumber = (UILabel *) [cell.contentView subviewWithTag:9];
    XCJGroupPost_list * post = dataSource[indexPath.row];
    
    if (post.excount > 0) {
        label_text.hidden = YES;
        imageview.hidden = NO;
        labelimage_text.hidden = NO;
        [imageview setImage:nil];
        [labelimage_text setHeight:60];
        [labelimage_text setWidth:177];
        label_photoNumber.text = [NSString stringWithFormat:@"共%d张",post.excount];
        labelimage_text.text = post.content;
    }else{
        label_photoNumber.text  = @"";
        if (post.imageURL.length > 5) {
            label_text.hidden = YES;
            imageview.hidden = NO;
            labelimage_text.hidden = NO;
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:post.imageURL width:60 height:100]]]; //placeholderImage:[UIImage imageNamed:@"usersummary_user_icon_loadpic"]
            CGFloat height = [self heightForCellWithPost:post.content withWidth:177];
            if (height > 97) {
                height = 75;
            }
            [labelimage_text setHeight:height];
            //            [labelimage_text sizeToFit];
            [labelimage_text setWidth:177];
            
            label_text.text = post.content;
        }else{
            label_text.hidden = NO;
            imageview.hidden = YES;
            labelimage_text.hidden = YES;
            
            CGFloat height = [self heightForCellWithPost:post.content withWidth:237];
            if (height > 97) {
                height = 75;
            }
            [label_text setHeight:height];
            //            [label_text sizeToFit];
            [label_text setWidth:237];
            
            label_text.text = post.content;
        }
    }
    

    NSString * currentTime = [tools timeLabelTextOfTimeMoth:post.time];
    
    if(indexPath.row>=1)
    {
        XCJGroupPost_list * postPre = dataSource[indexPath.row-1];
        NSString * string = [tools timeLabelTextOfTimeMoth:postPre.time];
        if ([currentTime isEqualToString:string]) {
            label_time.text = @"";
        }else{
            label_time.text = currentTime;
        }
    }else
    {
        label_time.text = currentTime;
    }
    label_address.text = @"";
    return cell;
}

- (CGFloat)heightForCellWithPost:(NSString *)post withWidth:(float) width{
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15.0f],NSFontAttributeName,nil];
    //ios7方法，获取文本需要的size，限制宽度 
     CGSize  actualsize = [post boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    SLog(@"actualsize.height %f",actualsize.height);
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//#pragma clang diagnostic pop
    return  fmaxf(20.0f, actualsize.height );
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = dataSource[indexPath.row];

    XCJMessageReplyInfoViewController * msgReplyInfoViewCr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMessageReplyInfoViewController"];
    msgReplyInfoViewCr.post = post;
    [self.navigationController pushViewController:msgReplyInfoViewCr animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = dataSource[indexPath.row];    
    if (post.imageURL.length > 5 || post.excount > 0) {
        return 100.0f;
    }
    CGFloat height = [self heightForCellWithPost:post.content withWidth:237];
    if (height > 97) {
        height = 75;
    }
    return height+12 + 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString * CellKey  = @"isloadingphotos";
    XCJGroupPost_list * activity = dataSource[indexPath.row];
    UIView * bgview =  [cell.contentView subviewWithTag:10];
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    if (activity.excount > 0) {
        
        
        [bgview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((UIView *)obj).hidden = YES;
        }];
        
       bgview.hidden = NO;
        Boolean bol = [cell.userInfo[@"CellKey"] boolValue];
        if (activity.excountImages.count <= 0 && !bol) {
            //check from networking
            cell.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@YES,CellKey, nil];
            [imageview showIndicatorViewBlue];

            
            NSString * cacheKey = [NSString stringWithFormat:@"post.readex.%@",activity.postid];
            NSArray * cahceArray = [[EGOCache globalCache] plistForKey:cacheKey];
            //            SLog(@"cahceArray :%@",cahceArray);
            if (cahceArray && cahceArray.count > 0) {
                NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                [[cahceArray mutableCopy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                    [arrayURLS addObject:stringurl];
                }];
                activity.excountImages = arrayURLS ;
                [self fillImagewithArray:arrayURLS withView:bgview];
                cell.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO,CellKey, nil];
                [imageview hideIndicatorViewBlueOrGary];
            }else{
                
                [[MLNetworkingManager sharedManager] sendWithAction:@"post.readex" parameters:@{@"postid":activity.postid} success:^(MLRequest *request, id responseObject) {
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
                        [activity.excountImages removeAllObjects];
                        [activity.excountImages addObjectsFromArray:arrayURLS];
                        [self fillImagewithArray:arrayURLS withView:bgview];
                        //54 84   23 23
                        //23 23 23
                    }
                    cell.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO,CellKey, nil];
                    [imageview hideIndicatorViewBlueOrGary];
                } failure:^(MLRequest *request, NSError *error) {
                    cell.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO,CellKey, nil];
                    [imageview hideIndicatorViewBlueOrGary];
                }];
            }
            
         
        }else{
            [self fillImagewithArray:activity.excountImages withView:bgview];
        }
    }else{
        bgview.hidden = YES;
    }
    
    
    if (dataSource.count < 50) {
        return;
    }
    if (self.isDontNeedLazyLoad) {
        return;
    }
    if ((indexPath.row) >= (NSInteger)(dataSource.count-1)) {
        if (!_isLoading) {
            self.isLoading = YES;
             XCJGroupPost_list * post = [dataSource lastObject];
            [self initDataSourcewithBeforeID:post.postid];
        }
    }
}


-(void) fillImagewithArray:(NSArray * ) array withView:(UIView*) bgview
{
    __block int TITLE_jianxi = 0;
    if (array.count >= 6) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * stringurl = obj;
            if (idx <= 5) {
                int row = idx/2;
                DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(27*(idx%2), (28+TITLE_jianxi) * row, 27, 28)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                iv.tag = idx;
                [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                [bgview addSubview:iv];
            }
        }];
    }else{
        switch (array.count) {
            case 5:
            {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = obj;
                    int row = idx/2;
                    int width;
                    if(idx == 4)
                        width =  54;
                    else
                        width = 27;
                        
                    DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(27*(idx%2), (28+TITLE_jianxi) * row, width, 28)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    [bgview addSubview:iv];
                }];
            }
                break;
            case 4:
            {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = obj;
                    int row = idx/2;
                    DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(27*(idx%2), (42+TITLE_jianxi) * row, 27, 42)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    [bgview addSubview:iv];
                }];
            }
                break;
            case 3:
            {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = obj;
                    int row = idx/2;
                    
                    int width;
                    if(idx == 2)
                        width = 54;
                    else
                        width = 27;
                    
                    DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(27*(idx%2), (42+TITLE_jianxi) * row, width, 42)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    [bgview addSubview:iv];
                }];
            }
                break;
            case 2:
            {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = obj;
                    int row = idx/1;
                    DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(27*(idx%1), (42+TITLE_jianxi) * row, 54, 42)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    [bgview addSubview:iv];
                }];
            }
                break;
            case 1:
            {
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString * stringurl = obj;
                    DAImageResizedImageView *iv = [[DAImageResizedImageView alloc] initWithFrame:CGRectMake(0  ,0,54,84)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    iv.tag = idx;
                    [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                    [bgview addSubview:iv];
                }];
            }
                break;
                
            default:
                break;
        }
        
    }

}


-(IBAction)changeMyPhoto:(id)sender
{
    if (!self.userID || [self.userID isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]) {
        
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"更换相册封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照" ,@"从相册选择", nil];
        [sheet showInView:self.view];
    }
    
}

@end
