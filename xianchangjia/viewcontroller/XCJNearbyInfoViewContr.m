//
//  XCJNearbyInfoViewContr.m
//  laixin
//
//  Created by apple on 2/28/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJNearbyInfoViewContr.h"
#import "XCAlbumAdditions.h"
#import "FCUserDescription.h"

@interface XCJNearbyInfoViewContr ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_likeCount;
@property (weak, nonatomic) IBOutlet UILabel *label_address;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UILabel *label_comment;
@property (weak, nonatomic) IBOutlet UILabel *label_type;
@property (weak, nonatomic) IBOutlet UIImageView *image_user;
@property (weak, nonatomic) IBOutlet UIImageView *image_user_sex;
@property (weak, nonatomic) IBOutlet UILabel *label_user_nick;
@property (weak, nonatomic) IBOutlet UIImageView *image_level;
@property (weak, nonatomic) IBOutlet UILabel *label_info;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation XCJNearbyInfoViewContr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
   
}

-(void) initallContr:( XCJGroup_list * ) groupinfo
{
    self.groupinfo = groupinfo;
    self.label_name.text = self.groupinfo.group_name;
    self.label_address.text = self.groupinfo.position;
    self.label_time.text = @"明               天";
    self.label_type.text = self.groupinfo.group_board;
    
    self.image_user.layer.cornerRadius = self.image_user.height/2;
    self.image_user.layer.masksToBounds = YES;
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
        FCUserDescription * user = response;
        //内容
        if (user.headpic) {
            [self.image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        }else{
            [self.image_user setImage:[UIImage imageNamed:@"avatar_default"] ];
        }
        self.label_user_nick.text = user.nick;
        self.image_level.image = [UIImage imageNamed:[NSString stringWithFormat:@"mqz_widget_vip_lv%d",[user.actor_level intValue]]];
        if ([user.sex intValue] == 1) {
            self.image_user_sex.image = [UIImage imageNamed:@"md_boy"];
        }else if ([user.sex intValue] == 2) {
            self.image_user_sex.image = [UIImage imageNamed:@"md_girl"];
        }
    } withuid:self.groupinfo.creator];
    
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSDictionary * parames = @{@"gid":self.groupinfo.gid,@"pos":@0,@"count":@"1"};
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //    postid = 12;
            /*
             Result={
             “posts”:[*/
            if (responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"posts"];
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                    self.label_likeCount.text = [NSString stringWithFormat:@"%d",post.like];
                    self.label_comment.text = [NSString stringWithFormat:@"%d",post.replycount];
                    self.label_info.text = post.content;
                }];
            }else{
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
        }];
        
    });
//    [self.tableview reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
