//
//  XCJFindYouMMViewcontr.m
//  laixin
//
//  Created by apple on 2/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJFindYouMMViewcontr.h"
#import "XCAlbumAdditions.h"
#import "XCJRecommendLSFriendViewcontr.h"
#import "XCJGroupPost_list.h"


@interface XCJFindYouMMViewcontr ()<UIActionSheetDelegate>
{
    UIButton * buttonChnagePhoto;
    UIButton * buttonChnageMenu ;
    UIView * viewSubMenu;
    UIView * viewSubPhoto ;
    
    NSMutableArray * datasource;
}

@end


enum actionTag {
    putMM = 1,
    findMM = 2,
    MoreClick = 3
};


@implementation XCJFindYouMMViewcontr

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
    
    UIView * viewSub = [self.view subviewWithTag:1];
    if (!IS_4_INCH) {
        [viewSub setTop:APP_SCREEN_HEIGHT-44];
    }

    buttonChnageMenu = (UIButton *)  [viewSub subviewWithTag:1];
    buttonChnagePhoto = (UIButton *)  [viewSub subviewWithTag:2];
    
    buttonChnageMenu.hidden = NO;
    buttonChnagePhoto.hidden = YES;
    
    viewSubMenu = [viewSub subviewWithTag:10];
    viewSubPhoto = [viewSub subviewWithTag:20];
    
    [((UIButton *)  [viewSub subviewWithTag:3]) setHeight:0.7];

    NSMutableArray * array = [[NSMutableArray alloc] init];
    datasource = array;
	// Do any additional setup after loading the view.
    
    [self.view showIndicatorViewLargeBlue];
    
    [self findWithCity:@"四川 成都"];
    
}


-(void) findWithCity:(NSString*) address
{
    double delayInSeconds = 0.1f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        /*   {"func":"recommend.search",
         "parm":{
         "city":"四川 成都",
         "sex":1} }   */
        [[MLNetworkingManager sharedManager] sendWithAction:@"recommend.search" parameters:@{@"city":address,@"sex":@"1"} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * dict = responseObject[@"result"];
                NSArray * array =  dict[@"recommends"];
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    XCJFindMM_list * findmm = [XCJFindMM_list turnObject:obj];
                    [datasource addObject:findmm];
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [self.view hideIndicatorViewBlueOrGary];

        }];
    });
}

-(IBAction)ChnagePhotoClick:(id)sender
{
    buttonChnageMenu.hidden = NO;
    buttonChnagePhoto.hidden = YES;
    
    viewSubMenu.hidden = YES;
    viewSubPhoto.hidden = NO;
}

-(IBAction)ChnageMenuClick:(id)sender
{
    buttonChnageMenu.hidden = YES;
    buttonChnagePhoto.hidden = NO;
    
    viewSubMenu.hidden = NO;
    viewSubPhoto.hidden = YES;
}

//发MM
- (IBAction)PutMMClick:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发妹妹" otherButtonTitles:@"发自己", nil];
    sheet.tag = putMM;
    [sheet showInView:self.view];
}

//抢M
- (IBAction)FindMMClick:(id)sender {
//    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看抢妹历史记录", nil];
//    sheet.tag = findMM;
//    [sheet showInView:self.view];
}

- (IBAction)MoreClick:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"常见问题",@"我要吐槽", nil];
    sheet.tag = MoreClick;
    
    [sheet showInView:self.view];
}

// *  换一换
- (IBAction)ChangeClick:(id)sender {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case putMM:
        {
            if (buttonIndex == 0) {
                XCJRecommendLSFriendViewcontr * viewTr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJRecommendLSFriendViewcontr"];
                viewTr.title = @"发妹妹";
                [self.navigationController pushViewController:viewTr animated:YES];
            }else if (buttonIndex == 1) {
                XCJRecommendLSFriendViewcontr * viewTr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJRecommendLSFriendViewcontr"];
                viewTr.title = @"发自己";
                [self.navigationController pushViewController:viewTr animated:YES];
            }
        }
            break;
        case MoreClick:
        {
            if (buttonIndex == 0) {
                
            }else if (buttonIndex == 1) {
                
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
