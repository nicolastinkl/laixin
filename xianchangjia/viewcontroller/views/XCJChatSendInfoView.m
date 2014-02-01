//
//  XCJChatSendInfoView.m
//  laixin
//
//  Created by apple on 14-1-25.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJChatSendInfoView.h"

@implementation XCJChatSendInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)takePhotoClick:(id)sender {
    [self.delegate takePhotoClick];
}
- (IBAction)choseFromGalleryClick:(id)sender {
    [self.delegate choseFromGalleryClick];
}
- (IBAction)choseLocationClick:(id)sender {
    [self.delegate choseLocationClick];
}
- (IBAction)sendMyfriendsClick:(id)sender {
        [self.delegate sendMyfriendsClick];
}
- (IBAction)moreClick:(id)sender {
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
