//
//  XCJSeetypeMMviewcontroller.m
//  laixin
//
//  Created by apple on 3/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSeetypeMMviewcontroller.h"
#import "XCAlbumAdditions.h"
#import "UIButton+WebCache.h"
#import "UIButton+AFNetworking.h"
#import "XCJAddUserTableViewController.h"
#import "EGOCache.h"
#import "XCJSelfPrivatePhotoViewController.h"

@interface XCJSeetypeMMviewcontroller ()
{
     
    NSMutableArray *HotTypeOfMMArray;
    NSMutableDictionary * photoDict;
    NSMutableDictionary * isLoadDict;
}
@end

@implementation XCJSeetypeMMviewcontroller

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
    
    {   NSMutableArray * array =   [[NSMutableArray alloc] init];
        HotTypeOfMMArray = array ;
    }
    {   NSMutableDictionary * array =   [[NSMutableDictionary alloc] init];
        photoDict = array ;
    }
    {   NSMutableDictionary * array =   [[NSMutableDictionary alloc] init];
        isLoadDict = array ;
    }
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.title = @"列表";
    
    [self.view showIndicatorViewLargeBlue];
    {
        NSDictionary * parames = @{@"uid":self.userArray};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
            [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                if (currentUser) {
                    [HotTypeOfMMArray addObject:currentUser];
                }
            }];
            [self.view hideIndicatorViewBlueOrGary];
            [self.tableView reloadData];
        } failure:^(MLRequest *request, NSError *error) {
            [self showErrorText:@"加载出错"];
            [self.view hideIndicatorViewBlueOrGary];
        }];
        
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return HotTypeOfMMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView * buttonview = (UIImageView * )  [cell.contentView subviewWithTag:1];
    UILabel * label_name = (UILabel * )  [cell.contentView subviewWithTag:2];
    UILabel * label_content = (UILabel * )  [cell.contentView subviewWithTag:3];
    UIButton * button = (UIButton * )  [cell.contentView subviewWithTag:4];
    LXUser *currentUser =  HotTypeOfMMArray[indexPath.row];
    [self fillPhotoWithUID:currentUser.uid withcell:cell];
    if([buttonview isKindOfClass:[UIImageView class]])
    {
         [buttonview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:currentUser.headpic Size:100]]   placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    }
    
//    [buttonview setImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
    //forState:UIControlStateNormal
   
//    button.tag = indexPath.row;
    label_name.text = currentUser.nick;
    label_content.text = currentUser.signature.length<=0?@"Ta什么都没说":currentUser.signature;
    buttonview.layer.cornerRadius = buttonview.height/2;
    buttonview.layer.masksToBounds = YES;
    
    
    UILabel * label_more = (UILabel * )  [cell.contentView subviewWithTag:8];
    UIButton * ButtonSeeuserinfo = (UIButton * )  [cell.contentView subviewWithTag:10];
