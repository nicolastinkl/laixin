//
//  ChatUserCell.m
//  ISClone
//
//  Created by Molon on 13-12-2.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ChatUserCell.h"
#import "Chat.h"
#import "Extend.h"

@interface ChatUserCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestMessageLabel;

@end

@implementation ChatUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChat:(Chat *)chat
{
    _chat = chat;
    [self.avatarImageView setImageWithURL:chat.avatarURL];
    self.nameLabel.text = chat.name;
    self.latestTimeLabel.text = [self timeLabelTextOfTime:chat.latestTime];
    self.latestMessageLabel.text = chat.latestMessage;
    if (chat.unreadCount>0) {
        NSString *count= [NSString stringWithFormat:@"%ld",(long)chat.unreadCount];
        if (chat.unreadCount>100) {
            count = @"99+";
        }
        [self showBadgeValue:count inView:self.avatarImageView];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    //重置
    _chat = nil;
    self.avatarImageView.image = nil;
    self.nameLabel.text = nil;
    self.latestTimeLabel.text = nil;
    self.latestMessageLabel.text = nil;
    [self removeBadgeValueInView:self.avatarImageView];
}

- (NSString*)timeLabelTextOfTime:(NSTimeInterval)time
{
    if (time<=0) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *text = [dateFormatter stringFromDate:date];
    
    //最近时间处理
    NSInteger timeAgo = [[NSDate date] timeIntervalSince1970] - time;
    if (timeAgo > 0 && timeAgo < 60) {
        text = [NSString stringWithFormat:@"%ld秒前", (long)timeAgo];
    }else if (timeAgo >= 60 && timeAgo < 3600) {
        NSInteger timeAgoMinute = timeAgo / 60;
        text = [NSString stringWithFormat:@"%ld分钟前", (long)timeAgoMinute];
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

- (UIView *)showBadgeValue:(NSString *)strBadgeValue inView:(UIView*)view
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    tabBar.items = @[item];
    //寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //从原视图上移除
                [subview removeFromSuperview];
                //添加到新视图右上角
                [view addSubview:subview];
                subview.frame = CGRectMake(view.frame.size.width-subview.frame.size.width/2, -4,
                                           subview.frame.size.width, subview.frame.size.height);
                return subview;
            }
        }
    }
    return nil;
}

- (void)removeBadgeValueInView:(UIView*)view
{
    for (UIView *subview in view.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
            [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            break;
        }
    }
}
@end
