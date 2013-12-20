//
//  MessageCell.m
//  ISClone
//
//  Created by Molon on 13-12-6.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MessageCell.h"
#import "Extend.h"
#import "Message.h"

@interface MessageCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;

@property (weak, nonatomic) IBOutlet MLCanPopUpImageView *messageImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageImageViewHeightConstraint;
@end

@implementation MessageCell

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
        self.isDisplayOnlyContent = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(Message *)message
{
    if ([_message isEqual:message]) {
        return;
    }
    
    _message = message;
    if (!self.isDisplayOnlyContent) { //不需要就不处理
        [self.avatarImageView setImageWithURL:message.avatarURL];
        self.nameLabel.text = message.name;
        self.timeLabel.text = [self timeLabelTextOfTime:message.time];
    }else{
        self.avatarImageView.image = nil;
        self.nameLabel.text = nil;
        self.timeLabel.text = nil;
    }
    self.messageImageView.image = message.messageImage;
    if (!message.messageImage) {
        self.messageImageViewHeightConstraint.constant = .0f;
    }else{
        self.messageImageViewHeightConstraint.constant = 256.0f;
    }
    [self.contentView setNeedsUpdateConstraints];
    self.contentLabel.text = message.content;
}

- (void)setIsDisplayOnlyContent:(BOOL)isDisplayOnlyContent
{
    if (_isDisplayOnlyContent == isDisplayOnlyContent) {
        return;
    }
    
    _isDisplayOnlyContent = isDisplayOnlyContent;
    
    self.avatarImageView.hidden = isDisplayOnlyContent;
    self.nameLabel.hidden = isDisplayOnlyContent;
    self.timeLabel.hidden = isDisplayOnlyContent;
    
    if (isDisplayOnlyContent) {
        self.imageViewTopConstraint.constant = .0f;
    }else{
        self.imageViewTopConstraint.constant = 8.0f;
    }
    [self.contentView setNeedsUpdateConstraints];
    
    if (!isDisplayOnlyContent&&self.message) { //突然需要了就再次处理
        [self.avatarImageView setImageWithURL:self.message.avatarURL];
        self.nameLabel.text = self.message.name;
        self.timeLabel.text = [self timeLabelTextOfTime:self.message.time];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    //重置
    _message = nil;
    self.isDisplayOnlyContent = NO;
    self.avatarImageView.image = nil;
    self.nameLabel.text = nil;
    self.timeLabel.text = nil;
    self.contentLabel.text = nil;
    self.messageImageView.image = nil;
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
@end
