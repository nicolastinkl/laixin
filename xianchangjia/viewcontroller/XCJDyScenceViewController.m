//
//  XCJDyScenceViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-14.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJDyScenceViewController.h"
#import "DAHttpClient.h"
#import "TalkData.h"
#import "tools.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "YLLabel.h"
#import "JSONKit.h"
#import "UIView+Additon.h"
#import "DAImageResizedImageView.h"
#import "UIViewController+Indicator.h"
#import "XCJSendNewContentViewController.h"

@interface XCJDyScenceViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *tempdata;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation XCJDyScenceViewController
@synthesize scene_id;
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
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    tempdata=[[NSMutableArray alloc] init];
    [self loadtimeline];
}

-(void) loadtimeline
{
    [self showIndicatorViewAtpoint:CGPointMake((self.view.width-20)/2, (self.view.height-60)/2)];
    // post json
    //{"offset":"0&2013-01-01 22:10:37&new","length":20,"scene_id":126088,"sessionid":"f57c653a8b55496db0f9abf4e8843524"}
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:@"0&2013-01-01 22:10:37&new"  forKey:@"offset"];
    [params setValue:[NSNumber numberWithInt:50]  forKey:@"length"];
    [params setValue:[NSNumber numberWithInt:scene_id] forKey:@"scene_id"];
    params[@"stopsync"] = @0;
    NSLog(@"json : %@",[params JSONString]);
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:params controller:@"post" Action:@"get_scene_posts" success:^(id obj) {
        NSArray *oldtalk = [obj objectForKey:@"posts"];
        [oldtalk enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			TalkData *tdata=[[TalkData alloc] init];
            [tdata setData:obj];
            [tempdata addObject:tdata];
		}];
        [self.tableview reloadData];
        if (oldtalk && oldtalk.count > 0) {
            [self hideIndicatorView];
        }else{
            [self hideIndicatorView:@"没有数据" block:nil];
        }
    } error:^(NSInteger index) {
        NSLog(@"error .. ..");
        [self hideIndicatorView:@"加载失败" block:nil];        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    return tempdata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dymaicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSUInteger row = indexPath.row;
    if (row%2==0) {
        cell.contentView.backgroundColor = [UIColor colorWithHex:0xF0F0F0 ];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    TalkData * info  = tempdata[row];
    DAImageResizedImageView *imgView = (DAImageResizedImageView *)[cell.contentView viewWithTag:1];
    UILabel *UILabel_name = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *UILabel_gender = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *UILabel_timer = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *UILabel_content = (UILabel *)[cell.contentView viewWithTag:5];
    
    UILabel_name.text = info.userinfo.user_name;
    UILabel_gender.text = [NSString stringWithFormat:@"%@",info.userinfo.user_age];
    if (info.userinfo.user_gender == 0) {
        UILabel_gender.backgroundColor  = [UIColor redColor];
    }else{
        UILabel_gender.backgroundColor  = [UIColor blueColor];
    }
    
    UILabel_timer.text = [tools FormatStringForDate:info.time];
    
 
    UILabel_content.font = [UIFont systemFontOfSize:14.0f];
    NSString * string =[NSString stringWithFormat:@"%@",info.user_word];
    [UILabel_content setText:string];
    [UILabel_content setHeight:[self heightForCellWithPost:info.user_word]];
    
    {
        //user icon
        [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",info.userinfo.user_avatar_image]] ];
        DAImageResizedImageView *imgView2 = (DAImageResizedImageView *)[cell.contentView viewWithTag:12];
        [imgView2 setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",info.talk_img_small]] ];
       
    }
    return cell;
}

- (CGFloat)tableView:(__unused UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TalkData * info  = tempdata[indexPath.row];
    return  [self heightForCellWithPost:info.user_word]  + 45;
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(35.0f, sizeToFit.height + 25.0f );
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

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ShowPhotosInAlbumSegueIdentifier"])
    {
        
    }

    if ([[segue identifier] isEqualToString:@"SendPhotoViewIdentifier"])
    {
//        UIViewController * selfcontr =  [segue sourceViewController];
        XCJSendNewContentViewController * Desviewcontr =  [segue destinationViewController];
        Desviewcontr.scene_id = self.scene_id;
    }
}


@end
