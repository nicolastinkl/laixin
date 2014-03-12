//
//  XCJTableViewMMController.m
//  laixin
//
//  Created by apple on 3/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJTableViewMMController.h"
#import "XCAlbumAdditions.h"
#import "UITableViewCell+TKCategory.h"
#import "UIButton+WebCache.h"
#import "UIButton+AFNetworking.h"
#import "XCJAddUserTableViewController.h"
#import "UIView+Additon.h"
#import "XCJSeetypeMMviewcontroller.h"
#import "XCJMutiMMViewController.h"
#import "XCJSelfPrivatePhotoViewController.h"


#define BUTTONCOLL  5
#define DISTANCE_BETWEEN_ITEMS  5.0
#define LEFT_PADDING            5.0
#define ITEM_WIDTH              80.0


@interface XCJTableViewMMController ()
{
    NSArray * tagArray;
    
    NSMutableArray *HotTypeOfMMArray;
    NSMutableArray *NewUserTypeOfMMArray;
}
@property (nonatomic, strong) IBOutlet UITableView *mainsTableView;

//@property (nonatomic, strong) IBOutlet UITableView *newUsersTableView;

@end

@implementation XCJTableViewMMController

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
    {
        NSMutableArray * array =   [[NSMutableArray alloc] init];
       NewUserTypeOfMMArray = array ;
    }
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyKSonger:) name:@"updateMyKSonger" object:nil];
     UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"已选(0)" style:UIBarButtonItemStyleDone target:self action:@selector(SeeChoseMMClick:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    NSMutableArray * array = [[EGOCache globalCache] plistForKey:KSingerCount];
    
    if (array.count > 0) {
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"已选(%d)",array.count];
    }else{
        self.navigationItem.rightBarButtonItem.title = @"已选(0)";
    }
    
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
        //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSString * strJson =  [dictionary valueForKey:@"ageDes"];
        NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        tagArray = [datajson  objectFromJSONData] ;
    }
    
    {
        NSString * strJson = [MobClick getConfigParams:@"HotTypeOfMM"];
        NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray * array = [datajson  objectFromJSONData] ;
        
        NSDictionary * parames = @{@"uid":array};
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
            [self.mainsTableView reloadData];
        } failure:^(MLRequest *request, NSError *error) {
        }];
        
        
    }
    
    
    UITableView * usertable = (UITableView*) [self.mainsTableView.tableFooterView subviewWithTag:1];
    
    {
        NSString * strJson = [MobClick getConfigParams:@"NewUserTypeOfMM"];
        NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray * array = [datajson  objectFromJSONData] ;
        SLog(@"string %@  : array %@",strJson,array);
        
        NSDictionary * parames = @{@"uid":array};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
            [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                if (currentUser) {
                    [NewUserTypeOfMMArray addObject:currentUser];
                }
                
            }];
            
            [usertable reloadData];
        } failure:^(MLRequest *request, NSError *error) {
        }];
        
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}




