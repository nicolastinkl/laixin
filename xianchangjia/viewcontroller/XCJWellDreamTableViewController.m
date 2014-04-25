//
//  XCJWellDreamTableViewController.m
//  laixin
//
//  Created by apple on 4/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.


#import "XCJWellDreamTableViewController.h"
#import "UIButton+WebCache.h"
#import "XCAlbumAdditions.h"
#import "PWLoadMoreTableFooterView.h"
//#import <OHAttributedLabel/OHAttributedLabel.h>
//#import <OHAttributedLabel/NSAttributedString+Attributes.h>
//#import <OHAttributedLabel/OHASBasicMarkupParser.h>
#import "XCJGroupPost_list.h"
#import "FCUserDescription.h"
#import "IDMPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DAImageResizedImageView.h"
#import "XCJContentTypesCell.h"
#import "SBSegmentedViewController.h"
#import "XCJAddUserTableViewController.h"
#import "XCJAppDelegate.h"
#import "YLLabel.h"


#define DISTANCE_BETWEEN_ITEMS  9.0
#define LEFT_PADDING            9.0
#define ITEM_WIDTH              135.0
#define TITLE_HEIGHT            40.0
#define TITLE_jianxi            2.5

#define colNumber 4

enum ENUMLoadMoreData {
    Enum_initData  = 0,
    Enum_UpdateTopData = 1,
    Enum_MoreData = 2
    
};

#define kAttributedLabelTag 211
///OHAttributedLabelDelegate
@interface XCJWellDreamTableViewController ()<PWLoadMoreTableFooterDelegate,UIActionSheetDelegate>
{
    NSMutableArray * groupList;
    PWLoadMoreTableFooterView *_loadMoreFooterView;
    BOOL _datasourceIsLoading;
    bool _allLoaded;
    NSString  *_Currentgid;
    NSString * CurrentUrl;
}

@end

@implementation XCJWellDreamTableViewController

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
    
    /**
     *  MARK: dosomething init... with tinkl
     */
    [self _init];
    
//    [[OHAttributedLabel appearance] setLinkColor:ios7BlueColor];
//    [[OHAttributedLabel appearance] setHighlightedLinkColor:[UIColor colorWithWhite:0.4 alpha:0.3]];
//    [[OHAttributedLabel appearance] setLinkUnderlineStyle:kCTUnderlineStyleNone];
   
    _Currentgid = @"61";
    
    /*!
     *  parse data
     *
     *  @since <#version number#>
   
    PFObject *gameScore = [PFObject objectWithClassName:@"LaixinNewVoice"];
    gameScore[@"WebUrl"] = @"http://mp.weixin.qq.com/s?__biz=MjM5MDI0MzMxMw==&mid=200246465&idx=1&sn=76577eebb9c4a89e30f073e9e3267a4a";
    gameScore[@"ContentText"] = @"..........";
    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            SLog(@"succeeded");
        else
            SLog(@"error %@",error.userInfo);
        
    }]; */
    
    
    
    //config the load more view
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    self.tableView.tableFooterView = _loadMoreFooterView;
    
    /**
     *  MARK: init 0..
     */
    _allLoaded = NO;
    _datasourceIsLoading = YES;
    
    /**
     * MARK: init net data.
     */
    [self initDatawithNet:Enum_initData];
    
    SBSegmentedViewController *segmentedViewController =  (SBSegmentedViewController *)self.navigationController.visibleViewController;
    UIBarButtonItem * barOne = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threadInfoButtonMinified"] style:UIBarButtonItemStyleDone target:self action:@selector(JoinDreamClick:)];
    segmentedViewController.navigationItem.rightBarButtonItem = barOne;
    
}

-(IBAction)JoinDreamClick:(id)sender
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"请选择您的参赛角色" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选手",@"粉丝团", nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.navigationController.view];
}


-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        groupList = _init_array;
    }
}



