//
//  XCJMutiMMViewController.m
//  laixin
//
//  Created by apple on 3/11/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJMutiMMViewController.h"
#import "XCAlbumAdditions.h"
#import "FCUserDescription.h"
#import "XCJAddUserTableViewController.h"

@interface XCJMutiMMViewController ()<UIActionSheetDelegate>
{
    NSMutableArray * _datasource;
}
@end

@implementation XCJMutiMMViewController

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

    self.title = @"已选列表";
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    NSMutableArray * arrays = [[EGOCache globalCache] plistForKey:KSingerCount];
    if(arrays.count > 0){
        _datasource = [arrays mutableCopy];
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearCacheClick:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
//    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(backCLick:)];
    
    if (arrays.count  == 0) {
        [self showErrorText:@"还没有选择K歌指导员"];
    }
    
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(IBAction)backCLick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [[EGOCache globalCache] removeCacheForKey:KSingerCount];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"remove"];
        });
        
        [_datasource removeAllObjects];
        [self.tableView reloadData];
    }
}

-(IBAction)clearCacheClick:(id)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确定清空吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _datasource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView * imageview =  (UIImageView * )[cell.contentView subviewWithTag:1];
    UILabel * name =  (UILabel * )[cell.contentView subviewWithTag:2];
    UILabel * des =  [cell.contentView subviewWithTag:3];
    UIButton * butondel =  (UIButton *)[cell.contentView subviewWithTag:4];
    NSString * userid   = _datasource[indexPath.row];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        if(response)
        {
            FCUserDescription * user = response;
            NSString *Urlstring = [tools getUrlByImageUrl:user.headpic Size:100];
            [imageview setImageWithURL:[NSURL URLWithString:Urlstring] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
            name.text = user.nick;
            des.text = user.signature.length<=0?@"Ta没有写任何东西":user.signature;
        }
        
    } withuid:userid];
    butondel.tag = indexPath.row;
    
    [butondel addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

-(IBAction)delClick:(id)sender
{
    UIButton * button = sender;

    NSString * userid = _datasource[button.tag];
    NSMutableArray * array = [[[EGOCache globalCache] plistForKey:KSingerCount] mutableCopy];
 
    //        NSMutableArray * array = [NSMutableArray arrayWithArray:oldarray];
    if (array) {
        if ([array containsObject:userid]) {
            //如果存在 就移除
            [array removeObject:userid];
            
            [[EGOCache globalCache] setPlist:array forKey:KSingerCount];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyKSonger" object:@"remove"];
            });
        }
    }
    [_datasource removeObjectAtIndex: button.tag];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * userid   = _datasource[indexPath.row];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        if (response) {
            
            XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
            addUser.UserInfo = response;
            [self.navigationController pushViewController:addUser animated:YES];
        }
    } withuid:userid];
 
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
