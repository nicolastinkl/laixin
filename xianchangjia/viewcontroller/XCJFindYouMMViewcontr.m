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
#import "iCarousel.h"
#import "XCJFindMMView.h"
#import "UIView+Shadow.h"
#import "ChatViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Conversation.h"
#import "FCMessage.h"
#import "FCUserDescription.h"
#import "XCJFindMMFirtStupViewcontr.h"
#import "CRFAQTableViewController.h"
#import "HZAreaPickerView.h"

@interface XCJFindYouMMViewcontr ()<UIActionSheetDelegate,iCarouselDataSource, iCarouselDelegate,HZAreaPickerDelegate>
{
    UIButton * buttonChnagePhoto;
    UIButton * buttonChnageMenu ;
    UIView * viewSubMenu;
    UIView * viewSubPhoto ;
    
    NSMutableArray * datasource;
}

@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue,*CurrentUserid;
@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@end


enum actionTag {
    putMM = 1,
    findMM = 2,
    MoreClick = 3
};


@implementation XCJFindYouMMViewcontr
@synthesize carousel;
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
        [self.carousel setTop:(20)];
    }else{
        [self.carousel setTop:(64)];
    }

    self.carousel.decelerationRate = 0.5;
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.delegate = self;
    self.carousel.dataSource = self; 
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition  object:nil];
    
   
    
    
    NSString * location =  [USER_DEFAULT stringForKey:@"FINDMMLOCATION"];
    if (!location) {
        location = @"四川 成都";
        [USER_DEFAULT setValue:@"四川 成都" forKey:@"FINDMMLOCATION"];
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:location style:UIBarButtonItemStyleDone target:self action:@selector(changeLocationClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self findWithCity:location];
    
}

-(IBAction)changeLocationClick:(id)sender
{
    //居住地
    self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
    [self.locatePicker showInView:self.view];
}


-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.cityValue = [NSString stringWithFormat:@"%@ %@", picker.locate.state, picker.locate.city];

}

- (void) cancel
{
    [self cancelLocatePicker];
}

- (void) complate
{
    [self cancelLocatePicker];
    self.navigationItem.rightBarButtonItem.title = self.cityValue;
    [USER_DEFAULT setValue:self.cityValue forKey:@"FINDMMLOCATION"];
    [USER_DEFAULT synchronize];
    [datasource removeAllObjects];
    [self.carousel reloadData];
    [self findWithCity:self.cityValue];
}

-(void) showErrorInfoWithRetryNot:(NSNotification * ) notify
{
    [self hiddeErrorInfoWithRetry];
    // start retry
    
    NSString * location =  [USER_DEFAULT stringForKey:@"FINDMMLOCATION"];
    if (!location) {
        location = @"四川 成都";
        [USER_DEFAULT setValue:@"四川 成都" forKey:@"FINDMMLOCATION"];
    }
    [self findWithCity:location];
}