- (void)initDatawithNet:(NSInteger) typeIndex
{
    
    switch (typeIndex) {
        case Enum_initData:
        {
            NSDictionary * parames = @{@"gid":_Currentgid,@"pos":@0,@"count":@"20"};
            
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
                        [groupList addObject:post];
                       
                    }];
                    if (postsDict.count >= 20) {
                        _allLoaded = NO;
                    }else{
                        _allLoaded = YES;
                    }
                }else{
                    [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
                }
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];

            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];

                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
            
        }
            break;
        case Enum_UpdateTopData:
        {
            //group.get_new_post(gid,frompos) 取得新消息，从某个位置开始，用于掉线后重新连上的情况
            //                Result=同11
            NSString * lastID = 0;
            if (groupList.count  > 0) {
                XCJGroupPost_list * post =[groupList firstObject];
                lastID = post.postid;
            }else{
                lastID = @"0";
            }
            NSDictionary* parames = @{@"gid":_Currentgid,@"frompos":lastID};
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.get_new_post" parameters:parames success:^(MLRequest *request, id responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"posts"];
                __block NSInteger lasID = 0;
                if (postsDict &&  postsDict.count > 0) {
                    [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                        if (post) {
                            lasID = [post.postid integerValue];
                            [groupList insertObject:post atIndex:0];
                        }
                    }];
                    _datasourceIsLoading = NO;
                    [self doneLoadingTableViewData];
                }
                
            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
        }
            break;
        case Enum_MoreData:
        {
            NSInteger postid ;
            if (groupList.count >= 20) {
                XCJGroupPost_list * post =[groupList lastObject];
                postid = [post.postid intValue];
            }else{
                postid = 0;
            }
            NSDictionary* parames = @{@"gid":_Currentgid,@"pos":@(postid),@"count":@"20"};
            
            [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //    postid = 12;
                /*
                 Result={
                 “posts”:[*/
                if (responseObject) {
                    NSDictionary * groups = responseObject[@"result"];
                    NSArray * postsDict =  groups[@"posts"];
                    if (postsDict && postsDict.count > 0) {
                        [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                            [groupList addObject:post];
                        }];
                        if (postsDict.count >= 20) {
                            _allLoaded = NO;
                        }else{
                            _allLoaded = YES;
                        }
                    }
                    _datasourceIsLoading = NO;
                    [self doneLoadingTableViewData];
                }
                
            } failure:^(MLRequest *request, NSError *error) {
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }];
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark -
#pragma mark PWLoadMoreTableFooterDelegate Methods

