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


@interface XCJFindYouMMViewcontr ()<UIActionSheetDelegate,iCarouselDataSource, iCarouselDelegate>
{
    UIButton * buttonChnagePhoto;
    UIButton * buttonChnageMenu ;
    UIView * viewSubMenu;
    UIView * viewSubPhoto ;
    
    NSMutableArray * datasource;
}
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
                    if (findmm.media_count > 0) {
                        [datasource addObject:findmm];
                    }
                }];
                [self.view hideIndicatorViewBlueOrGary];
                [self.carousel reloadData];
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
                            [label.image setImageWithURL:[NSURL URLWithString:[DataHelper getStringValue:obj[@"picture"] defaultValue:@""]]];
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
