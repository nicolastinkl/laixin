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
#import "UIImageView+Addtion.h"
#import "UIViewController+Indicator.h"
#import "ChatViewController.h"
#import "Conversation.h"
#import "CoreData+MagicalRecord.h"
#import "XCJAddUserTableViewController.h"
#import "FCMessage.h"

#define BUTTONCOLL  0
#define DISTANCE_BETWEEN_ITEMS  0.0
#define LEFT_PADDING            0.0
#define ITEM_WIDTH              320.0
#define TITLE_HEIGHT            320.0

@interface XCJNearbyInfoViewContr ()<UIScrollViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray * photoArray;
    XCJGroupPost_list *  postinfo;
}
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
@property (weak, nonatomic) IBOutlet UIButton *button_like;

@end

@implementation XCJNearbyInfoViewContr

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)likeorunlikeClick:(id)sender {
    if (postinfo) {
        [self.button_like showAnimatingLayer];
        
        if (!postinfo.ilike) {
            NSDictionary * parames = @{@"postid":postinfo.postid};
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.like"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //            [activity.likeUsers addObject:[[LXAPIController sharedLXAPIController] currentUser]];
                postinfo.ilike = YES;
                postinfo.like ++;
                self.button_like.enabled = YES;
                self.label_likeCount.text = [NSString stringWithFormat:@"%d",postinfo.like];
                [self.button_like setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
            } failure:^(MLRequest *request, NSError *error) {
                self.button_like.enabled = YES;
                [UIAlertView showAlertViewWithMessage:@"喜欢失败 请重试!"];
            }];
        }else{
            NSDictionary * parames = @{@"postid":postinfo.postid};
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.dislike"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //如果有则删除，没有则不动啊
                postinfo.like -- ;
                postinfo.ilike = NO;
                self.button_like.enabled = YES;
                self.label_likeCount.text = [NSString stringWithFormat:@"%d",postinfo.like];
                       [self.button_like setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
            } failure:^(MLRequest *request, NSError *error) {
                self.button_like.enabled = YES;
                [UIAlertView showAlertViewWithMessage:@"取消喜欢失败 请重试!"];
            }];
        }
    }
    
}

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 10;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    return cell;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollview) {
        self.pagecontrl.currentPage = self.scrollview.contentOffset.x/320.0f;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    [self initallContr:self.groupinfo];
    
    self.scrollview.delegate = self;
    
    self.scrollview.pagingEnabled = YES;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"参加" style:UIBarButtonItemStyleBordered target:self action:@selector(jsonInviteClick:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            // ok
            if ([self.groupinfo.creator isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]) {
                [UIAlertView showAlertViewWithMessage:@"不能参加自己的活动"];
                return;
            }
            
            [SVProgressHUD showSuccessWithStatus:@"正在处理..."];
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                FCUserDescription * user = response;
                if (user) {
                    [SVProgressHUD dismiss];
                    
                    NSString * name = [NSString stringWithFormat:@"我想参加您发起的活动(%@),有什么变化麻烦告诉我噢.",self.groupinfo.group_name];
                    NSDictionary * parames = @{@"uid":user.uid,@"content":name};
                    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send" parameters:parames success:^(MLRequest *request, id responseObject) {
                        if (responseObject) {
                            
                            // target to chat view
                            NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
                            NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",self.groupinfo.creator];
                            Conversation * array =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
                            ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                            if (array) {
                                chatview.conversation = array;
                                
                                {
                                    //系统消息公告
                                    FCMessage * msg = [FCMessage MR_createInContext:localContext];
                                    msg.messageType = @(messageType_SystemAD);
                                    msg.text =name;
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
                                conversation.facebookName = user.nick;
                                conversation.facebookId = user.uid;
                                conversation.badgeNumber = @0;
                                {
                                    //系统消息公告
                                    FCMessage * msg = [FCMessage MR_createInContext:localContext];
                                    msg.messageType = @(messageType_SystemAD);
                                    msg.text = [NSString stringWithFormat:@"我想参加您发起的活动(%@),有什么变化麻烦告诉我噢.",self.groupinfo.group_name],
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
                        }
                    } failure:^(MLRequest *request, NSError *error) {
                        [SVProgressHUD dismiss];
                        [UIAlertView showAlertViewWithMessage:@"参加活动失败,请检查网络设置"];
                    }];
                    
                }else{
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"用户不存在!"];
                }
            } withuid:self.groupinfo.creator];
            
            
        }
    }
}