- (void)pwLoadMore {
    //just make sure when loading more, DO NOT try to refresh your data
    //Especially when you do your work asynchronously
    //Unless you are pretty sure what you are doing
    //When you are refreshing your data, you will not be able to load more if you have pwLoadMoreTableDataSourceIsLoading and config it right
    //disable the navigationItem is only demo purpose
    
    _datasourceIsLoading = YES;
    [self initDatawithNet:Enum_MoreData];
    
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData {
	//  model should call this when its done loading
	[_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
    [self.tableView reloadData];
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _datasourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}


#pragma mark - XLSwipeContainerItemDelegate

-(id)swipeContainerItemAssociatedSegmentedItem
{
    return @"动态";
}

-(UIColor *)swipeContainerItemAssociatedColor
{
    return [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    XCJGroupPost_list * post = groupList[section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        return 4;
    }
    
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = groupList[indexPath.section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        switch (indexPath.row) {
            case 0:
                return 44.0f;
                break;
            case 1:
            {
                float imageviewHeight = (post.excount/colNumber)*65 +(post.excount/colNumber)*TITLE_jianxi;
                if (post.excount%colNumber>0) {
                    imageviewHeight += TITLE_jianxi+65;
                }
                return imageviewHeight + 10; //content
            }
                break;
            case 2:
                return [self textHeight:post.content];//text
                break;
            case 3:
                return 44.0f;
                break;
                
            default:
                break;
        }
    }
    switch (indexPath.row) {
        case 0:
            return 44.0f;
            break;
        case 1:
            return [self textHeight:post.content];//text
            break;
        case 2:
            return 44.0f;
            break;
            
        default:
            break;
    }
    return 0.0f;
}

-(float) textHeight:(NSString *) text
{
    CGFloat maxWidth = 300.0f;//[UIScreen mainScreen].applicationFrame.size.width * 0.70f;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 20.0f );
}

-(IBAction)commentClick:(id)sender
{
    UIButton * button = sender;
    UITableViewCell * cell = (UITableViewCell *)button.superview.superview.superview;
    XCJGroupPost_list * post = groupList[ [self.tableView indexPathForCell:cell].section];
    if (post) {
        
        SBSegmentedViewController *segmentedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBSegmentedCommentController"];
        segmentedViewController.position = SBSegmentedViewControllerControlPositionNavigationBar;
        [segmentedViewController addStoryboardSegments:@[@"SegmentComment", @"SegmentLikes"]];
        segmentedViewController.someobject = post;
        [self.navigationController pushViewController:segmentedViewController animated:YES];
         
    }
}

-(IBAction)likeClick:(id)sender
{
    UIButton * likeButton = sender;
    UITableViewCell * cell = (UITableViewCell *)likeButton.superview.superview.superview;
    XCJGroupPost_list * post = groupList[ [self.tableView indexPathForCell:cell].section];
    
    
    likeButton.enabled = NO;
    //赞
    if (!post.ilike) {
        NSDictionary * parames = @{@"postid":post.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
            post.ilike = YES;
            post.like ++;
            likeButton.enabled = YES;
            [self refreshbutton:likeButton withdata:post];
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"操作失败"];
        }];
    }else{
        NSDictionary * parames = @{@"postid":post.postid};
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.dislike"  parameters:parames success:^(MLRequest *request, id responseObject) {
            post.like -- ;
            post.ilike = NO;
            likeButton.enabled = YES;
            [self refreshbutton:likeButton withdata:post];
        } failure:^(MLRequest *request, NSError *error) {
            likeButton.enabled = YES;
            [UIAlertView showAlertViewWithMessage:@"操作失败"];
        }];
    }
    
    //执行赞图标放大的动画
    likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
    [UIView animateWithDuration:.50f
                     animations:^{
                         likeButton.imageView.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                      
                     }];
}

-(void) refreshbutton:(UIButton *) likeButton withdata:(XCJGroupPost_list * ) post
{
    if (!post.ilike)
        [likeButton setImage:[UIImage imageNamed:@"home_tl_ic_like_nor"] forState:UIControlStateNormal];
    else
        [likeButton setImage:[UIImage imageNamed:@"home_tl_ic_liked_nor"] forState:UIControlStateNormal];
    
    [likeButton setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
}

-(IBAction)shareClick:(id)sender
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"分享该动态给好友" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友",@"微信朋友圈", nil];
    actionsheet.tag = 2;
    [actionsheet showInView:self.view];
}

