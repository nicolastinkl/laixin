//
//  XCJCommentViewController.m
//  xianchangjia
//
//  Created by apple on 13-12-16.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJCommentViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJSendCommentViewController.h"

@interface XCJCommentViewController ()
{
    NSMutableArray * commetArray;
}
@end

@implementation XCJCommentViewController
@synthesize talk_id,touserid,scene_id;
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
    
    self.title = @"评论";
    NSMutableArray * array = [[NSMutableArray alloc] init];
    commetArray = array;
    
    [self initCommentData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithTitle:@"写评论" style:UIBarButtonItemStylePlain target:self action:@selector(CommentClick:)];
     self.navigationItem.rightBarButtonItem = right;
}

-(IBAction)CommentClick:(id)sender
{
    XCJSendCommentViewController *viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSendCommentViewController"];
    viewcon.talk_id = self.talk_id;
    viewcon.scene_id = self.scene_id;
    viewcon.touserid = self.touserid;
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:viewcon];
    [self presentViewController:navi animated:YES completion:nil];
}

-(void) initCommentData
{
    SLog(@"self.talk_id: %lld",self.talk_id);
    NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
	[postdata setObject:[NSNumber numberWithLongLong:self.talk_id] forKey:@"post_id"];
	[postdata setObject:[NSNumber numberWithInt:0] forKey:@"offset"];
	[postdata setObject:[NSNumber numberWithInt:100] forKey:@"length"];
	[[GlobalData sharedGlobalData] addCommentCommandInfo:postdata];
	[[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"post_comment" Action:@"get_comments" success:^(id obj) {
        SLog(@"%@",obj);
        [self performSelector:@selector(getListFin:) withObject:obj];
	} error:^(NSInteger index) {
	} failure:^(NSError *error) {
	}];
}


-(void)getListFin:(NSDictionary*)result
{
	if(result)
	{
		NSArray *Commitlist=[result valueForKeyPath:@"list"];
        [Commitlist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CommitInfo *info=[[CommitInfo alloc] initWithJSONObject:obj];
            [commetArray addObject:info];
        }];
        [self.tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommitInfo *info= commetArray[indexPath.row];
    NSString * string =[NSString stringWithFormat:@"%@",info.words];
    return  [self heightForCellWithPost:string]+34.0f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  commetArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView * imageview = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel * nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel * contentLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel * timeLabel = (UILabel *)[cell.contentView viewWithTag:4];
    CommitInfo *info= commetArray[indexPath.row];
    [imageview setImageWithURL:info.avatar_small];
    
    NSString * string =[NSString stringWithFormat:@"%@",info.words];
    contentLabel.text = string;
    [contentLabel setHeight:[self heightForCellWithPost:string]];
    
    nameLabel.text = info.screen_name;
    timeLabel.text =  [tools FormatStringForDate:info.timestamp];
    return cell;
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(232.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
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
