//
//  ActivityCommentsView.m
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ActivityCommentsView.h"
#import "Comment.h"
#import "User.h"
#import "Extend.h"
#import "MLTapGrayView.h"

@interface ActivityCommentsView()<TTTAttributedLabelDelegate,UIGestureRecognizerDelegate>
@end

@implementation ActivityCommentsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor colorWithString:@"{242}"];
        self.clipsToBounds = YES;
        self.frame = CGRectZero;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setComments:(NSArray *)comments
{
    _comments = comments;
    
    //删除原来的子View
    [self removeAllSubViews];
    
    CGFloat yOffset = 0;
    NSInteger index = 0;
    for (Comment *comment in _comments) {
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(8, 0, self.frameWidth-8*2, 0)];
        label.font = [UIFont systemFontOfSize:13];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        //超链接样式
        [label.linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [label.linkAttributes setValue:[UIColor colorWithString:@"{116,126,170}"] forKey:(NSString *)kCTForegroundColorAttributeName];
        [label.activeLinkAttributes setValue:[UIColor redColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        label.delegate = self;
        
        label.text = [NSString stringWithFormat:@"%@: %@",comment.user.name,comment.content];
        [label addLinkToCommand:[NSString stringWithFormat:@"%d",comment.user.uid] withRange: NSMakeRange (0, comment.user.name.length)];
        [label sizeToFit];
        label.frameHeight += 5*2;//多来点间距
        
        //此cell的作用是左右给label有8的间距，然后点按时候背景有灰色
        MLTapGrayView *cell = [[MLTapGrayView alloc]initWithFrame:CGRectMake(0, yOffset, self.frameWidth, label.frameHeight)];
        cell.tag = index++;
        [cell addSubview:label];
        [self addSubview:cell];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [cell addGestureRecognizer:tapGesture];
        tapGesture.delegate = self;
        [tapGesture addTarget:self action:@selector(commentTap:)];
        
        yOffset += cell.frameHeight;
    }
    self.frameHeight = yOffset;
}

#pragma mark - Label delegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithCMD:(NSString *)cmd
{
    if (_delegate&&[_delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithCMD:)]) {
        [_delegate attributedLabel:label didSelectLinkWithCMD:cmd];
    }
}

- (void)commentTap:(UITapGestureRecognizer *)gesture
{
    //根据gesture.view 找到其对应的index
    if (_delegate&&[_delegate respondsToSelector:@selector(clickCommentsView:atIndex:atBottomY:)]) {
        [_delegate clickCommentsView:self atIndex:gesture.view.tag atBottomY:gesture.view.frameBottom];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]){
        TTTAttributedLabel *label = (TTTAttributedLabel *)touch.view;
        if ([label linkAtPoint:[touch locationInView:label]]) { //有值说明点击了链接
            return NO;
        }
    }
    return YES;
}

@end