#pragma mark cellfor

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    XCJGroupPost_list * post = groupList[indexPath.section];
    // Return the number of rows in the section.
    if (post.imageURL.length > 4 || post.excount > 0) {   //图片
        switch (indexPath.row) {
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKCONTENTCELL" forIndexPath:indexPath];
            }
                break;
            case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKREICKTEXTCELL" forIndexPath:indexPath];
                
                UILabel* labelContent = (UILabel*)[cell viewWithTag:kAttributedLabelTag];
                if (labelContent == nil) {
                    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
                    labelContent.tag = kAttributedLabelTag;
                    labelContent.numberOfLines = 0;
                    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
                    labelContent.font = [UIFont systemFontOfSize:16.0f];
                    [cell addSubview:labelContent];
                    //  labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
                }
                labelContent.text = [NSString stringWithFormat:@"%@",post.content];
                [labelContent sizeToFit];
                
                [labelContent setWidth:300.0f];
                [labelContent setHeight:[self textHeight:[NSString stringWithFormat:@"%@",post.content]]];
                
                [labelContent setTop:0.0f];
                [labelContent setLeft:10.0f];
            }
                break;
            case 3:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKOPERATIONCELL" forIndexPath:indexPath];
                
                UIButton * buttonComment =(UIButton *)  [cell.contentView subviewWithTag:1];
                UIButton * buttonLike =(UIButton *)  [cell.contentView subviewWithTag:2];
                UIButton * buttonHSare =(UIButton *)  [cell.contentView subviewWithTag:3];
                UIView * lineView =[cell.contentView subviewWithTag:5];
                [lineView setHeight:0.5];
                [buttonComment setTitle:[NSString stringWithFormat:@"%d",post.replycount] forState:UIControlStateNormal];
                [buttonLike setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
                [self refreshbutton:buttonLike withdata:post];
                [buttonComment addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonLike addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonHSare addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
                
                
            }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKREICKTEXTCELL" forIndexPath:indexPath];
                UILabel* labelContent = (UILabel*)[cell viewWithTag:kAttributedLabelTag];
                if (labelContent == nil) {
                    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
                    labelContent.tag = kAttributedLabelTag;
                    labelContent.numberOfLines = 0;
                    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
                    labelContent.font = [UIFont systemFontOfSize:16.0f];
                    [cell addSubview:labelContent];
                    //  labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
                }
                labelContent.text = [NSString stringWithFormat:@"%@",post.content];
                [labelContent sizeToFit];
                
                [labelContent setWidth:300.0f];
                [labelContent setHeight:[self textHeight:[NSString stringWithFormat:@"%@",post.content]]];
                
                [labelContent setTop:0.0f];
                [labelContent setLeft:10.0f];
            }
                break;
            case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TKOPERATIONCELL" forIndexPath:indexPath];
                UIButton * buttonComment =(UIButton *)  [cell.contentView subviewWithTag:1];
                UIButton * buttonLike =(UIButton *)  [cell.contentView subviewWithTag:2];
                UIButton * buttonHSare =(UIButton *)  [cell.contentView subviewWithTag:3];
                [buttonComment setTitle:[NSString stringWithFormat:@"%d",post.replycount] forState:UIControlStateNormal];
                [buttonLike setTitle:[NSString stringWithFormat:@"%d",post.like] forState:UIControlStateNormal];
                [self refreshbutton:buttonLike withdata:post];
                [buttonComment addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonLike addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
                [buttonHSare addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
                
            default:
                break;
        }
    }
    
    //TKUSERCELL TKCONTENTCELL  TKREICKTEXTCELL TKOPERATIONCELL
    
    /**
     *  row  0
     */
    if(indexPath.row == 0){ //通用
        cell = [tableView dequeueReusableCellWithIdentifier:@"TKUSERCELL" forIndexPath:indexPath];
        UIButton * _avatarButton = (UIButton *) [cell.contentView subviewWithTag:1];
//        _avatarButton.layer.cornerRadius = 35/2;
//        _avatarButton.layer.masksToBounds = YES;
        [_avatarButton addTarget:self action:@selector(seeUseinfoClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    // Configure the cell...
    cell.backgroundColor = [UIColor colorWithHex: 0xffefefef];
    return cell;
}

-(IBAction)seeUseinfoClick:(id)sender
{
    UIButton *buttonSender = (UIButton *)sender;
    UITableViewCell * cell = (UITableViewCell *)buttonSender.superview.superview.superview;
    XCJGroupPost_list * post = groupList[ [self.tableView indexPathForCell:cell].section];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
        
        XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
        addUser.UserInfo = response;
        [self.navigationController pushViewController:addUser animated:YES];
        
    } withuid:post.uid];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJGroupPost_list * post = groupList[indexPath.section];
    if (indexPath.row == 0) {
        UIButton * _avatarButton = (UIButton *) [cell.contentView subviewWithTag:1];
        UILabel * useName = (UILabel *) [cell.contentView subviewWithTag:2];
        UILabel * sendTime = (UILabel *) [cell.contentView subviewWithTag:3];
        sendTime.text = [tools timeLabelTextOfTime:post.time];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            if (response) {
                FCUserDescription * user = response;
                //内容
                if (user.headpic) {
                    [_avatarButton setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                }else{
                    [_avatarButton setImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
                }
                [useName setText:user.nick];
                [useName setTextColor:[tools colorWithIndex:[user.actor_level intValue]]];
                
            }
        } withuid:post.uid];
        
    }
    
    if (post.imageURL.length > 4 || post.excount > 0) {
        switch (indexPath.row) {
            case 1:
            {
                XCJContentTypesCell *contentCell = (XCJContentTypesCell *) cell;
                if (post.excount > 0) {
                    if (post.excountImages.count <= 0 && !contentCell.isloadingphotos) {
                        //check from networking
                        //查看是否有缓存
                        NSString * cacheKey = [NSString stringWithFormat:@"post.readex.%@",post.postid];
                        NSArray * cahceArray = [[EGOCache globalCache] plistForKey:cacheKey];
                        //            SLog(@"cahceArray :%@",cahceArray);
                        if (cahceArray && cahceArray.count > 0) {
                            NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                            [[cahceArray mutableCopy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                                [arrayURLS addObject:stringurl];
                            }];
                            post.excountImages = arrayURLS ;
                            contentCell.isloadingphotos = NO;
                        }else{
                            contentCell.isloadingphotos = YES;
                            //             [cell.imageListScroll showIndicatorViewBlue];
                            [[MLNetworkingManager sharedManager] sendWithAction:@"post.readex" parameters:@{@"postid":post.postid} success:^(MLRequest *request, id responseObject) {
                                if (responseObject) {
                                    NSDictionary  * result = responseObject[@"result"];
                                    NSArray * array = result[@"exdata"];
                                    if (array.count > 0) {
                                        [[EGOCache globalCache]  setPlist:[array mutableCopy] forKey:cacheKey];
                                    }
                                    NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                                        [arrayURLS addObject:stringurl];
                                    }];
                                    [post.excountImages removeAllObjects];
                                    [post.excountImages addObjectsFromArray:arrayURLS];
                                    //    [_tableView reloadData];
                                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                }
                                contentCell.isloadingphotos = NO;
                            } failure:^(MLRequest *request, NSError *error) {
                                contentCell.isloadingphotos = NO;
                            }];
                        }
                        
                    }
                }
                
                UIView * imageListScroll = [cell.contentView subviewWithTag:1];
                /*
                 *  多图模式
                 */
                if (post.excount > 0) {
                    [imageListScroll.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        ((UIView *)obj).hidden = YES;
                    }];
                    if (post.excountImages.count <= 0 ) {//&& !self.isloadingphotos
                        
                    }else{
                        //有数据
                        [post.excountImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString * stringurl = obj;
                            int row = idx/colNumber;
                            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(65*(idx%colNumber)+TITLE_jianxi*(idx%colNumber+1), (65+TITLE_jianxi) * row, 65, 65)];
                            iv.contentMode = UIViewContentModeScaleAspectFill;
                            iv.clipsToBounds = YES;
                            iv.tag = idx;
                            if([stringurl containString:@"assets-library://asset/"])
                            {
                                //系统图片
                                [iv setImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                                
                                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                                [library assetForURL:[NSURL URLWithString:stringurl]
                                         resultBlock:^(ALAsset *asset) {
                                             
                                             // Here, we have the asset, let's retrieve the image from it
                                             
                                             CGImageRef imgRef = asset.thumbnail;// [[asset defaultRepresentation] fullResolutionImage];
                                             
                                             /* Instead of the full res image, you can ask for an image that fits the screen
                                              CGImageRef imgRef  = [[asset defaultRepresentation] fullScreenImage];
                                              */
                                             // From the CGImage, let's build an UIImage
                                             UIImage *  imatgetemporal = [UIImage imageWithCGImage:imgRef];
                                             [iv setImage:imatgetemporal];
                                             
                                         } failureBlock:^(NSError *error) {
                                             
                                             // Something wrong happened.
                                             
                                         }];
                            }else {
                                [iv setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:100]] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
                            }
                            iv.userInteractionEnabled = YES;
                            UITapGestureRecognizer * tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewmulitClick:)];
                            [iv addGestureRecognizer:tapges];
                            //                [iv setFullScreenImageURL:[NSURL URLWithString:stringurl]];
                            // add self view
                            [imageListScroll addSubview:iv];
                        }];
                        //            [self.imageListScroll layoutIfNeeded];
                    }
                    float imageviewHeight = (post.excount/colNumber)*65 +(post.excount/colNumber)*TITLE_jianxi;
                    if (post.excount%colNumber>0) {
                        imageviewHeight += TITLE_jianxi+65;
                    }
                    imageListScroll.frame = CGRectMake(10, 5, 255.0, imageviewHeight);
                    imageListScroll.hidden = NO;
                }
            }
                break;
            case 3:
            {
                
            }
                break;
            default:
                break;
        }
        
    }else{
        switch (indexPath.row) {
          
            case 2:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}



-(void) SeeBigImageviewmulitClick:(id) sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    UITableViewCell * cell = (UITableViewCell *)buttonSender.superview.superview.superview.superview;
    XCJGroupPost_list * post = groupList[ [self.tableView indexPathForCell:cell].section];
    if (post.excount > 0) {
        NSArray * arrayPhotos  = [IDMPhoto photosWithURLs:post.excountImages];
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arrayPhotos animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        //        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:buttonSender.tag];
        if (buttonSender.image) {
            browser.scaleImage = buttonSender.image;        // Show
        }
        
        [self presentViewController:browser animated:YES completion:nil];
    }
}
/*
/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Method
/////////////////////////////////////////////////////////////////////////////

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    
    //    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    //        return YES;
    //        else
    //        // Unsupported link type (especially phone links are not supported on Simulator, only on device)
    //        return NO;
    CurrentUrl =  [NSString stringWithFormat:@"%@",linkInfo.extendedURL];
    if (linkInfo.extendedURL ) {
        NSString * url = CurrentUrl;
        NSString * toastText;
        if ([url isHttpUrl]) {
            toastText = @"浏览器打开";
        }else if([url isValidPhone])
        {
            toastText = @"电话打开";
        }else{
            toastText = url;
        }
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消 " destructiveButtonTitle:@"复制" otherButtonTitles:toastText, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }else{
        NSAttributedString * newStr = [attributedLabel.attributedText  attributedSubstringFromRange:linkInfo.range];
        CurrentUrl = newStr.string;
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制" otherButtonTitles:nil, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }
    
    return NO;
}
*/

