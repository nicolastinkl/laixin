//
//  ActivityTableViewCell.h
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Activity;

@protocol ActivityTableViewCellDelegate <NSObject>

//点击某用户
- (void)clickUserID:(NSInteger)uid onActivity:(Activity *)activity;
//点击当前activity的发布者头像
- (void)clickAvatarButton:(UIButton *)avatarButton onActivity:(Activity *)activity;
//点击评论按钮
- (void)clickCommentButton:(UIButton *)commentButton onActivity:(Activity *)activity;
//点击赞按钮
- (void)clickLikeButton:(UIButton *)likeButton onActivity:(Activity *)activity;
//点击评论View中的某行(当前如果点击的是其中的某用户是会忽略的)
- (void)clickCommentsView:(UIView *)commentsView atIndex:(NSInteger)index atBottomY:(CGFloat)bottomY onActivity:(Activity *)activity;

@end


@interface ActivityTableViewCell : UITableViewCell

//cell高度
@property (nonatomic, assign,readonly) CGFloat cellHeight;
//当前cell对应的activity
@property (nonatomic, strong) Activity *activity;
//delegate
@property (nonatomic, weak) id<ActivityTableViewCellDelegate> delegate;

@end
