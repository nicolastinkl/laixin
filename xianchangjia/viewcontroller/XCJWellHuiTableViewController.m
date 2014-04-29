//
//  XCJWellHuiTableViewController.m
//  laixin
//
//  Created by tinkl on 29/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJWellHuiTableViewController.h"
#import "XCAlbumAdditions.h"
#import "JSONKit.h"
#import "UIActionSheet+Blocks.h"


#define NAME_CELL_ROW 0
#define IMAGE_CELL_ROW 1
#define USERABLE_CELL_ROW 2
#define CAPTION_CELL_ROW 3


@interface XCJWellHuiTableViewController ()
{
    NSMutableArray * groupList;
}
@end

@implementation XCJWellHuiTableViewController

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
    
    /**
     *  MARK: dosomething init... with tinkl
     */
    [self _init];
    
    NSString*filePath=[[NSBundle mainBundle] pathForResource:@"JsonOfVoiceFile"ofType:@"txt"];
    NSData * jsondata = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *jsonObj = [jsondata objectFromJSONData];
    NSDictionary * dataDict = jsonObj[@"data"];
    NSArray * array = dataDict[@"resultList"];
    [groupList addObjectsFromArray:array];
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        groupList = _init_array;
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
    return groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSDictionary * jsonDict = groupList[indexPath.section];
    if (indexPath.row == NAME_CELL_ROW) {
        return [self heightForCellWithPost:jsonDict[@"itemTitle"]];
    }else if (indexPath.row == IMAGE_CELL_ROW) {
        return 200;
    }else if (indexPath.row == USERABLE_CELL_ROW) {
       return 20+ [self heightForCellWithPost:jsonDict[@"shopName"]];
    }else if (indexPath.row == CAPTION_CELL_ROW) {
        return 50.0f;
    }
    return 0.0f;
    
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
    CGFloat maxWidth = 280.0f;//[UIScreen mainScreen].applicationFrame.size.width * 0.70f;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 20.0f );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * jsonDict = groupList[indexPath.section];
    UITableViewCell *cell;
    if (indexPath.row == NAME_CELL_ROW) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell" forIndexPath:indexPath];
    }else if (indexPath.row == IMAGE_CELL_ROW) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    }else if (indexPath.row == USERABLE_CELL_ROW) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UseableCell" forIndexPath:indexPath];
    }else if (indexPath.row == CAPTION_CELL_ROW) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    }
        
    if (indexPath.row == NAME_CELL_ROW) {
        UILabel * nameLabel =(UILabel *) [cell.contentView subviewWithTag:1];
        nameLabel.text = jsonDict[@"itemTitle"];
        nameLabel.height = [self heightForCellWithPost:jsonDict[@"itemTitle"]];
        nameLabel.width = 280;
        [nameLabel sizeToFit];
    }else if (indexPath.row == IMAGE_CELL_ROW) {
        UIImageView * imageview =(UIImageView *) [cell.contentView subviewWithTag:1];
        
        NSString * url =[NSString stringWithFormat:@"http://gw.alicdn.com/tps/%@",jsonDict[@"pictUrl"]];
        [imageview setImageWithURL:[NSURL URLWithString:url]];
        
    }else if (indexPath.row == USERABLE_CELL_ROW) {
        UILabel * nameLabel =(UILabel *) [cell.contentView subviewWithTag:1];
        nameLabel.text = jsonDict[@"shopName"];
        nameLabel.height = [self heightForCellWithPost:jsonDict[@"shopName"]];
        nameLabel.width = 280;
        [nameLabel sizeToFit];
    }else if (indexPath.row == CAPTION_CELL_ROW) {
        UILabel * phoneLabel =(UILabel *) [cell.contentView subviewWithTag:1];
        phoneLabel.text = [NSString stringWithFormat:@"电话：%@",jsonDict[@"tel"]];
        UILabel * addressLabel =(UILabel *) [cell.contentView subviewWithTag:2];
        addressLabel.text = [NSString stringWithFormat:@"地址：%@",jsonDict[@"address"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * jsonDict = groupList[indexPath.section];
    
    UIActionSheet * actionsheet =[[UIActionSheet alloc] initWithTitle:@"" cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"] destructiveButtonItem:[RIButtonItem itemWithLabel:jsonDict[@"tel"] action:^{
        NSMutableString * strURL = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",jsonDict[@"tel"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }] otherButtonItems:[RIButtonItem itemWithLabel:jsonDict[@"address"] action:^{
 //&daddr=%f,%f  saddr//起点终点
        NSString* urlText= [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%f,%f",[jsonDict[@"x"] floatValue],[jsonDict[@"y"] floatValue]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlText]];
        
    }], nil];
    [actionsheet showInView:self.view];
}

@end
