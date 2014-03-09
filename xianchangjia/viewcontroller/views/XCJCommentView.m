//
//  XCJCommentView.m
//  laixin
//
//  Created by apple on 3/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJCommentView.h"

@implementation XCJCommentView 
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
- (IBAction)closeViewClick:(id)sender {
    [self.delegate closeView];
}

- (IBAction)button_send:(id)sender {
    [self.delegate sendContentWith:self.textview.text];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.textview.text isEqualToString: @"输入评价内容"]) {
        self.textview.text = @"";
        self.label_count.text = @"200";
        self.textview.textColor = [UIColor blackColor];
        return YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString * string =  textView.text;
    int index =  200 - string.length;
    if (index > 0) {
        self.label_count.text = [NSString stringWithFormat:@"%d",index];
        self.label_count.textColor = [UIColor lightGrayColor];
        self.buttonsend.enabled = YES;
    }else{
        self.label_count.text = [NSString stringWithFormat:@"%d",index];
        self.label_count.textColor = [UIColor redColor];
        self.buttonsend.enabled = NO;
    }
}
@end
