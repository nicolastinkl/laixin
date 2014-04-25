//
//  XCJGroupMenuView.m
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJGroupMenuView.h"

@implementation XCJGroupMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)hideSelfViewClick:(id)sender {
    [self.delegate hiddenSelfViewClick];
}

- (IBAction)addfriendClick:(id)sender {
    [self.delegate addFriendClick];
}

- (IBAction)SeeGroupUsersClick:(id)sender {
    [self.delegate findandfindCodeClick];
}

- (IBAction) MuteMusicClick:(id)sender {
    [self.delegate MuteMusicClick];
}

- (IBAction)moreChoiceClick:(id)sender {
    [self.delegate moreClick];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
