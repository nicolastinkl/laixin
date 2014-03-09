//
//  XCJSeeJiuShuiViewController.m
//  laixin
//
//  Created by apple on 3/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSeeJiuShuiViewController.h"
#import "XCAlbumAdditions.h"

#import "SKSTableView.h"
#import "SKSTableViewCell.h"

@interface XCJSeeJiuShuiViewController ()
{
    NSMutableArray * datasources;
}

@end

@implementation XCJSeeJiuShuiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"酒水价格预览";
    self.tableView.SKSTableViewDelegate = self;
    
    // In order to expand just one cell at a time. If you set this value YES, when you expand an cell, the already-expanded cell is collapsed automatically.
    self.tableView.shouldExpandOnlyOneCell = YES;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    datasources = array;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
    //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString * strJson =  [dictionary valueForKey:@"lebaihuiJIushuiList"];
    NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * responseObject =[datajson  objectFromJSONData] ;
    NSArray * arrays = responseObject[@"list"];
    [arrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * titleName =  obj[@"name"];
        NSArray * subArray = obj[@"list"];
        NSMutableArray  * Thisarray = [[NSMutableArray alloc] init];
        [subArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            JiuSInfoSub * subinfo = [JiuSInfoSub turnObject:obj];
            [Thisarray addObject:subinfo];
        }];
        JiuSInfo * info = [[JiuSInfo alloc] init];
        info.name = titleName;
        info.list = Thisarray;
        [datasources addObject:info];
        
    }];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [datasources count];


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    JiuSInfo * info = datasources[section];
    
    return [info.list count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    JiuSInfo * info = datasources[indexPath.section];
    
    return [info.list count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    JiuSInfo * info = datasources[indexPath.section];
    
    cell.textLabel.text = info.name;
    
    cell.isExpandable = YES;
//    
//    if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 0)) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2)))
//       
//    else
//        cell.isExpandable = NO;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JiuSInfo * info = datasources[indexPath.section];
   
    JiuSInfoSub * subinfo = info.list[indexPath.subRow - 1];
    
    UILabel * labelname = (UILabel  *) [cell.contentView subviewWithTag:1];
    UILabel * labelprice = (UILabel  *) [cell.contentView subviewWithTag:2];
    UILabel * labeltype = (UILabel  *) [cell.contentView subviewWithTag:3];
    UILabel * labelunit = (UILabel  *) [cell.contentView subviewWithTag:4];
    UILabel * labelml = (UILabel  *) [cell.contentView subviewWithTag:5];
    labelname.text = subinfo.name;
    labelprice.text = subinfo.price;
    labeltype.text = subinfo.unit;
    labelunit.text = subinfo.other;
    labelml.text = subinfo.type;
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    return 66.0f;
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


@implementation JiuSInfo


@end



@implementation JiuSInfoSub


@end