-(void) findWithCity:(NSString*) address
{
    [self hiddeErrorText]; 
    [self.view showIndicatorViewLargeBlue];
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
                    if (findmm.media_count > 0) {
                    
                        [datasource addObject:findmm];
                    }
                }];
                if (array.count <= 0) {
                    [self showErrorText:@"没有数据"];
                }else{
                    [self hiddeErrorText];
                }
                [self.view hideIndicatorViewBlueOrGary];
                [self.carousel reloadData];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [self.view hideIndicatorViewBlueOrGary];
            [self showErrorInfoWithRetry] ;//]showErrorText:@"请求失败,请检查网络设置"];
            
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
    [UIAlertView showAlertViewWithMessage:@"暂无抢妹记录"];
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
    [UIAlertView showAlertViewWithMessage:@"抱歉,您的等级不够,不能换一换"];
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
                
                [UIAlertView showAlertViewWithMessage:@"抱歉,等级不够,不能发自己"];
                
                /*
                 XCJRecommendLSFriendViewcontr * viewTr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJRecommendLSFriendViewcontr"];
                 viewTr.title = @"发自己";
                 [self.navigationController pushViewController:viewTr animated:YES];
                 */
            }
        }
            break;
        case MoreClick:
        {
            if (buttonIndex == 0) {
                //常见问题
                // custom initializer
                CRFAQTableViewController *faqViewController = [[CRFAQTableViewController alloc] initWithQuestions:@[@[@"Q : 来信也能抢你妹?", @"A : 是的,我们正在努力打造一款有趣好玩的抢你妹插件应用,你可以带上好奇的心来参加抢你妹,目前beta版本,还有很多不完善,欢迎小伙伴们吐槽哦~"],@[@"Q : 在哪里可以体验到抢你妹?", @"A : 在来信->想要->'抢你妹'点击成功之后即可体验抢你妹功能."],@[@"Q : 怎么样分享抢你妹给好友?", @"A : 直接按住电源键+home按键即可截图分享给好友."],@[@"Q : 怎么样才能抢到妹?", @"A : 只要是来信资深用户,都有50%几率抢到妹."],@[@"Q : 抢到妹妹之后怎么办?", @"A : 抢到妹之后来信团队会在一个工作日之类给您电话回访."]]];
                [faqViewController addQuestion:@"Q : 怎么样才能得到妹?" withAnswer:@"A : 来信团队会通知您并告知得到方式."];
                faqViewController.title = @"常见问题";
                [self.navigationController pushViewController:faqViewController animated:YES];
            }else if (buttonIndex == 1) {
                //我要吐槽
                
                
                [SVProgressHUD showWithStatus:@"正在处理..."];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {                    
                    FCUserDescription * user = response;
                    if (user) {
                        
                        [SVProgressHUD dismiss];
                        // target to chat view
                        NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
                        NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",user.uid];
                        Conversation * array =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
                        ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                        if (array) {
                            chatview.conversation = array;
                            
                            {
                                //系统消息公告
                                FCMessage * msg = [FCMessage MR_createInContext:localContext];
                                msg.messageType = @(messageType_SystemAD);
                                msg.text = @"我要吐槽:随便您发泄用着不爽的地方";
                                msg.sentDate = [NSDate date];
                                msg.audioUrl = @"";
                                // message did not come, this will be on rigth
                                msg.messageStatus = @(NO);
                                msg.messageId =  [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
                                msg.messageguid = @"";
                                msg.messageSendStatus = @0;
                                msg.read = @YES;
                                array.lastMessage = msg.text;
                                [array addMessagesObject:msg];
                            }
                        }else{
                            // create new
                            Conversation * conversation =  [Conversation MR_createInContext:localContext];
                            conversation.lastMessageDate = [NSDate date];
                            conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
                            conversation.messageStutes = @(messageStutes_incoming);
                            conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
                            conversation.facebookName = @"来信小助手";
                            conversation.facebookId = user.uid;
                            conversation.badgeNumber = @0;
                            {
                                //系统消息公告
                                FCMessage * msg = [FCMessage MR_createInContext:localContext];
                                msg.messageType = @(messageType_SystemAD);
                                msg.text = @"我要吐槽:随便您发泄用着不爽的地方";
                                msg.sentDate = [NSDate date];
                                msg.audioUrl = @"";
                                // message did not come, this will be on rigth
                                msg.messageStatus = @(NO);
                                msg.messageId =  [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
                                msg.messageguid = @"";
                                msg.messageSendStatus = @0;
                                msg.read = @YES;
                                conversation.lastMessage = msg.text;
                                [conversation addMessagesObject:msg];
                            }
                            [localContext MR_saveOnlySelfAndWait];
                            chatview.conversation = conversation;
                        }
                        chatview.userinfo = user;
                        chatview.title = user.nick;
                        [self.navigationController pushViewController:chatview animated:YES];
                    }else{
                        [SVProgressHUD dismiss];
                        [UIAlertView showAlertViewWithMessage:@"用户不存在!"];
                    }
                } withuid:@"24"]; //来信小助手                
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [datasource count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return [datasource count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	XCJFindMMView *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-44)];
        XCJFindMMView * findView = [[[NSBundle mainBundle] loadNibNamed:@"XCJFindMMView" owner:self options:nil] lastObject];
        label = findView;
//        findView.view_bg.layer.borderWidth = .2;
        findView.view_bg.layer.cornerRadius = 4;
        findView.view_bg.layer.masksToBounds = YES;
		[view addSubview:label];
        
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
	 XCJFindMM_list * findmm = datasource[index];
    if (findmm.media_count > 0 && findmm.medias.count <= 0 ) {
        
        if (!label.isrequestMedia) {
            label.isrequestMedia = YES;
            [[MLNetworkingManager sharedManager] sendWithAction:@"recommend.medias" parameters:@{@"uid":findmm.uid,@"recommend_uid":findmm.recommend_uid} success:^(MLRequest *request, id responseObject) {
                if (responseObject) {
                    NSDictionary * dict = responseObject[@"result"];
                    NSArray * array = dict[@"exdata"];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if (idx == 0) {
                            [label.image setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[DataHelper getStringValue:obj[@"picture"] defaultValue:@""] Size:640]]];
                        }
                        [findmm.medias addObject:[DataHelper getStringValue:obj[@"picture"] defaultValue:@""]];
                    }];
                }
                label.isrequestMedia = NO;
            } failure:^(MLRequest *request, NSError *error) {
                label.isrequestMedia = NO;
            }];
        }
    }else{
        if (findmm.medias.count > 0) {
            [label.image setImageWithURL:[NSURL URLWithString:[findmm.medias firstObject]]];
        }
    }
    [label setupThisData:findmm];
	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return  0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	return nil;
}


-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{    
    XCJFindMMFirtStupViewcontr * viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJFindMMFirtStupViewcontr"];
    XCJFindMM_list * findmmData = datasource[index];
    viewcon.data = findmmData;
    [self.navigationController pushViewController:viewcon animated:YES];
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return APP_SCREEN_WIDTH;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
