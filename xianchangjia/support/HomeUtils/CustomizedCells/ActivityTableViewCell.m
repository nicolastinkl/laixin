//
//  ActivityTableViewCell.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import "ActivityCommentsView.h"
#import "XCJGroupPost_list.h"
#import "LXUser.h"
#import "Extend.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+Addtion.h"
#import "UIAlertViewAddition.h"
#import "UIButton+WebCache.h"
#import "LXAPIController.h"
#import "LXRequestFacebookManager.h"
#import "Comment.h"
#import "tools.h"
#import "FCUserDescription.h"
#import "XCAlbumDefines.h"
#import "UIView+Additon.h"


@interface ActivityTableViewCell()<TTTAttributedLabelDelegate,ActivityCommentsViewDelegate>

//用户头像View
@property (nonatomic, strong) UIButton *avatarButton;
//用户名字的Label
@property (nonatomic, strong) UIButton *userNameButton;
//发布时间Label
@property (nonatomic, strong) UILabel *timeLabel;
//内容Label
@property (nonatomic, strong) UILabel *contentLabel;
//图片View
@property (nonatomic, strong) MLCanPopUpImageView *activityImageView;
//评论按钮
@property (nonatomic, strong) UIButton *commentButton;
//赞按钮
@property (nonatomic, strong) UIButton *likeButton;
//举报按钮
@property (nonatomic, strong) UIButton *ReportButton;


//赞和评论的背景View，主要就是为了带箭头
@property (nonatomic, strong) UIImageView *likeCommentBackView;
//赞的背景View
@property (nonatomic, strong) UIView *likeBackView;
//赞的用户Label
@property (nonatomic, strong) TTTAttributedLabel *likeLabel;
//评论View
@property (nonatomic, strong) ActivityCommentsView *commentsView;

//分割线
@property (nonatomic, strong) UILabel *lineCell;

@property (nonatomic, strong) UIView *imageBackgroundView_FullScreen;
@property (nonatomic, strong) UIView *imageMaskView_FullScreen;
@property (nonatomic, strong) UIImageView *imageView_FullScreen;

@end

