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
#import "TKParallaxCell.h"
#import "UIImage+ImageEffects.h"
#import "DAImageResizedImageView.h"

@interface XCJNearbyInviteViewContr ()<UIScrollViewDelegate>
{
    NSMutableArray * _datasource;
    NSArray *arrayUrls;
    NSMutableArray * labelArray;
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
    NSArray* arrayUrlsss = @[@"http://img.weheartpics.com/photo/320x320/13406137.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406171.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406088.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13392856.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13401922.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13403320.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13404422.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13400800.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13400732.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406127.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406110.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406084.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13405954.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13401319.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406053.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13401824.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13401632.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13406166.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13405856.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13405827.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13390281.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13405827.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13387482.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13383977.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13382796.jpg",
                           @"http://img.weheartpics.com/photo/320x320/13382052.jpg"];
    arrayUrls = arrayUrlsss;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
    //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString * strJson =  [dictionary valueForKey:@"grouptypeArray"];
    NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSArray * responseObject =[datajson  objectFromJSONData] ;
    
    labelArray = [NSMutableArray arrayWithArray:responseObject];
    
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
                        
                        [self scrollViewDidScroll:nil];
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
    TKParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XCJGroup_list * list = _datasource[indexPath.row];
    UILabel * labelName = (UILabel *)[cell.contentView subviewWithTag:2];
    UILabel * labelgroupName = (UILabel *)[cell.contentView subviewWithTag:3];
//    UILabel * labelgroupAddress = (UILabel *)[cell.contentView subviewWithTag:4];
    UILabel * labelgroupBoard = (UILabel *)[cell.contentView subviewWithTag:5];
    UILabel * labelgorupTime = (UILabel *)[cell.contentView subviewWithTag:6];
    UILabel * labelsignBg = (UILabel *)[cell.contentView subviewWithTag:12];

//    UIImageView* imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
   
    //.image = [UIImage imageNamed:@"demo_3.jpg"];//[UIImage imageNamed:@"PublicPlatform_add_banner_background"];
//    imageview.layer.cornerRadius = imageview.height/2;
//    imageview.layer.masksToBounds = YES;
    // Configure the cell...
    labelgroupName.text = list.group_name;
//    labelgroupAddress.text = list.position;
    labelgroupBoard.text = @"";// list.group_board;
    labelName.text = list.group_board;
    
    NSInteger indexWithUrl = [labelArray indexOfObject:list.group_board];
    if (arrayUrls.count > indexWithUrl) {
        NSString * tagUrl = arrayUrls[indexWithUrl];
        [cell.parallaxImage setImageWithURL:[NSURL URLWithString:tagUrl] ];
    }else{
        int index = 13383619 + random()%1000;
        //13383619
        [cell.parallaxImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.weheartpics.com/photo/320x320/%d.jpg",index]]];
    }

    //placeholderImage:[UIImage imageNamed:@"demo_3.jpg"]
    int index = 1 + random()%5;
    labelgroupBoard.textColor = [tools colorWithIndex:index];
    labelsignBg.backgroundColor = [tools colorWithIndex:index];

    NSString * str =[self timeLabelTextOfTime:list.time];
    labelgorupTime.text = @"";// str;
    if ([str isEqualToString:@"失               效"]) {
        labelgorupTime.textColor =  [UIColor redColor];
//        cell.parallaxImage.image = [[UIImage imageNamed:@"demo_3.jpg"] applyLightEffect];
    }else{
        labelgorupTime.textColor =  [tools colorWithIndex:0];
    }
    
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (TKParallaxCell *cell in visibleCells) {
        [cell cellOnTableView:self.tableView didScrollOnView:self.navigationController.view];
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0f;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    XCJGroup_list * list = _datasource[indexPath.row];
//    TKParallaxCell *cellPar = cell;
//    cellp
//    UIImageView* imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
//    UILabel * labelName = (UILabel *)[cell.contentView subviewWithTag:2];
//    labelName.textAlignment = NSTextAlignmentCenter;
    /*[[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
     if (response) {
     
     FCUserDescription * user = response;
     //内容
     if (user.headpic) {
     // [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:320]] placeholderImage:[UIImage imageNamed:@"PublicPlatform_add_banner_background"]];
     }else{
     //  [imageview setImage:[UIImage imageNamed:@"PublicPlatform_add_banner_background"] ];
     }
     labelName.text = user.nick;
     }
     } withuid:list.creator];*/
    
    
//}


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


@end
