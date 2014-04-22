//
//  XCJWellDreamUsersTableViewController.m
//  laixin
//
//  Created by apple on 4/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJWellDreamUsersTableViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJAddUserTableViewController.h"
#import "XCJDreamPopUserView.h"


#define DISTANCE_BETWEEN_ITEMS  8.0
#define LEFT_PADDING            8.0
#define ITEM_WIDTH              96.0
#define colNumber 3
#define TITLE_jianxi            2.5
CGFloat const kRNGridMenuDefaultDuration = 0.45f;
CGFloat const kRNGridMenuDefaultBlur = 0.3f;
CGFloat const kRNGridMenuDefaultWidth = 280;

NSString  * sendLikeBOOL = @"sendLikeUSERDREAM";

@interface XCJWellDreamUsersTableViewController ()<XCJDreamPopUserViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray * groupList;
    XCJDreamPopUserView *  dreamPopView;
    LXUser * currentUser;
}

// The time in seconds for the show and dismiss animation
// default 0.25f
@property (nonatomic, assign) CGFloat animationDuration;

// An optional block that gets executed before the gridMenu gets dismissed
@property (nonatomic, copy) dispatch_block_t dismissAction;

// Determine whether or not to bounce in the animation
// default YES
@property (nonatomic, assign) BOOL bounces;
@end

@implementation XCJWellDreamUsersTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        groupList = _init_array;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition  object:nil];
    
    _bounces = YES;
    
    _animationDuration = kRNGridMenuDefaultDuration;
    
    [self reloadData];
    
}

-(void) reloadData
{
    [groupList removeAllObjects];
    [self.tableView showIndicatorViewLargeBlue];
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.members" parameters:@{@"gid":@"61"} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"result"];
            NSArray * arr =  dict[@"members"];
            NSMutableArray * userArray = [[NSMutableArray alloc] init];
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [userArray addObject:[DataHelper getStringValue:obj[@"uid"] defaultValue:@""]];
            }];
            
            NSDictionary * parameIDS = @{@"uid":userArray};
            [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parameIDS success:^(MLRequest *request, id responseObject) {
                // "users":[....]
                NSDictionary * userinfo = responseObject[@"result"];
                NSArray * userArray = userinfo[@"users"];
                [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    LXUser * luser = [[LXUser alloc] initWithDict:obj];
                    [groupList addObject:luser];
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFriendsObject:luser];
                }];
                
                [self.tableView hideIndicatorViewBlueOrGary];
                [self.tableView reloadData];
            } failure:^(MLRequest *request, NSError *error) {
                [self.tableView hideIndicatorViewBlueOrGary];
                [self showErrorInfoWithRetry];
            }];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [self showErrorInfoWithRetry];
    }];
}

-(void) showErrorInfoWithRetryNot:(NSNotification * ) notify
{
    [self hiddeErrorInfoWithRetry];
    // start retry
    
    [self reloadData];
}


#pragma mark - XLSwipeContainerItemDelegate

-(id)swipeContainerItemAssociatedSegmentedItem
{
    return @"成员";
}

-(UIColor *)swipeContainerItemAssociatedColor
{
    return [UIColor whiteColor];
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
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float imageviewHeight = (groupList.count/colNumber)*ITEM_WIDTH +(groupList.count/colNumber)*TITLE_jianxi;
    if (groupList.count%colNumber>0) {
        imageviewHeight += TITLE_jianxi+ITEM_WIDTH;
    }
    return imageviewHeight + 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsersCell" forIndexPath:indexPath];
    [groupList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LXUser * userinfo = obj;
        int row = idx/3;
        UIImageView* imageview = [[UIImageView alloc] init];
        [imageview setFrame:CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1),LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row, ITEM_WIDTH, ITEM_WIDTH)];
        imageview.contentMode = UIViewContentModeScaleAspectFill;         
        imageview.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
        [recognizer setNumberOfTapsRequired:1];
        [recognizer setNumberOfTouchesRequired:1];
        [imageview addGestureRecognizer:recognizer];
        
        imageview.tag = idx;
        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:userinfo.headpic Size:160]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [cell.contentView addSubview:imageview];
        
        {
            UILabel * label  = [[UILabel alloc] init];
            label.frame = CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1), LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row+76, ITEM_WIDTH, 20);
            label.text = userinfo.nick;
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor colorWithWhite:0.095 alpha:0.300];
            [cell.contentView addSubview:label];
        }
        
        {
            UILabel * label  = [[UILabel alloc] init];
            label.frame = CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1) + ITEM_WIDTH-43, LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row, 40, 20);
            label.text = [NSString stringWithFormat:@"%d票",userinfo.like_me_count];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [UIColor redColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor clearColor];// [UIColor colorWithWhite:0.095 alpha:0.300];
            [cell.contentView addSubview:label];
        }
        
    }];
    
    // Configure the cell...
    
    return cell;
}

