//
//  XCJDreamPopUserView.m
//  laixin
//
//  Created by apple on 4/11/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJDreamPopUserView.h"

@implementation XCJDreamPopUserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (IBAction)likeClick:(id)sender {
    [self.delegate sendLike];
}
- (IBAction)closeview:(id)sender {
    [self.delegate closeView];
}

- (IBAction)targetuserinfoClick:(id)sender
{
    [self.delegate targetUserinfo];
}
@end
