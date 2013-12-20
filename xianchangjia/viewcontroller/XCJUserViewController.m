//
//  XCJUserViewController.m
//  xianchangjia
//
//  Created by apple on 13-12-13.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJUserViewController.h"
#import "XCJCommentViewController.h"
#import "XCAlbumAdditions.h"

@interface XCJUserViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * UserImageArray;
}
@end

@implementation XCJUserViewController
@synthesize userinfo;

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
	// Do any additional setup after loading the view.
    NSMutableArray * array = [[NSMutableArray alloc] init];
    UserImageArray = array;
    self.tableviewUser.delegate = self;
    self.tableviewUser.dataSource = self;
    self.tableviewUser.sectionHeaderHeight = 20.0f;
    if (userinfo) {
        [self.Image_userIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.userinfo.user_avatar_image]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        [self.Image_bg setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.userinfo.user_background_image]] placeholderImage:[UIImage imageNamed:@"img_player_bg"]];
        self.title = self.userinfo.user_name;
        self.Label_Userinfo.text = [NSString stringWithFormat:@"%@岁 %@",self.userinfo.user_age,@"双鱼"];
        
        [self LoadUserPhotosData];
    }
}
-(void) LoadUserPhotosData
{
    NSMutableDictionary * postdata = [[NSMutableDictionary alloc] init];
	[postdata setObject:[NSNumber numberWithInt:0] forKey:@"offset"];
	[postdata setObject:[NSNumber numberWithInt:50] forKey:@"length"];  //加载数据条数
	[postdata setObject:[NSNumber numberWithUnsignedInteger:self.userinfo.user_id] forKey:@"uid"];
	[[GlobalData sharedGlobalData] addCommentCommandInfo:postdata];
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:postdata controller:@"footprint" Action:@"get_user_photo_stream" success:^(id obj) {
        SLog(@"%@",obj);
        [self getUserPicLogListFin:obj];
    } error:^(NSInteger index) {
        
    } failure:^(NSError *error) {
        
    }];
}


-(void) getUserPicLogListFin:(NSDictionary*)result
{
    if(result!=nil)
    {
        NSArray* list=[result objectForKey:@"stream"];
		if (!list) {
			return;
		}
		NSMutableArray * array = [[NSMutableArray alloc] init];
        for(NSDictionary* oneinvite in list)
        {
            User_Piclog *data=[[User_Piclog alloc] initWithJSONObject:oneinvite];
			[array addObject:data];
        };
        [UserImageArray  addObjectsFromArray:array];
        [self.tableviewUser reloadData];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"个性签名";
    }
        return @"最新动态";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString * content = [NSString stringWithFormat:@"%@",self.userinfo.user_profile];
        return  [self heightForCellWithPost:content];
    }
    return  242.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50.0f;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return UserImageArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"SignCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (indexPath.section == 0) {
            UILabel * contentLabel = (UILabel *)[cell.contentView viewWithTag:1];
            NSString * content = [NSString stringWithFormat:@"%@",self.userinfo.user_profile];
            contentLabel.text =content;
            [contentLabel setHeight:[self heightForCellWithPost:content]];
        }
        return cell;
    }

    /*个人动态*/
    static NSString *CellIdentifier = @"DymaicUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 1) {
        User_Piclog * userPic = UserImageArray[indexPath.row];
        UIImageView * imageview = (UIImageView *)[cell.contentView viewWithTag:1];
        UILabel * contentLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel * timeLabel = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel * CommentLabel = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel * likdsLabel = (UILabel *)[cell.contentView viewWithTag:5];
        UILabel * idLabel = (UILabel *)[cell.contentView viewWithTag:8];
        UILabel * sceneidLabel = (UILabel *)[cell.contentView viewWithTag:9];
        UIButton * btn_Comment = (UIButton *)[cell.contentView viewWithTag:7];
        [btn_Comment addTarget:self action:@selector(CommentClick:) forControlEvents:UIControlEventTouchUpInside];
        idLabel.text = [NSString stringWithFormat:@"%lld", userPic.talkdataMain.talk_id];
        sceneidLabel.text =[NSString stringWithFormat:@"%d", userPic.talkdataMain.scene_id];
        contentLabel.text = userPic.talkdataMain.user_word;
//        [contentLabel setHeight:[self heightForCellWithPost:content]];
        timeLabel.text = [tools FormatStringForDate:userPic.time];
        CommentLabel.text = [NSString stringWithFormat:@"%d",userPic.talkdataMain.replycount];
        likdsLabel.text = [NSString stringWithFormat:@"%d",userPic.talkdataMain.likes];
        [imageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",userPic.url]]];
    }
    return cell;
}

-(IBAction) CommentClick:(id)sender
{
    UIButton * btn =  (UIButton *)sender;
    UIView * view =   btn.superview;
    UIView * views =   view.superview;
    UILabel * label = (UILabel *)[views viewWithTag:8];
    UILabel * labelSceneID = (UILabel *)[views viewWithTag:9];
    XCJCommentViewController *viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCommentViewController"];
    viewcon.talk_id = [label.text longLongValue];
    viewcon.scene_id = [labelSceneID.text intValue];
    viewcon.touserid = userinfo.user_id;
    [self.navigationController pushViewController:viewcon animated:YES];

}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