-(IBAction)tagSelected:(id)sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    LXUser * user =  groupList[buttonSender.tag];
    currentUser = user;
    if (dreamPopView == nil) {
        dreamPopView = [[[NSBundle mainBundle] loadNibNamed:@"XCJDreamPopUserView" owner:self options:nil] firstObject];
        dreamPopView.delegate = self;
        [dreamPopView.image_user setLeft:10.5];
        dreamPopView.image_user.layer.cornerRadius = 2;
        dreamPopView.image_user.layer.masksToBounds= YES;
    }
    
    [dreamPopView.image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:320]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    dreamPopView.label_number.text = [NSString stringWithFormat:@"%d票",user.like_me_count];
    
    dreamPopView.label_name.text = currentUser.nick;
    [self showAnimated:YES];
}




- (void)showAnimated:(BOOL)animated {
    [self.navigationController.view addSubview:dreamPopView];
//    dreamPopView.center = self.navigationController.view.center;
    
    if (animated) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @0.;
        opacityAnimation.toValue = @1.;
        opacityAnimation.duration = self.animationDuration * 0.5f;
        
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D startingScale = CATransform3DScale(dreamPopView.layer.transform, 0, 0, 0);
        CATransform3D overshootScale = CATransform3DScale(dreamPopView.layer.transform, 1.05, 1.05, 1.0);
        CATransform3D undershootScale = CATransform3DScale(dreamPopView.layer.transform, 0.98, 0.98, 1.0);
        CATransform3D endingScale = dreamPopView.layer.transform;
        
        NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
        NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
        NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        
        if (self.bounces) {
            [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
            [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        }
        
        [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
        [keyTimes addObject:@1.0f];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        scaleAnimation.values = scaleValues;
        scaleAnimation.keyTimes = keyTimes;
        scaleAnimation.timingFunctions = timingFunctions;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        animationGroup.duration = self.animationDuration;
        
        [dreamPopView.layer addAnimation:animationGroup forKey:nil];
    }

    
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.dismissAction != nil) {
        self.dismissAction();
    }
    
    if (animated) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @1.;
        opacityAnimation.toValue = @0.;
        opacityAnimation.duration = self.animationDuration;
        [dreamPopView.layer addAnimation:opacityAnimation forKey:nil];
        
        CATransform3D transform = CATransform3DScale(dreamPopView.layer.transform, 0, 0, 0);
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:dreamPopView.layer.transform];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        scaleAnimation.duration = self.animationDuration;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[opacityAnimation, scaleAnimation];
        animationGroup.duration = self.animationDuration;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [dreamPopView.layer addAnimation:animationGroup forKey:nil];
        
        dreamPopView.layer.opacity = 0;
        dreamPopView.layer.transform = transform;
        [self performSelector:@selector(cleanupGridMenu) withObject:nil afterDelay:self.animationDuration];
    } else {
        self.view.hidden = YES;
        [self cleanupGridMenu];
    }
}

- (void)cleanupGridMenu {
    [dreamPopView removeFromSuperview];
    dreamPopView = nil;
}

-(void) closeView
{
    [self dismissAnimated:YES];
}

-(void) targetUserinfo
{
    if (currentUser) {
        [self dismissAnimated:YES];
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError *error) {
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
            [self.navigationController pushViewController:addUser animated:YES];
        }];
    }
    
}

-(void) sendLike
{
    
    NSString * sendLikeBOOLNumber = [[EGOCache globalCache]stringForKey:sendLikeBOOL];
    if (sendLikeBOOLNumber && [sendLikeBOOLNumber intValue] >= 3) {
        [UIAlertView showAlertViewWithMessage:@"今天投票机会已经用完了"];
    }else{
        NSString * title = @"";
        title = [title stringByAppendingString:@"每天只有3次投票机会  \n"];
        
        title  = [title stringByAppendingFormat:@"还有%d次机会",3 - [sendLikeBOOLNumber intValue]];
        
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"投票" otherButtonTitles:nil, nil];
        sheet.tag = 4;
        [sheet showInView:self.tableView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 4) {
        
        if (buttonIndex == 0) {
            if (currentUser) {
                [SVProgressHUD showWithStatus:@"正在投票..."];
                [[MLNetworkingManager sharedManager] sendWithAction:@"user.like" parameters:@{@"uid":currentUser.uid} success:^(MLRequest *request, id responseObject) {
                    [dreamPopView.button_like showAnimatingLayer];
                    currentUser.like_me_count ++;
                    dreamPopView.label_number.text = [NSString stringWithFormat:@"%d票",currentUser.like_me_count];
                    [dreamPopView.button_like setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
                    [self.tableView reloadData];
                    [SVProgressHUD dismiss];
                    
                    if ([[EGOCache globalCache] hasCacheForKey:sendLikeBOOL]) {
                        NSString * sendLikeBOOLNumber = [[EGOCache globalCache]stringForKey:sendLikeBOOL];
                        [[EGOCache globalCache]  setString:[NSString stringWithFormat:@"%d",([sendLikeBOOLNumber intValue] + 1)] forKey:sendLikeBOOL withTimeoutInterval:60*60*24];
                    }else{
                        [[EGOCache globalCache]  setString:@"1" forKey:sendLikeBOOL withTimeoutInterval:60*60*24];
                    }
                } failure:^(MLRequest *request, NSError *error) {
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"投票失败"];
                }];
            }
        }
        
    }
}

@end