#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3) {
        
        if (buttonIndex == 0) {
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:[NSString stringWithFormat:@"%@",CurrentUrl]];
        }else if(buttonIndex == 1)
        {
            NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
            if (![ title  isEqualToString:@"取消"]) {
                
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:CurrentUrl]])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CurrentUrl]];
                }else{
                    [UIAlertView showAlertViewWithMessage:@"打开失败"];
                }
            }
        }
    
    }else if (actionSheet.tag == 2) {
        // weichat share
        //1  朋友圈
        //0   好友
        
        XCJAppDelegate *delegate = (XCJAppDelegate *)[UIApplication sharedApplication].delegate;
        UIImage * image = [self.tableView  viewToImage:self.tableView];
        NSData * data = UIImageJPEGRepresentation(image, .5);
        switch (buttonIndex) {
            case 0:
            {
                [delegate sendImageContent:0 withImageData:data];
            }
                break;
            case 1:
            {
                [delegate sendImageContent:1 withImageData:data];
            }
                break;
            default:
                break;
        }
    }else if(actionSheet.tag == 1)
    {
        switch (buttonIndex) {
            case 0:
            {
                [self setuserTag:@"新都梦想好声音选手"];
            }
                break;
            case 1:
            {
                [self setuserTag:@"新都梦想好声音粉丝团"];                
            }
                break;
            default:
                break;
        }
    }
}


-(void) setuserTag:(NSString *) strtag
{
    [SVProgressHUD showWithStatus:@"正在处理中..."];
    
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.update_tag" parameters:@{@"tags":@[strtag]} success:^(MLRequest *request, id responseObject) {
        if (responseObject) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"设置成功"];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [SVProgressHUD dismiss];
        [UIAlertView showAlertViewWithMessage:@"设置失败,请重试"];
    }];
}
@end