@implementation ActivityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code 初始化需要的View
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIColor *commonColor = [UIColor colorWithString:@"{116,126,170}"];
        //头像
        self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.layer.borderColor = [UIColor grayColor].CGColor;
        _avatarButton.layer.borderWidth = 0.5f;
        _avatarButton.clipsToBounds = YES;
        [_avatarButton addTarget:self action:@selector(avatarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarButton];
        
        //用户名
        self.userNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _userNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _userNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _userNameButton.backgroundColor = [UIColor clearColor];
        [_userNameButton setTitleColor:commonColor forState:UIControlStateNormal];
        [_userNameButton addTarget:self action:@selector(avatarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_userNameButton];
        
        //时间
        self.timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        [self addSubview:_timeLabel];
        
        //时间
        self.lineCell = [[UILabel alloc] init];
        _lineCell.backgroundColor = [UIColor lightGrayColor];
        _lineCell.alpha = 0.6f;
        [self addSubview:_lineCell];
        
        
        //正文
        self.contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contentLabel];
        
        //图片
        self.activityImageView = [[MLCanPopUpImageView alloc] init];
        [self addSubview:_activityImageView];
        
        //评论按钮
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setImage:[UIImage imageNamed:@"btn_comment.png"] forState:UIControlStateNormal];
        [_commentButton setContentMode:UIViewContentModeCenter];
        [_commentButton setTitleColor:commonColor forState:UIControlStateNormal];
        [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0f, 0.0, 0.0)];
        [_commentButton addTarget:self
                               action:@selector(likeOrCommentButtonClick:)
                     forControlEvents:UIControlEventTouchUpInside];
        [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:11.5];
        _commentButton.tag = 802;
        [self addSubview:_commentButton];
        
        // 举报按钮
        
        self.ReportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ReportButton setContentMode:UIViewContentModeCenter];
        [_ReportButton setTitleColor:commonColor forState:UIControlStateNormal];
        [_ReportButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0f, 0.0, 0.0)];
        [_ReportButton addTarget:self
                           action:@selector(ReportButtonClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        [_ReportButton setTitle:@"举报" forState:UIControlStateNormal];
        _ReportButton.titleLabel.font = [UIFont systemFontOfSize:11.5];
        _ReportButton.tag = 805;
//        [self addSubview:_ReportButton];
        
        //赞按钮
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"btn_unlike.png"] forState:UIControlStateNormal];
        [_likeButton setContentMode:UIViewContentModeCenter];
        [_likeButton setTitleColor:commonColor forState:UIControlStateNormal];
        [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0f, 0.0, 0.0)];
        [_likeButton addTarget:self
                           action:@selector(likeOrCommentButtonClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:11.5];
        _likeButton.tag = 801;
        [self addSubview:_likeButton];
        
        self.likeCommentBackView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"like_comment_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:23]];
        [self addSubview:_likeCommentBackView];
        
        //赞外包装
        self.likeBackView = [[UIView alloc]init];
//        _likeBackView.backgroundColor = [UIColor colorWithString:@"{242}"];
        [self addSubview:self.likeBackView];
        //赞label
        self.likeLabel = [[TTTAttributedLabel alloc] init];
        _likeLabel.backgroundColor = [UIColor clearColor];
        _likeLabel.font = [UIFont systemFontOfSize:12.5];
        _likeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _likeLabel.numberOfLines = 0;
        _likeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
        //超链接样式
        [_likeLabel.linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [_likeLabel.linkAttributes setValue:commonColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [_likeLabel.activeLinkAttributes setValue:[UIColor redColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        _likeLabel.delegate = self;
        [_likeBackView addSubview:_likeLabel];
        
        //赞label里的赞图标
        UIImageView *likeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 15, 15)];
        likeIcon.image = [UIImage imageNamed:@"btn_like.png"];
        [_likeBackView addSubview:likeIcon];
        
        //评论View
        self.commentsView = [[ActivityCommentsView alloc] init];
        [self addSubview:_commentsView];
        
        _cellHeight = 0;
    }
    return self;
}

-(IBAction)ReportButtonClick:(id)sender
{
    [UIAlertView showAlertViewWithMessage:@"举报成功"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - set Activity
- (void)setActivity:(XCJGroupPost_list *)activity
{
    //在这里根据activity的内容去设置各个subView的frame和细节
    _activity = activity;
    if([activity.uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
    {
         [_avatarButton setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_fault"]];
        [_userNameButton setTitle:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick] forState:UIControlStateNormal];
    }else{
        
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
            FCUserDescription * user = response;
            //内容
            if (user.headpic) {
                [_avatarButton setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:user.headpic Size:100]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_fault"]];
            }else{
                [_avatarButton setImage:[UIImage imageNamed:@"avatar_fault"] forState:UIControlStateNormal];
            }
            [_userNameButton setTitle:user.nick forState:UIControlStateNormal];
        } withuid:activity.uid];
    }
    
    
    _timeLabel.text = [self timeLabelTextOfTime:_activity.time];
    _contentLabel.text = _activity.content;
    
    //重置下
    _activityImageView.image = nil;
    _activityImageView.fullScreenImageURL = nil;
    _activityImageView.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
    if (_activity.imageURL) {
//        NSRange range = [_activity.imageURL rangeOfString:@"/" options:NSBackwardsSearch];
//        NSString *thumbImageURL = [_activity.imageURL stringByReplacingCharactersInRange:range withString:@"/320/"];
        
        [_activityImageView setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:_activity.imageURL Size:160]] placeholderImage:nil displayProgress:YES];
        _activityImageView.fullScreenImageURL = [NSURL URLWithString:[tools getUrlByImageUrl:_activity.imageURL Size:640]];
    }
    
    if (_activity.ilike) {
        [_likeButton setImage:[UIImage imageNamed:@"btn_like.png"] forState:UIControlStateNormal];
        [_likeButton setTitle:@"已赞" forState:UIControlStateNormal];
    }else{
        [_likeButton setImage:[UIImage imageNamed:@"btn_unlike.png"] forState:UIControlStateNormal];
        [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
    }
    //根据latestLikeUser和likeCount来设置text
    if (_activity.like>0) {
        NSString *text = @"     ";
        __block NSString * nicktext;
        NSMutableArray *textCheckingResults = [[NSMutableArray alloc]init];
        for (postlikes *aUser in _activity.likeUsers) {
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError * error) {
                FCUserDescription * user = response;
                [textCheckingResults addObject:[NSTextCheckingResult replacementCheckingResultWithRange:NSMakeRange(text.length, user.nick.length) replacementString:user.uid]];
                 nicktext = user.nick;
            } withuid:aUser.uid];
           text = [text stringByAppendingFormat:@"%@, ",nicktext];
        }
        
        if (text.length>0) {
            text = [text substringToIndex:text.length-2];//去掉最后的，号
            text = [text stringByAppendingString:@" "];
        }
        NSInteger otherUserCount = _activity.like - _activity.likeUsers.count;
        if (otherUserCount) {
            if (_activity.likeUsers.count>0) {
                text = [text stringByAppendingFormat:@"等%d人",otherUserCount];
            }else{
                text = [text stringByAppendingFormat:@"%d人",otherUserCount];
            }
        }
        text = [text stringByAppendingFormat:@"觉得很赞"];
        _likeLabel.text = text;
        [_likeLabel addLinksWithTextCheckingResults:textCheckingResults attributes:_likeLabel.linkAttributes];
    }else{
        _likeLabel.text = @"";
    }
    
    //frame
    CGFloat xOffset = 10;
    CGFloat yOffset = 10;
    
    _lineCell.frame = CGRectMake(0, 1, 320, 0.5f);
    
    _avatarButton.frame = CGRectMake(xOffset, yOffset, 46, 46);
    _avatarButton.layer.cornerRadius = 23.0;
    
    xOffset += _avatarButton.frameWidth+10;

    _timeLabel.frame = CGRectZero;
    [_timeLabel sizeToFit]; //自适应时间长度
    _timeLabel.frame = CGRectMake(self.frameWidth-_timeLabel.frameWidth-10, yOffset, _timeLabel.frameWidth, _timeLabel.frameHeight);
    
    //用户名是时间宽度刨去，再刨去5像素为最终宽度，如果太长就自动省略号了
    CGFloat width = [_userNameButton.titleLabel.text realWidthForWidth:_timeLabel.frame.origin.x-xOffset-5 font:_userNameButton.titleLabel.font];
    _userNameButton.frame = CGRectMake(xOffset, yOffset, width, 20);
    
    yOffset += _userNameButton.frameHeight+5;
    
    _contentLabel.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, 1);
     [_contentLabel sizeToFit];//自适应高度
    yOffset += _contentLabel.frameHeight+10;
    
    if (_activity.imageURL && _activity.imageURL.length > 5) {
        _activityImageView.hidden = NO;
        _activityImageView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-100, self.frameWidth-xOffset-100);
        yOffset += _activityImageView.frameHeight+10;
    }else{
        _activityImageView.hidden = YES;
    }
    
    _likeButton.frame = CGRectMake(self.frameWidth-120, yOffset, 50, 20);
    _commentButton.frame = CGRectMake(_likeButton.frame.origin.x+_likeButton.frameWidth+10, yOffset, 50, _likeButton.frameHeight);
    _ReportButton.frame =   CGRectMake(50, yOffset, 50, _likeButton.frameHeight);
    yOffset += _likeButton.frameHeight+10;
    

    
    CGFloat likeCommentBackY = yOffset-6.2;
    
    if (_activity.like>0) {
        _likeLabel.frame = CGRectMake(8, 5, self.frameWidth-xOffset-10-8*2, 0);
        [_likeLabel sizeToFit];
        
        _likeBackView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, _likeLabel.frameHeight+5*2);
        
        _likeBackView.hidden = NO;
        yOffset += _likeBackView.frameHeight;
    }else{
        _likeBackView.hidden = YES;
    }
    
    if (_activity.comments.count>0) {
        _commentsView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, 0);
        _commentsView.comments = _activity.comments; //会根据内容和自身宽度自动调整高度
        _commentsView.delegate = self;
        _commentsView.hidden = NO;
        yOffset += _commentsView.frameHeight;
    }else{
        _commentsView.comments = nil;
        _commentsView.hidden = YES;
    }
    
    _likeCommentBackView.frame = CGRectMake(xOffset, likeCommentBackY, self.frameWidth-xOffset-10, yOffset-likeCommentBackY);
    
    if (_activity.like>0||_activity.comments.count>0) {
        yOffset += 10;
        _likeCommentBackView.hidden = NO;
    }else{
        _likeCommentBackView.hidden = YES;
    }
    
    _cellHeight = yOffset;
}


