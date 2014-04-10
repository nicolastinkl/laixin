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


#define DISTANCE_BETWEEN_ITEMS  8.0
#define LEFT_PADDING            8.0
#define ITEM_WIDTH              96.0
#define colNumber 3
#define TITLE_jianxi            2.5

@interface XCJWellDreamUsersTableViewController ()
{
    NSMutableArray * groupList;
}
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
    float imageviewHeight = (groupList.count/colNumber)*65 +(groupList.count/colNumber)*TITLE_jianxi;
    if (groupList.count%colNumber>0) {
        imageviewHeight += TITLE_jianxi+ITEM_WIDTH;
    }
    return imageviewHeight;
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
            label.frame = CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1), LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row+76, ITEM_WIDTH-40, 20);
            label.text = userinfo.nick;
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor colorWithWhite:0.095 alpha:0.300];
            [cell.contentView addSubview:label];
        }
        
        {
            UILabel * label  = [[UILabel alloc] init];
            label.frame = CGRectMake(ITEM_WIDTH*(idx%3)+LEFT_PADDING*(idx%3+1) + ITEM_WIDTH-40, LEFT_PADDING + (ITEM_WIDTH+LEFT_PADDING) * row+76, 40, 20);
            label.text = @"12";
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = [UIColor redColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor colorWithWhite:0.095 alpha:0.300];
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
    
    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:user withCompletion:^(id response, NSError *error) {
        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
        addUser.UserInfo = response;
        [self.navigationController pushViewController:addUser animated:YES];
    }];
    
    
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
