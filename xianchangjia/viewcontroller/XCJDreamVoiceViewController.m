//
//  XCJDreamVoiceViewController.m
//  laixin
//
//  Created by apple on 4/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDreamVoiceViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "MTAnimatedLabel.h"
#import "XCJWellDreamTableViewController.h"

@interface XCJDreamVoiceViewController ()<UIActionSheetDelegate>
{
    NSString *CurrentGID;
}
@property (strong, nonatomic) IBOutlet MTAnimatedLabel *animatinLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation XCJDreamVoiceViewController

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
    CurrentGID = @"61"; //新都梦想好声音
    UIView * view = [self.view subviewWithTag:1];
//    MTAnimatedLabel * label = (MTAnimatedLabel *) [view subviewWithTag:2];
//    [self.view addSubview:label];
//    label.frame = CGRectMake(20, APP_SCREEN_CONTENT_HEIGHT - 50, 204, 21);
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
    UIButton * button = (UIButton *) [view subviewWithTag:3];
    [button sendMessageStyle];
    
    [view setTop:APP_SCREEN_CONTENT_HEIGHT - view.height];
    self.animatinLabel.text = @"已有??人参加";
    [button addTarget:self action:@selector(joinThisinviteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.members" parameters:@{@"gid":CurrentGID} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"result"];
            NSArray * arr =  dict[@"members"];
            self.animatinLabel.text = [NSString stringWithFormat:@"已有%d人参加",arr.count];
        }
    } failure:^(MLRequest *request, NSError *error) {
    }];
    
}

-(IBAction)joinThisinviteClick:(id)sender
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"参加成功后即可对你喜欢的选手投票" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"立即参加" otherButtonTitles:nil, nil];
    [actionsheet showInView:self.view];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.animatinLabel startAnimating];
}

-(void)dealloc
{
    if (self.animatinLabel) {
        [self.animatinLabel stopAnimating];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [SVProgressHUD showWithStatus:@"正在加入"];
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.join" parameters:@{@"gid":CurrentGID} success:^(MLRequest *requestsd, id responseObjectsd) {
            if (responseObjectsd) {
                [SVProgressHUD dismiss];
                [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_dream_goodvoice];
                [USER_DEFAULT synchronize];
//                [UIAlertView showAlertViewWithMessage:@"参加成功"];
                [self.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"openDreamGoodVoice" object:nil];                
            }else{
                [UIAlertView showAlertViewWithMessage:@"参加失败"];
            }
        } failure:^(MLRequest *requestsd, NSError *errorsd) {
            [SVProgressHUD  dismiss];
            [UIAlertView showAlertViewWithMessage:@"参加失败"];
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