-(int) heigthforCell:(XCJGroupPost_list *) _activity_new
{
    //frame
    CGFloat xOffset = 10;
    CGFloat yOffset = 10;
    
    _avatarButton.frame = CGRectMake(xOffset, yOffset, 46, 46);
    _avatarButton.layer.cornerRadius = 23.0;
    
    xOffset += _avatarButton.frameWidth+10;
    
    _timeLabel.frame = CGRectZero;
    [_timeLabel sizeToFit]; //自适应时间长度
    _timeLabel.frame = CGRectMake(self.frameWidth-_timeLabel.frameWidth-10, yOffset, _timeLabel.frameWidth, _timeLabel.frameHeight);
    
    //用户名是时间宽度刨去，再刨去5像素为最终宽度，如果太长就自动省略号了
    CGFloat width = [_userNameButton.titleLabel.text realWidthForWidth:_timeLabel.frame.origin.x-xOffset-5 font:_userNameButton.titleLabel.font];
    _userNameButton.frame = CGRectMake(xOffset, yOffset, width, 20);
    
    yOffset += _userNameButton.frameHeight+5;
    
    _contentLabel.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, 1);
    [_contentLabel sizeToFit];//自适应高度
    yOffset += _contentLabel.frameHeight+10;
    
    if (_activity_new.imageURL) {
        _activityImageView.hidden = NO;
        _activityImageView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, self.frameWidth-xOffset-10);
        yOffset += _activityImageView.frameHeight+10;
    }else{
        _activityImageView.hidden = YES;
    }
    
    _likeButton.frame = CGRectMake(self.frameWidth-120, yOffset, 50, 20);
    _commentButton.frame = CGRectMake(_likeButton.frame.origin.x+_likeButton.frameWidth+10, yOffset, 50, _likeButton.frameHeight);
    _ReportButton.frame =   CGRectMake(50, yOffset, 50, _likeButton.frameHeight);
    yOffset += _likeButton.frameHeight+10;
    
    
    
    CGFloat likeCommentBackY = yOffset-6.2;
    
    if (_activity_new.like>0) {
        _likeLabel.frame = CGRectMake(8, 5, self.frameWidth-xOffset-10-8*2, 0);
        [_likeLabel sizeToFit];
        
        _likeBackView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, _likeLabel.frameHeight+5*2);
        
        _likeBackView.hidden = NO;
        yOffset += _likeBackView.frameHeight;
    }else{
        _likeBackView.hidden = YES;
    }
    
    if (_activity_new.comments.count>0) {
        _commentsView.frame = CGRectMake(xOffset, yOffset, self.frameWidth-xOffset-10, 0);
        _commentsView.comments = _activity_new.comments; //会根据内容和自身宽度自动调整高度
        _commentsView.delegate = self;
        _commentsView.hidden = NO;
        
        yOffset += _commentsView.frameHeight;
    }else{
        _commentsView.comments = nil;
        _commentsView.hidden = YES;
    }
    
    _likeCommentBackView.frame = CGRectMake(xOffset, likeCommentBackY, self.frameWidth-xOffset-10, yOffset-likeCommentBackY);
    
    if (_activity_new.like>0||_activity_new.comments.count>0) {
        yOffset += 10;
        _likeCommentBackView.hidden = NO;
    }else{
        _likeCommentBackView.hidden = YES;
    }
    
    _cellHeight = yOffset;
    
    return _cellHeight;
}


