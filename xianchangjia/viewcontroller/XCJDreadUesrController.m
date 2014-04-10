//
//  XCJDreadUesrController.m
//  laixin
//
//  Created by apple on 4/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDreadUesrController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+WebCache.h"
@interface XCJDreadUesrController ()
{
    NSMutableArray * groupList;
}
@end

@implementation XCJDreadUesrController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    self.collectionView.top = 64.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition  object:nil];
    
    [self reloadData];
    
}


-(void) reloadData
{
    [groupList removeAllObjects];
    [self.collectionView showIndicatorViewLargeBlue];
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
                
                [self.collectionView hideIndicatorViewBlueOrGary];
                [self.collectionView reloadData];
            } failure:^(MLRequest *request, NSError *error) {
                [self.collectionView hideIndicatorViewBlueOrGary];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return groupList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = (UICollectionViewCell*) [collectionView  dequeueReusableCellWithReuseIdentifier:@"UserCollection" forIndexPath:indexPath];
    
    UIButton * countToupiao = (UIButton * ) [cell.contentView subviewWithTag:1];
    UILabel * label = (UILabel * ) [cell.contentView subviewWithTag:2];
    LXUser * luser = groupList[indexPath.row];
    
    [countToupiao setBackgroundImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:luser.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"usersummary_user_icon_loadpic"]];
    
    [label setText:[NSString stringWithFormat:@"%d",2]];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