//    ButtonSeeuserinfo.tag = indexPath.row;
    
    [ButtonSeeuserinfo addTarget:self action:@selector(SeeUserHotClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row == 0) {
        
        label_more.text = @"推荐理由: 千杯不醉,品酒达人. 精通:赤霞珠/西拉/增芳德/佳美娜";
        
    } else  if (indexPath.row == 1) {
        
        label_more.text = @"推荐理由: 声音性感,言语动听. 精通:埃德华兹酒园 菩裴拉佳美娜干红葡萄酒/洛神山庄加本力苏维翁红葡萄酒";
    } else  if (indexPath.row == 2) {
        
    }else{
         label_more.text = @"推荐理由: 眼神勾魂,身材惹火. 精通:伏特加/香槟";
    }
    
    
    [button addTarget:self action:@selector(attentClick:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
    if (![array containsObject:currentUser.uid])
        [button setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
    else
        [button setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
    // Configure the cell...
    
    return cell;
}

-(void) fillPhotoWithUID:(NSString*) uid withcell:(UITableViewCell *)cell
{
    
    UIImageView * imageview1 = (UIImageView * )  [cell.contentView subviewWithTag:5];
    UIImageView * imageview2 = (UIImageView * )  [cell.contentView subviewWithTag:6];
    UIImageView * imageview3 = (UIImageView * )  [cell.contentView subviewWithTag:7];
    imageview1.image = [UIImage imageNamed:@"aio_ogactivity_default"];
    imageview2.image = [UIImage imageNamed:@"aio_ogactivity_default"];
    imageview3.image = [UIImage imageNamed:@"aio_ogactivity_default"];
    
    imageview1.layer.cornerRadius = 2;
    imageview1.layer.masksToBounds = YES;
    
    imageview2.layer.cornerRadius = 2;
    imageview2.layer.masksToBounds = YES;
    
    imageview3.layer.cornerRadius = 2;
    imageview3.layer.masksToBounds = YES;
    
    
    NSArray * photos = photoDict[uid];
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [imageview1 setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:obj Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        }else        if (idx == 1) {
            [imageview2 setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:obj Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        }else        if (idx == 2) {
            [imageview3 setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:obj Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        }
    }];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXUser *currentUser =  HotTypeOfMMArray[indexPath.row];
    
    NSString * CellKey  = [NSString stringWithFormat:@"CellKeyuid_%@",currentUser.uid];
    Boolean bol = [isLoadDict[CellKey] boolValue];
 
    NSArray * photos = photoDict[currentUser.uid];
    if (photos.count <= 0 && !bol) {
        [isLoadDict setValue:@YES forKey:CellKey];
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"album.read" parameters:@{@"uid":currentUser.uid,@"count":@"3"} success:^(MLRequest *request, id responseObject) {
            NSDictionary * result = responseObject[@"result"];
            NSArray * medias = result[@"medias"];
            NSMutableArray * array = [[NSMutableArray alloc] init];
            [medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString  *url = [DataHelper getStringValue:obj[@"picture"] defaultValue:@""];
                [array addObject:url];
            }];
            [photoDict setValue:array forKey:currentUser.uid];

            if(medias.count <= 0)
            {
                [isLoadDict setValue:@YES forKey:CellKey];
            }else{
                [isLoadDict setValue:@NO forKey:CellKey];
            }
                
            [self fillPhotoWithUID:currentUser.uid withcell:cell];
        } failure:^(MLRequest *request, NSError *error) {
            [isLoadDict setValue:@NO forKey:CellKey];
        }];
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXUser *currentUser =  HotTypeOfMMArray[indexPath.row];
    XCJSelfPrivatePhotoViewController * viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPrivatePhotoViewController"];
    viewControl.privateUID = currentUser.uid;
    [self.navigationController pushViewController:viewControl animated:YES];
}

-(IBAction)SeeUserHotClick:(id)sender
{
    UIButton * button = sender;
    UITableViewCell * cell = (UITableViewCell *) button.superview.superview.superview;
    
    LXUser *currentUser =  HotTypeOfMMArray[[self.tableView indexPathForCell:cell].row ];
//    LXUser * currentUser = cell.userInfo[@"userinfo"];
    if (currentUser) {
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
            if (response) {
                //FCUserDescription
                XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
                addUser.UserInfo = response;
                [self.navigationController pushViewController:addUser animated:YES];
            }
        }];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 246.0f;
}


-(IBAction)attentClick:(id)sender
{
    UIButton * button = sender;
    UITableViewCell * cell = (UITableViewCell *) button.superview.superview.superview;
    NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
//    LXUser * userinfo = cell.userInfo[@"userinfo"];
    LXUser *userinfo =  HotTypeOfMMArray[[self.tableView indexPathForCell:cell].row ];
    if (array) {
        if ([array containsObject:userinfo.uid]) {
            //如果存在 就移除
            [array removeObject:userinfo.uid];
            
            [button setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
            [button showAnimatingLayer];
            
            [[EGOCache globalCache] setPlist:array forKey:KSingerCount];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"remove"];
            });
        }else{
            //如果不存在  就加入
            
            [array addObject:[NSString stringWithFormat:@"%@",userinfo.uid]];
            
            [[EGOCache globalCache] setPlist:array forKey:KSingerCount];
            [button setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
            [button showAnimatingLayer];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
            });
        }
    }else{
        
        //如果不存在  就加入
        [[EGOCache globalCache] setPlist:[NSArray arrayWithObject:userinfo.uid] forKey:KSingerCount];
        [button setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
        [button showAnimatingLayer]; 
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
        });
        
        
    }
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
