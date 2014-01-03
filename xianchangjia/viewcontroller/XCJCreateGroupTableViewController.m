//
//  XCJCreateGroupTableViewController.m
//  laixin
//
//  Created by apple on 14-1-3.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJCreateGroupTableViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "NSString+Addition.h"
#import "NSStringAddition.h"
#import "DataHelper.h"
#import "XCJGroupPost_list.h"
#import "UIAlertViewAddition.h"


@interface XCJCreateGroupTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *GroupName;

@end

@implementation XCJCreateGroupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)cancelClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)ComplateClick:(id)sender {
    /**
     *  16 group.create(name,board,type) 创建群
     Result={“gid”:1}
     */
    if ([self.GroupName.text isNilOrEmpty]) {
        return;
    }
    
    NSDictionary * parames = @{@"name":self.GroupName.text ,@"board":@"",@"type":@1};
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.create"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //Result={“gid”:1}
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"Result"];
            NSString * gid =  [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
            XCJGroup_list * list = [[XCJGroup_list alloc] init];
            list.gid = gid;
            list.group_name = self.GroupName.text;
            list.group_board = @"";
            list.type  = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_changeDomainID" object:list];
            [self cancelClick:nil];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"创建失败"];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