-(void) updateMyKSonger:(NSNotification * ) notify
{
    if (notify.object) {
        NSMutableArray * array = [[EGOCache globalCache] plistForKey:KSingerCount];
        
        if (array.count > 0) {
            self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"已选(%d)",array.count];
        }else{
               self.navigationItem.rightBarButtonItem.title = @"已选(0)";
        }
    }
}
-(IBAction)SeeChoseMMClick:(id)sender
{
    XCJMutiMMViewController  *MMViewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJMutiMMViewController"];
    [self.navigationController pushViewController:MMViewContr animated:YES];
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
    if (tableView == self.mainsTableView)
        return 2;
    
    // Return the number of rows in the section.
    return NewUserTypeOfMMArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.mainsTableView) {
        if (indexPath.row == 0) {
            return 142.0f;
        }else
        if (indexPath.row == 1) {
            int row =  tagArray.count / 2;
            return (row * 150 + row * 5) + 50;
        }
    }
    return 44;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    // Configure the cell...
    
    
    UITableViewCell *cell;
	
	if (tableView == self.mainsTableView) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"titileCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
            UIScrollView * scrollview = (UIScrollView *) [cell.contentView subviewWithTag:1];
            //移除 old view
            [scrollview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [( (UIView *) obj) setHidden:YES];
            }];
            [scrollview reloadInputViews];
            __block int page = 0;
            CGSize pageSize = CGSizeMake(ITEM_WIDTH, scrollview.frame.size.height);
 
            [HotTypeOfMMArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser *currentUser = obj;
                
                UIView * viewFrame =  [[UIView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
                viewFrame.layer.cornerRadius = 5;
                viewFrame.layer.masksToBounds = YES;
                viewFrame.hidden = NO;
                UIButton * imageButon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
                UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, 80, 18)];
                nameLabel.textAlignment = NSTextAlignmentCenter;
                nameLabel.font = [UIFont systemFontOfSize:13.0f];
                nameLabel.textColor = [UIColor whiteColor];
                nameLabel.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
                imageButon.tag = idx;
                [imageButon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:currentUser.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                nameLabel.text = currentUser.nick;
                [viewFrame addSubview:imageButon];
                [viewFrame addSubview:nameLabel];
                [imageButon addTarget:self action:@selector(SeeUserHotClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [viewFrame setLeft:(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++)];
                [scrollview addSubview:viewFrame];

            }];
                scrollview.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * HotTypeOfMMArray.count, pageSize.height);
            
            
            return cell;
        }else if (indexPath.row == 1) {
            __block int TITLE_jianxi = 5;
            static NSString *CellIdentifier = @"typeCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            UIView * contentview =  [cell.contentView subviewWithTag:1];
            [tagArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                int row = idx/2;
                UIButton *iv = [[UIButton alloc] initWithFrame:CGRectMake(150*(idx%2)+TITLE_jianxi*(idx%2+1), (150+TITLE_jianxi) * row, 150, 150)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                iv.layer.cornerRadius = 4;
                iv.layer.masksToBounds =  YES;
                iv.titleLabel.font = [UIFont boldSystemFontOfSize:30.0f];
                [iv setBackgroundColor:[tools colorWithIndex:row+1]];
                iv.tag = (idx + 1);
                [iv setTitle:[NSString stringWithFormat:@"%@",obj] forState:UIControlStateNormal];
                [iv addTarget:self action:@selector(seetypeMMClick:) forControlEvents:UIControlEventTouchUpInside];
                [contentview addSubview:iv];
            }];
            int row =  tagArray.count / 2;
            [contentview setHeight: (row * 150 + row * TITLE_jianxi)];
            return cell;
        }
        
	} else {
        static NSString *CellIdentifier = @"userCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView * imageview = (UIImageView * )  [cell.contentView subviewWithTag:1];
        UILabel * label_name = (UILabel * )  [cell.contentView subviewWithTag:2];
        UILabel * label_content = (UILabel * )  [cell.contentView subviewWithTag:3];
        UIButton * button = (UIButton * )  [cell.contentView subviewWithTag:4];
        LXUser *currentUser =  NewUserTypeOfMMArray[indexPath.row];
        imageview.layer.cornerRadius = imageview.height/2;
        imageview.layer.masksToBounds = YES;
        
        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:currentUser.headpic Size:100]]  placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        label_name.text = currentUser.nick;
        label_content.text = currentUser.signature.length<=0?@"Ta什么都没说":currentUser.signature;
        NSMutableDictionary * keymuta  = [[NSMutableDictionary alloc] initWithObjectsAndKeys:currentUser,@"userinfo", nil];
        [cell setUserInfo:keymuta];
        
        [button addTarget:self action:@selector(attentClick:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
        if (![array containsObject:currentUser.uid])
            [button setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
        else
            [button setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
        
        return cell;
	}
    return cell;
}

-(IBAction)SeeUserHotClick:(id)sender
{
   
    UIButton * button = sender;
    LXUser *currentUser = HotTypeOfMMArray[button.tag];
    if (currentUser) {
        
        XCJSelfPrivatePhotoViewController * viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPrivatePhotoViewController"];
        viewControl.privateUID = currentUser.uid;
        [self.navigationController pushViewController:viewControl animated:YES];
        
        return;
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

-(IBAction)seetypeMMClick:(id)sender
{
    UIButton * button = sender;
    NSString * paramsstr ;
    switch (button.tag) {
        case 1:
        {
            paramsstr = @"MMType_xueshengmei";
        }
            break;
        case 2:
        {
            paramsstr = @"MMType_shaonvshidai";
        }
            break;
        case 3:
        {
            paramsstr = @"MMType_doukounianhua";
        }
            break;
        case 4:
        {
            paramsstr = @"MMType_qingchunwudi";
        }
            break;
        case 5:
        {
            paramsstr = @"MMType_xiaoluoli";
        }
            break;
        case 6:
        {
            paramsstr = @"MMType_tongyanjuru";
        }
            break;
        case 7:
        {
            paramsstr = @"MMType_hanbaodaifang";
        }
            break;
        case 8:
        {
            paramsstr = @"MMType_shaoyouyunwei";
        }
            break;
        case 9:
        {
            paramsstr = @"MMType_poguazhinian";
        }
            break;
        case 10:
        {
            paramsstr = @"MMType_biyunianhua";
        }
            break;
        case 11:
        {
            paramsstr = @"MMType_taolinianhua";
        }
            break;
        case 12:
        {
            paramsstr = @"MMType_huaxinnianhua";
        }
            break;
            
        default:
            break;
    }
    
    NSString * strJson = [MobClick getConfigParams:paramsstr];
    if (strJson) {
        NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray * array = [datajson  objectFromJSONData] ;
         
        XCJSeetypeMMviewcontroller * viewtronl = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSeetypeMMviewcontroller"];
        viewtronl.title = button.titleLabel.text;
        viewtronl.userArray = array;
        [self.navigationController pushViewController:viewtronl animated:YES];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"userCell"]) {
        LXUser * currentUser = cell.userInfo[@"userinfo"];
        XCJSelfPrivatePhotoViewController * viewControl = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSelfPrivatePhotoViewController"];
        viewControl.privateUID = currentUser.uid;
        [self.navigationController pushViewController:viewControl animated:YES];
        
        /* [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response    , NSError * error) {
         if (response) {
         //FCUserDescription
         XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
         addUser.UserInfo = response;
         [self.navigationController pushViewController:addUser animated:YES];
         }
         }];*/
    }
}

-(IBAction)attentClick:(id)sender
{
    UIButton * button = sender;
    UITableViewCell * cell = (UITableViewCell *) button.superview.superview.superview;
    if ([cell.reuseIdentifier isEqualToString:@"userCell"]) {
        NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
        LXUser * userinfo = cell.userInfo[@"userinfo"];
//        NSMutableArray * array = [NSMutableArray arrayWithArray:oldarray];
        if (array) {
            if ([array containsObject:userinfo.uid]) {
                //如果存在 就移除
                [array removeObject:userinfo.uid];
                
                [button setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
                [button showAnimatingLayer];
                
                SLog(@" remove array %d",array.count);
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
                SLog(@" add array %d",array.count);
                
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
            SLog(@" add array %d",array.count);
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"add"];
            });
            
       
        }
        
        
//        [SVProgressHUD showWithStatus:@"正在处理..."];
//        NSDictionary * parames = @{@"uid":@[userinfo.uid]};
//        [[MLNetworkingManager sharedManager] sendWithAction:@"user.add_friend" parameters:parames success:^(MLRequest *request, id responseObject) {
//            // add this user to friends DB
//            // setFriendsObject
//            [SVProgressHUD dismiss];
//            if (responseObject) {
//                
//                [button setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
//                [button showAnimatingLayer];
//                
//                //[self.navigationController popViewControllerAnimated:YES];
//            }
//        } failure:^(MLRequest *request, NSError *error) {
//            [UIAlertView showAlertViewWithMessage:@"处理失败..."];
//        }];
        
        
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
