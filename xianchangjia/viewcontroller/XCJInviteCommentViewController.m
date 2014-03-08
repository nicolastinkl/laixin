//
//  XCJInviteCommentViewController.m
//  laixin
//
//  Created by apple on 3/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJInviteCommentViewController.h"
#import "XCAlbumAdditions.h"
#import "Comment.h"


@interface XCJInviteCommentViewController ()
{
    NSMutableArray *  _datasource;
}
@end

@implementation XCJInviteCommentViewController

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

    
    self.title = @"用户留言";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.view showIndicatorViewLargeBlue];
    
    
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _datasource =array;
    NSDictionary * parames = @{@"postid":self.postid,@"pos":@0,@"count":@"100"};
    [[MLNetworkingManager sharedManager] sendWithAction:@"post.get_reply"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //    postid = 12;
        /*
         Result={
         “posts”:[*/
        NSDictionary * groups = responseObject[@"result"];
        NSArray * postsDict =  groups[@"replys"];
        if (postsDict && postsDict.count > 0) {
            [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Comment * comment = [Comment turnObject:obj];
                [_datasource addObject:comment];
                
            }];
            [self.tableView reloadData];
            [self.view hideIndicatorViewBlueOrGary];
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        [self showErrorText:@"请求失败,请重试"];
        [self.view hideIndicatorViewBlueOrGary];
    }];
    
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
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    UILabel * labelName = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    UILabel * labelContent = (UILabel *) [cell.contentView subviewWithTag:4];
    
    
    
    return cell;
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
