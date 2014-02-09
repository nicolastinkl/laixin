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


@interface XCJSelfPhotoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray * dataSource;
}
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
    UILabel * label_name = (UILabel *)[self.tableView.tableHeaderView viewWithTag:1];
    UILabel * label_sign = (UILabel *)[self.tableView.tableHeaderView viewWithTag:2];
    UIImageView * imageIcon = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:3];
    UIImageView * imagebg = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:4];
    if ([LXAPIController sharedLXAPIController].currentUser) {
        
       
        
    }
    label_name.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    //[LXAPIController sharedLXAPIController].currentUser.nick;
    label_sign.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];
    
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
    
    NSString * jsonData = [[EGOCache globalCache] stringForKey:@"MyPhotoCache"];
    if (jsonData.length > 10) {
        // parse
        NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary * responseObject =[data  objectFromJSONData] ;
        NSDictionary * dicreult = responseObject[@"result"];
        NSArray * array = dicreult[@"posts"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
            [dataSource addObject:post];
        }];
        
    }else{
        // get json data from networking
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.posts" parameters:@{@"uid":[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id],@"count":@"50"} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * dicreult = responseObject[@"result"];
                NSArray * array = dicreult[@"posts"];
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                    [dataSource addObject:post];
                }];
                [self.tableView reloadData];
                if (array.count > 0) {
                    [[EGOCache globalCache] setString:[responseObject JSONString] forKey:@"MyPhotoCache"];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            
        }];
    }
    
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
    [[EGOCache globalCache] setImage:image forKey:@"myphotoBgImage"];
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
    
    // Configure the cell...
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelimage_text = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * label_time = (UILabel *) [cell.contentView subviewWithTag:3];
    UILabel * label_address = (UILabel *) [cell.contentView subviewWithTag:4];
    UILabel * label_text = (UILabel *) [cell.contentView subviewWithTag:5];
    XCJGroupPost_list * post = dataSource[indexPath.row];
    if (post.imageURL.length > 5) {
        label_text.hidden = YES;
        imageview.hidden = NO;
        labelimage_text.hidden = NO;
        labelimage_text.text = post.content;
        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:post.imageURL width:60 height:90]] placeholderImage:[UIImage imageNamed:@"usersummary_user_icon_loadpic"]];
       CGFloat height = [self heightForCellWithPost:post.content withWidth:177];
        [labelimage_text setHeight:height];
        [labelimage_text sizeToFit];
        [labelimage_text setWidth:177];
    }else{
        label_text.hidden = NO;
        imageview.hidden = YES;
        labelimage_text.hidden = YES;
        label_text.text = post.content;
        
        CGFloat height = [self heightForCellWithPost:post.content withWidth:237];
        if (height > 97) {
            height = 95;
        }
        [label_text setHeight:height];
        [label_text sizeToFit];
        [label_text setWidth:237];
    }
    label_time.text = [tools timeLabelTextOfTimeMoth:post.time];
    label_address.text = @"";
    return cell;
}

- (CGFloat)heightForCellWithPost:(NSString *)post withWidth:(float) width{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(35.0f, sizeToFit.height + 25.0f );
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
    if (post.imageURL.length > 5) {
        return 100.0f;
    }
    CGFloat height = [self heightForCellWithPost:post.content withWidth:237];
    if (height > 97) {
        height = 95;
    }
    return height-12;
}

-(IBAction)changeMyPhoto:(id)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"更换相册封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照" ,@"从相册选择", nil];
    [sheet showInView:self.view];
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
