//
//  XCJSettingsViewController.m
//  xianchangjia
//
//  Created by apple on 13-11-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJSettingsViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"

@interface XCJSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *UserImageicon;
@property (weak, nonatomic) IBOutlet UILabel *UserName; 
@property (weak, nonatomic) IBOutlet UILabel *label_level;
@property (weak, nonatomic) IBOutlet UIImageView *image_level;
@property (weak, nonatomic) IBOutlet UIImageView *image_levelBg;
@property (weak, nonatomic) IBOutlet UIImageView *image_level_number;
@end

@implementation XCJSettingsViewController

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
    
//    LXUser * user =  [[LXAPIController sharedLXAPIController] currentUser];
//    self.title = user.nick;
    
    self.UserName.text =  [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    [self.UserImageicon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]] placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
    self.image_level_number.image = nil;
    if ([LXAPIController sharedLXAPIController].currentUser) {
        if ([LXAPIController sharedLXAPIController].currentUser.actor_level <= 0) {
            self.image_levelBg.width = 80;
            self.image_level_number.image = nil;
            self.label_level.textColor = [UIColor lightGrayColor];
            self.label_level.text = @"未激活";
            self.image_level.image = [UIImage imageNamed:@"face_vip"];
        }else{
            self.image_level.image = [UIImage imageNamed:@"face_vip"];
            self.label_level.textColor = [UIColor redColor];
            self.image_levelBg.width = 50;
//            self.label_level.text = [NSString stringWithFormat:@"%d",[LXAPIController sharedLXAPIController].currentUser.actor_level];
            self.image_level_number.image  = [UIImage imageNamed:[NSString stringWithFormat:@"mqz_widget_vip_lv%d",[LXAPIController sharedLXAPIController].currentUser.actor_level]];
        }
        self.UserName.textColor = [tools colorWithIndex:[LXAPIController sharedLXAPIController].currentUser.actor_level];
    }else{
        [self LoadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeNick:) name:@"changeSlefNick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSlefHeadpic:) name:@"changeSlefHeadpic" object:nil];
}

-(void) changeSlefHeadpic:(NSNotification *) notify
{
    if (notify.object) {
          [self.UserImageicon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:notify.object Size:100]] placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
    }
}

-(void) ChangeNick:(NSNotification *) notify
{
    if (notify.object) {
        self.UserName.text = notify.object;
    }
}

- (IBAction)updateInfoClick:(id)sender {
    NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
    NSDictionary * parames = @{@"nick":[NSString stringWithFormat:@"表弟 id%@",userid],@"signature":@" S开发中经常使用的数据持久化的技术。但其操作过程稍微繁琐，即使你只是实现简单的存"};
    //@"headpic":@"http://media.breadtrip.com/photos/2013/02/10/5b4cd8bc68fd765e9ca9e68313c8030f.jpg"
    //nick, signature,sex, birthday, marriage, height
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
//        SLog(@"responseObject :%@",responseObject);
        [self LoadData];
    } failure:^(MLRequest *request, NSError *error) {
    }];
}


-(void) LoadData
{
    NSString * userid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
    NSDictionary * parames = @{@"uid":@[userid]};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
        // "users":[....]
        NSDictionary * userinfo = responseObject[@"result"];
        NSArray * userArray = userinfo[@"users"];
        if (userArray && userArray.count > 0) {
            NSDictionary * dic = userArray[0];
            
            LXUser * user = [[LXUser alloc] initWithDict:dic];
            [LXAPIController sharedLXAPIController].currentUser = user;
            self.UserName.textColor = [tools colorWithIndex:[LXAPIController sharedLXAPIController].currentUser.actor_level];
            if ([LXAPIController sharedLXAPIController].currentUser.actor_level <= 0) {
                self.image_levelBg.width = 80;
                self.image_level_number.image = nil;
                self.label_level.textColor = [UIColor lightGrayColor];
                self.label_level.text = @"未激活";
                self.image_level.image = [UIImage imageNamed:@"threadInfoButtonSelected"];
            }else{
                self.image_level.image = [UIImage imageNamed:@"face_vip"];
                self.label_level.textColor = [UIColor redColor];
                self.image_levelBg.width = 50;
                self.image_level_number.image  = [UIImage imageNamed:[NSString stringWithFormat:@"mqz_widget_vip_lv%d",[LXAPIController sharedLXAPIController].currentUser.actor_level]];
            }
            
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"nick"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_nick];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"headpic"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_headpic];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"signature"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_signature];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"position"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_position];
            
            [USER_DEFAULT synchronize];
            
        self.UserName.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
            [self.UserImageicon setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]] placeholderImage:[UIImage imageNamed:@"left_view_avatar_avatar"]];
        }
    } failure:^(MLRequest *request, NSError *error) {
    }];
    
    /*
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    params[@"uid"] = @1571;
    [[DAHttpClient sharedDAHttpClient] defautlRequestWithParameters:params controller:@"user_profile" Action:@"profile" success:^(id obj) {
        if (obj)
        {
            NSDictionary *result=[obj objectForKey:@"user"];
            if ([result valueForKeyPath:@"avatar"]) {
                NSString * strurl = [NSString stringWithFormat:@"%@",[result valueForKeyPath:@"avatar"]];
                NSString * newurl = [tools ReturnNewURLBySize:strurl lengDp:180 status:@""];
                [self.UserImageicon setImageWithURL:[NSURL URLWithString:newurl]];
            }
            self.UserSign.text =  [result objectForKey:@"signature"];
            self.UserName.text =   [result objectForKey:@"name"];
            
        }
    } error:^(NSInteger index) {
    } failure:^(NSError *error) {
    }];
     */
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
