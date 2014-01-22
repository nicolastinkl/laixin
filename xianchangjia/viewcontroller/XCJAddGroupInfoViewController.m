//
//  XCJAddGroupInfoViewController.m
//  laixin
//
//  Created by apple on 14-1-22.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJAddGroupInfoViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "XCJGroupPost_list.h"
#import "FCHomeGroupMsg.h"
#import "CoreData+MagicalRecord.h"
#import "QRCodeGenerator.h"

@interface XCJAddGroupInfoViewController ()
{
    XCJGroup_list * currentGroup;
}
@end

@implementation XCJAddGroupInfoViewController

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
    self.title = @"群信息";
	// Do any additional setup after loading the view.
    UIButton * button = ((UIButton * ) [self.view subviewWithTag:4]);
    [button addTarget:self action:@selector(AddGroupClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * newCode = [NSString stringWithFormat:@"[group]-%@",self.gid];
    ((UIImageView * ) [self.view subviewWithTag:6]).image  = [QRCodeGenerator qrImageForString:newCode imageSize:216.0f];
    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD showWithStatus:@"正在查找..."];
        
        NSDictionary * paramess = @{@"gid":@[self.gid]};
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
            NSDictionary * groupsss = responseObjects[@"result"];
            NSArray * groupsDicts =  groupsss[@"groups"];
            
            [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx == 0) {
                    XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                    currentGroup = list;
                    ((UILabel * ) [self.view subviewWithTag:1]).text = list.group_name;
                    ((UILabel * ) [self.view subviewWithTag:3]).text = list.group_board;
                    ((UILabel * ) [self.view subviewWithTag:2]).text = list.creator;
                }
            }];
            [SVProgressHUD dismiss];
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
        }];
    });    
}

-(IBAction)AddGroupClick:(id)sender
{
    if(currentGroup)
    {
         NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate *predicatess = [NSPredicate predicateWithFormat:@"gid == %@", self.gid];
        FCHomeGroupMsg *msg = [FCHomeGroupMsg MR_findFirstWithPredicate:predicatess inContext:localContext];
        if(msg == nil)
        {
            // 处理加入请求
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.join" parameters:@{@"gid":self.gid} success:^(MLRequest *request, id responseObject) {
                if(responseObject){
                    // Build the predicate to find the person sought
                    
                }
            } failure:^(MLRequest *request, NSError *error) {
                
            }];
            msg = [FCHomeGroupMsg MR_createInContext:localContext];
        }
        msg.gid = currentGroup.gid;
        msg.gCreatorUid = currentGroup.creator;
        msg.gName = currentGroup.group_name;
        msg.gBoard = currentGroup.group_board;
        msg.gDate = [NSDate dateWithTimeIntervalSinceNow:currentGroup.time];
        msg.gbadgeNumber = @1;
        msg.gType = [NSString stringWithFormat:@"%d",currentGroup.type];
        [localContext MR_saveToPersistentStoreAndWait];
        
        [SVProgressHUD showSuccessWithStatus:@"加入成功"];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"加入失败"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
