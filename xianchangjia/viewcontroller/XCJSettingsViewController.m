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
@property (weak, nonatomic) IBOutlet UILabel *UserSign;

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
    [self LoadData];
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
//        SLog(@"responseObject :%@",responseObject);
        // "users":[....]
        NSDictionary * userinfo = responseObject[@"result"];
        NSArray * userArray = userinfo[@"users"];
        if (userArray && userArray.count > 0) {
            NSDictionary * dic = userArray[0];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"nick"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_nick];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"headpic"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_headpic];
            [USER_DEFAULT setObject:[tools getStringValue:dic[@"signature"] defaultValue:@""] forKey:KeyChain_Laixin_account_user_signature];
            [USER_DEFAULT synchronize];
            
            self.UserSign.text =  [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];
            self.UserName.text =    [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
            [self.UserImageicon setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];
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
