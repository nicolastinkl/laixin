//
//  XCJFindRoomViewControl.m
//  laixin
//
//  Created by apple on 3/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJFindRoomViewControl.h"
#import "XCAlbumAdditions.h"
#import "XCJRoomInfoViewcontroller.h"

@interface XCJFindRoomViewControl ()<UIActionSheetDelegate>
{
    NSMutableArray * datasources;
    LocationInfo * locationinfo;
}
@end

@implementation XCJFindRoomViewControl

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    datasources = array;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
    //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString * strJson =  [dictionary valueForKey:@"lebaihuibaolizhongxin"];
    NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * responseObject =[datajson  objectFromJSONData] ;
    NSArray * arrays = responseObject[@"list"];
    [arrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        roomInfo * rom = [roomInfo turnObject:obj];
        if (rom) {
            [datasources addObject:rom];
        }
    }];
    
    LocationInfo * locaot = [LocationInfo turnObject:responseObject];
    locationinfo = locaot;
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];//allocate titleView
    titleView.backgroundColor=[UIColor clearColor];
    //Create UILable
    UILabel *titleText = [[UILabel alloc] initWithFrame: titleView.frame];//allocate titleText
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor = [UIColor whiteColor];
    titleText.textAlignment = UITextAlignmentCenter;
    [titleText setText:@"乐佰汇"];
    [titleView addSubview:titleText];
    
    UILabel *desText = [[UILabel alloc] initWithFrame: CGRectMake(0, 24, 200, 20)];//allocate titleText
    desText.backgroundColor = [UIColor clearColor];
    desText.textColor = [UIColor whiteColor];
    desText.textAlignment = UITextAlignmentCenter;
    desText.font = [UIFont systemFontOfSize:12.0f];
    [desText setText:@"成都"];
    [titleView addSubview:desText];
    
    //Create Round UIButton
//    UIButton *btnNormal = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btnNormal setFrame:CGRectMake(0, 0, 40, 20)];
//    [btnNormal addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [btnNormal setTitle:@"Normal" forState:UIControlStateNormal];
//    [titleView addSubview:btnNormal];
    
    
    //Set to titleView
    self.navigationItem.titleView = titleView;
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保利店" style:UIBarButtonItemStyleDone target:self action:@selector(chooseRoomClick:)];
    self.navigationItem.rightBarButtonItem =  rightBarButtonItem;
}

-(IBAction)chooseRoomClick:(id)sender
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"目前只开通了成都保利店,后续开通更多店铺" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保利店" otherButtonTitles:nil, nil];
    [actionsheet showInView:self.view];
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
    return datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    roomInfo * rom = datasources[indexPath.row];
    UILabel * label_RoomBg =  (UILabel *)[cell.contentView subviewWithTag:1];
    UILabel * label_Room_name =  (UILabel *)[cell.contentView subviewWithTag:2];
    UILabel * label_Room_Type =  (UILabel *)[cell.contentView subviewWithTag:3];
    UILabel * label_room_peo_num =  (UILabel *)[cell.contentView subviewWithTag:4];
    UILabel * label_room_address =  (UILabel *)[cell.contentView subviewWithTag:5];
    UILabel * label_room_price =  (UILabel *)[cell.contentView subviewWithTag:6];
    UILabel * label_room_price_90 =  (UILabel *)[cell.contentView subviewWithTag:7];
    
    [((UILabel *)[cell.contentView subviewWithTag:9]) setHeight:.5];
    [((UILabel *)[cell.contentView subviewWithTag:9]) setTop:89.5];
    
    label_Room_name.text = rom.name;
    label_Room_Type.text = rom.type;
    label_room_peo_num.text = [NSString stringWithFormat:@"适合%@人",rom.parensNumber];
    label_room_address.text = locationinfo.location;
    label_room_price_90.text = [NSString stringWithFormat:@"￥%@",rom.lowprice];
    int lowPrice = [rom.lowprice intValue]*.9;
    label_room_price.text = [NSString stringWithFormat:@"￥%d",lowPrice];
    
    int colorindex = indexPath.row % 6 + 1 ;
    label_RoomBg.backgroundColor  = [tools colorWithIndex:colorindex];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    XCJRoomInfoViewcontroller * rominfoView = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJRoomInfoViewcontroller"];
    roomInfo * rom = datasources[indexPath.row];
    rominfoView.rominfo  = rom;
    rominfoView.locatinfo = locationinfo;
    [self.navigationController pushViewController:rominfoView animated:YES];
    
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

@implementation LocationInfo


@end

@implementation roomInfo


@end
