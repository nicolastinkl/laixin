//
//  XCJHomeMenuView.m
//  laixin
//
//  Created by apple on 14-1-3.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJHomeMenuView.h"
#import "XCAlbumAdditions.h"

@implementation XCJHomeMenuView
@synthesize delegate = _delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void) setButtonLayout
{
    
    if(IS_4_INCH)
    {
        [self.button_Close setTop:519];
    }else{
        [self.button_Close setTop:409];
    }
}

- (IBAction)MoreClick:(id)sender {
     [self.delegate hiddenSelfViewClick];
}
- (IBAction)HideThisViewClick:(id)sender {
     [self.delegate hiddenSelfViewClick];
}

- (IBAction)HideSelfViewClick:(id)sender {
    [self.delegate hiddenSelfViewClick];
}

- (IBAction)createGroupClick:(id)sender {
    [self.delegate createGroupClick];
}

- (IBAction)addfriendClick:(id)sender {
    [self.delegate addFriendClick];
}

- (IBAction)saoyisaoClick:(id)sender {
    [self.delegate findandfindCodeClick];
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