#pragma mark - button event
- (void)likeOrCommentButtonClick:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button.tag == 801) {
        //like
        if (_delegate&& [_delegate respondsToSelector:@selector(clickLikeButton:onActivity:)]) {
            [_delegate clickLikeButton:button onActivity:_activity];
        }
    }else if (button.tag == 802) {
        //comment
        if (_delegate&& [_delegate respondsToSelector:@selector(clickCommentButton:onActivity:)]) {
            [_delegate clickCommentButton:button onActivity:_activity];
        }
    }
}

- (void)avatarButtonClick:(id)sender
{
    if (_delegate&&[_delegate respondsToSelector:@selector(clickAvatarButton:onActivity:)]) {
        [_delegate clickAvatarButton:sender onActivity:_activity];
    }
}

#pragma mark - TTTLabel and ActivityCommentsViewDelegate's TTTLabel delegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithCMD:(NSString *)cmd
{
    if (_delegate&&[_delegate respondsToSelector:@selector(clickUserID:onActivity:)]) {
        [_delegate clickUserID:cmd onActivity:_activity];
    }
}

#pragma mark - ActivityCommentsViewDelegate delegate
- (void)clickCommentsView:(UIView *)commentsView atIndex:(NSInteger)index atBottomY:(CGFloat)bottomY
{
    if (_delegate&&[_delegate respondsToSelector:@selector(clickCommentsView:atIndex:atBottomY:onActivity:)]) {
        [_delegate clickCommentsView:commentsView atIndex:index atBottomY:bottomY onActivity:_activity];
    }
}

#pragma mark - other Common
- (NSString*)timeLabelTextOfTime:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_activity.time];
    NSString *text = [dateFormatter stringFromDate:date];
    
    //最近时间处理
    NSInteger timeAgo = [[NSDate date] timeIntervalSince1970] - _activity.time;
    if (timeAgo > 0 && timeAgo < 60) {
        text = [NSString stringWithFormat:@"%d秒前", timeAgo];
    }else if (timeAgo >= 60 && timeAgo < 3600) {
        NSInteger timeAgoMinute = timeAgo / 60;
        text = [NSString stringWithFormat:@"%d分钟前", timeAgoMinute];
    }else if (timeAgo >= 3600 && timeAgo < 86400) {
        [dateFormatter setDateFormat:@"今天HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }else if (timeAgo >= 86400 && timeAgo < 86400*2) {
        [dateFormatter setDateFormat:@"昨天HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }else if (timeAgo >= 86400*2 && timeAgo < 86400*3) {
        [dateFormatter setDateFormat:@"前天HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }
    return text;
}

@end