-(IBAction)jsonInviteClick:(id)sender
{
    //私信ta
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确定参加此活动吗?\n 注意活动时间和地点,\n确认后系统将会以您的身份给发起者发送通知." delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"参加" otherButtonTitles:nil, nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 59.0f;
    }
    if (indexPath.section == 1 ) {
        return 44.0f;
    }
    if (indexPath.section == 2 ) {
        return 53.0f;
    }
    if (indexPath.section == 3) {
        
        if (postinfo) {
            CGFloat height =  [self heightForCellWithPost: postinfo.content];
            return height+20;
        }
        return 44.0f;
    }
    
    return 44.0f;
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            //评论
        }
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // user info
            [SVProgressHUD show];
            //查看好友资料
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                FCUserDescription * user = response;
                if (user) {
                    [SVProgressHUD dismiss];
                    XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
                    addUser.UserInfo = user;
                    [self.navigationController pushViewController:addUser animated:YES];
                }else{
                    [SVProgressHUD dismiss];
                    [UIAlertView showAlertViewWithMessage:@"用户不存在!"];
                }
            } withuid:self.groupinfo.creator];
            
        }
    }
}

-(void) initallContr:( XCJGroup_list * ) groupinfo
{
//    self.groupinfo = groupinfo;
    self.label_name.text = groupinfo.group_name;
    self.label_address.text = groupinfo.position;
    self.label_time.text = @"明天";
    self.label_type.text = groupinfo.group_board;
    self.label_type.textColor = [tools colorWithIndex:3];
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
    } withuid:groupinfo.creator];
    
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSDictionary * parames = @{@"gid":groupinfo.gid,@"pos":@0,@"count":@"1"};
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"group.post_list"  parameters:parames success:^(MLRequest *request, id responseObject) {
            //    postid = 12;
            /*
             Result={
             “posts”:[*/
            if (responseObject) {
                NSDictionary * groups = responseObject[@"result"];
                NSArray * postsDict =  groups[@"posts"];
                [postsDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (idx == 0) {
                        
                        XCJGroupPost_list * post = [XCJGroupPost_list turnObject:obj];
                        postinfo = post;
                        self.label_likeCount.text = [NSString stringWithFormat:@"%d",post.like];
                        
                        if(post.ilike)
                        {
                             [self.button_like setImage:[UIImage imageNamed:@"pictureHeartLike_1"] forState:UIControlStateNormal];
                        }else{
                             [self.button_like setImage:[UIImage imageNamed:@"pictureHeartLike_0"] forState:UIControlStateNormal];
                        }
                            
                        self.label_comment.text = [NSString stringWithFormat:@"评论(%d)",post.replycount];
                        self.label_info.text = post.content;
                        [self.tableview reloadData];
                        CGFloat height =  [self heightForCellWithPost: post.content];
                        [self.label_info setHeight:height];
                        
                        if (post.postid) {
                            // get photo list
                           UIView *view =  [self.tableView.tableHeaderView subviewWithTag:1];
                            [view showIndicatorViewLargeBlue];
                            
                            
                            [[MLNetworkingManager sharedManager] sendWithAction:@"post.readex" parameters:@{@"postid":post.postid} success:^(MLRequest *request, id responseObject) {
                                if (responseObject) {
                                    NSDictionary  * result = responseObject[@"result"];
                                    CGSize pageSize = CGSizeMake(ITEM_WIDTH, self.scrollview.frame.size.height);
                                    NSArray * array = result[@"exdata"];
                                    NSMutableArray * arrayURLS  = [[NSMutableArray alloc] init];
                                    __block NSUInteger page = 0;
                                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                        NSString * stringurl = [DataHelper getStringValue:obj[@"picture"] defaultValue:@"" ];
                                        [arrayURLS addObject:stringurl];
                                        
                                        UIImageView * imageview = [[UIImageView alloc] init];
                                        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:stringurl Size:320]] placeholderImage:[UIImage imageNamed:@"photo_loading"] displayProgress:YES];
                                        [imageview setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, LEFT_PADDING, ITEM_WIDTH, ITEM_WIDTH)];
                                        imageview.userInteractionEnabled = YES;
                                        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
//                                        [recognizer setNumberOfTapsRequired:1];
                                        [recognizer setNumberOfTouchesRequired:1];
                                        [imageview addGestureRecognizer:recognizer];
                                        imageview.tag = idx;
                                        [self.scrollview addSubview:imageview];
                                        
                                    }];
                                    photoArray = arrayURLS;
                                    self.pagecontrl.numberOfPages = photoArray.count;
                                    self.pagecontrl.currentPageIndicatorTintColor = ios7BlueColor;
                                    
                                    self.scrollview.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * ([photoArray count] ), pageSize.height);
                                }
                                [view hideIndicatorViewBlueOrGary];
                            } failure:^(MLRequest *request, NSError *error) {
                                [view hideIndicatorViewBlueOrGary];
                                [self showErrorText:@"图片加载错误"];
                            }];
                        }
                    }
                }];
            }else{
                [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [UIAlertView showAlertViewWithMessage:@"获取数据出错"];
        }];
        
    });
    
    
}


-(void) tagSelected:(UITapGestureRecognizer * ) tap
{
//    UIView * view = tap.view;
//    UIImageView * viewImg = (UIImageView *) view;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
