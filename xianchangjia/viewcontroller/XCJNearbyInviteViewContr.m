//
//  XCJNearbyInviteViewContr.m
//  laixin
//
//  Created by apple on 2/28/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJNearbyInviteViewContr.h"
#import "XCAlbumAdditions.h"
#import "XCJGroupPost_list.h"
#import "FCUserDescription.h"
#import "XCJNearbyInfoViewContr.h"
#import "XCJCreateNearInviteViewcontr.h"

@interface XCJNearbyInviteViewContr ()
{
    NSMutableArray * _datasource;
}
@end

@implementation XCJNearbyInviteViewContr

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发起" style:UIBarButtonItemStyleBordered target:self action:@selector(ActionInviteClick:)];
    
    self.navigationItem.rightBarButtonItem  = rightBarButtonItem;
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _datasource = array;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNearbyInvite:) name:@"refreshNearbyInvite" object:nil];
    
    [self.view showIndicatorViewLargeBlue];
   
    [self refershNearbyinvite];
    
    self.title = @"活动列表";
    
}

-(void) refershNearbyinvite
{
    
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.search" parameters:@{@"type":@(groupsGroupNearbyInvite)} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * result = responseObject[@"result"];
                NSArray * arrayGroup = result[@"groups"];
                NSMutableArray * array = [[NSMutableArray alloc] init];
                [arrayGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    /*  add group */
                    NSString * str = [tools getStringValue:obj[@"gid"] defaultValue:@""];
                    [array addObject:str];
                }];
                if (array.count > 0) {
                    //group.info (gid<群id或者id数组>)
                    NSDictionary * paramess = @{@"gid":array};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
                        NSDictionary * groupsss = responseObjects[@"result"];
                        NSArray * groupsDicts =  groupsss[@"groups"];
                        [groupsDicts enumerateObjectsUsingBlock:^(id objss, NSUInteger idx, BOOL *stop) {
                            XCJGroup_list * list = [XCJGroup_list turnObject:objss];
                            if(list.type == groupsGroupNearbyInvite && list.position.length > 0){
                                [_datasource addObject:list];
                                
                            }
                        }];
                        
                        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
                        //一个临时副本
                        NSMutableArray *array = [_datasource mutableCopy];
                    
                        [array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                        _datasource = array;
                        [self.tableView reloadData];
                        [self.view hideIndicatorViewBlueOrGary];
                        
                        
                        int index = 1 + random()%5; 
                        ((UILabel *) [self.tableView.tableHeaderView subviewWithTag:1]).backgroundColor = [tools colorWithIndex:index];
                        ((UILabel *) [self.tableView.tableFooterView subviewWithTag:1]).backgroundColor = [tools colorWithIndex:index];
                        
                    } failure:^(MLRequest *request, NSError *error) {
                        [self.view hideIndicatorViewBlueOrGary];
                    }];
                }else
                {
                    [self.view hideIndicatorViewBlueOrGary];
                }
            }
        } failure:^(MLRequest *request, NSError *error) {
            
            [self.view hideIndicatorViewBlueOrGary];
        }];
    });
}

-(void)refreshNearbyInvite:(NSNotification *) notify
{
    [_datasource removeAllObjects];
    [self.tableView reloadData];
    
    [self.view showIndicatorViewLargeBlue];
    [self refershNearbyinvite];    
}

-(IBAction)ActionInviteClick:(id)sender
{
    XCJCreateNearInviteViewcontr * view = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCreateNearInviteViewcontr"];
    view.title = @"创建活动";
    [self.navigationController pushViewController:view animated:YES];
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
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellGroup";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XCJGroup_list * list = _datasource[indexPath.row];
    UILabel * labelgroupName = (UILabel *)[cell.contentView subviewWithTag:3];
    UILabel * labelgroupAddress = (UILabel *)[cell.contentView subviewWithTag:4];
    UILabel * labelgroupBoard = (UILabel *)[cell.contentView subviewWithTag:5];
    UILabel * labelgorupTime = (UILabel *)[cell.contentView subviewWithTag:6];
    UILabel * labelsignBg = (UILabel *)[cell.contentView subviewWithTag:12];

    UIImageView* imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
    imageview.layer.cornerRadius = imageview.height/2;
    imageview.layer.masksToBounds = YES;
    // Configure the cell...
    labelgroupName.text = list.group_name;
    labelgroupAddress.text = list.position;
    labelgroupBoard.text = list.group_board;
     int index = 1 + random()%5;
    labelgroupBoard.textColor = [tools colorWithIndex:index];
    labelsignBg.backgroundColor = [tools colorWithIndex:index];
//    list.time
    NSString * str =[self timeLabelTextOfTime:list.time];
    labelgorupTime.text = str;
    if ([str isEqualToString:@"失               效"]) {
        labelgorupTime.textColor =  [UIColor redColor];
    }else{
        labelgorupTime.textColor =  [tools colorWithIndex:0];
    }
    
    return cell;
}

- (NSString*) timeLabelTextOfTime:(NSTimeInterval)time
{
    if (time<=0) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *text = [dateFormatter stringFromDate:date];
    //最近时间处理
    NSInteger timeAgo = [[NSDate date] timeIntervalSince1970] - time;
//    SLog(@"timeAgo  %d",timeAgo);
    if (timeAgo > 0 && timeAgo < 86400) {
        return @"今               天";
    }else if (timeAgo >= 86400) {
        return @"失               效";
    }
    return text;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroup_list * list = _datasource[indexPath.row];
    UIImageView* imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
    UILabel * labelName = (UILabel *)[cell.contentView subviewWithTag:2];
//    labelName.textAlignment = NSTextAlignmentCenter;
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
        FCUserDescription * user = response;
        //内容
        if (user.headpic) {
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        }else{
            [imageview setImage:[UIImage imageNamed:@"avatar_default"] ];
        }
        labelName.text = user.nick;
    } withuid:list.creator];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"XCJNearbyInfoViewContr"]) {
        
        UITableViewCell * cell = (UITableViewCell *)sender;
         XCJGroup_list * list  = _datasource[[self.tableView indexPathForCell:cell].row];
        XCJNearbyInfoViewContr * view = [segue destinationViewController];
        view.title = @"活动详情";
        view.groupinfo = list;
//        [view initallContr:list];
        
    }

    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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


 */

@end
