//
//  UIImageView+Exetension.m
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-20.
//
//

#import "UIImageView+Exetension.h"
#import "XCAlbumDefines.h"

#define  TagLargeImage  2
#define TagCloseButton	3
#define KeyCloseSize	184/2
@implementation UIImageView (UIImageView_Exetension)

+ (void) presentModalImage:(NSString *)url  {
    
    [UIView beginAnimations:@"ImageAnimation" context:NULL];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDuration:0.15];
    CATransition *animation = [CATransition animation];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:window.frame];
    scroll.backgroundColor = [UIColor whiteColor];
    scroll.layer.masksToBounds = YES;
    scroll.tag = TagLargeImage;
    
    //显示大图
    UIImageView *large = [[UIImageView alloc] initWithFrame:
								  CGRectMake(0.0, 0.0, scroll.frame.size.width, scroll.frame.size.height -  20.0)];
    [large setContentMode:UIViewContentModeScaleAspectFit];
    [large setBackgroundColor:[UIColor clearColor]];
    [large setTag:TagLargeImage];
	//[large setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil showIndicator:YES];
    [scroll addSubview:large];
	[scroll setBackgroundColor:[UIColor blackColor]];
    [window addSubview:scroll];
    
    //动画参数设置
    [scroll setAlpha:0.0];
    scroll.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [scroll setAlpha:1.0];
    scroll.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromTop;
    animation.duration = 1.0;
    window.layer.opacity = 1.0;
    [animation  setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [window.layer addAnimation:animation forKey:@"transitionViewAnimation"];
    [UIView commitAnimations];
	
    //关闭按钮
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.tag = TagCloseButton;
    close.frame = CGRectMake(window.frame.size.width/2 - KeyCloseSize, window.frame.size.height - 68/2, KeyCloseSize, 68/2);
   // [close setImage:[UIImage imageNamedTwo:@"selfView_icon_normal"] forState:UIControlStateNormal];
	//[close setImage:[UIImage imageNamedTwo:@"selfView_icon_pressed"] forState:UIControlStateHighlighted];
	[close setTitle:@"关闭" forState:UIControlStateNormal];
    [close addTarget:self action:@selector(dismissModalImage:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:close];
}

+ (void) dismissModalImage:(UIButton *)button {
    
    [UIView beginAnimations:@"ImageAnimation" context:NULL];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDuration:0.15];
    CATransition *animation = [CATransition animation];
	
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [[window viewWithTag:TagCloseButton] removeFromSuperview];
    UIView *scroll = (UIView *)[window viewWithTag:TagLargeImage];
    scroll.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [scroll setAlpha:1.0];
    scroll.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [scroll setAlpha:0.0];
    [window sendSubviewToBack:scroll];
    [scroll removeFromSuperview];
    
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromTop;
    animation.duration = 1.0;
    window.layer.opacity = 1.0;
    [animation  setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [window.layer addAnimation:animation forKey:@"transitionViewAnimation"];
    [UIView commitAnimations];
}

@end
