//
//  UIView+Indicator.m
//  XianchangjiaAlbum
//
//  Created by JIJIA &&&&& ljh on 12-12-17.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "UIView+Indicator.h"
#import "UIView+Additon.h"

typedef enum {
    kTagIndicatorView = 1988,
    kTagIndicatorViewImg = 1989,
}kUIViewIndicatorTags;

@implementation UIView (Indicator)

- (void)showIndicatorView{
    [self showIndicatorViewAtpoint:CGPointMake((self.width-20)/2, (self.height-20)/2)];
}

- (void)showIndicatorViewAtpoint:(CGPoint)point{
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    [self showIndicatorViewAtpoint:point indicatorStyle:style];
}

- (void)showIndicatorViewWithStyle:(UIActivityIndicatorViewStyle)style{
    [self showIndicatorViewAtpoint:CGPointMake((self.width-20)/2, (self.height-20)/2) indicatorStyle:style];
}

- (void)showIndicatorViewAtpoint:(CGPoint)point indicatorStyle:(UIActivityIndicatorViewStyle)style{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self subviewWithTag:kTagIndicatorView];
    
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        indicator.frame = CGRectMake(point.x, point.y, 20, 20);
        indicator.tag = kTagIndicatorView; 
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:indicator];
        [indicator startAnimating];
    }
    
    [indicator startAnimating];
}

- (void)hideIndicatorView{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self subviewWithTag:kTagIndicatorViewImg];
    
    if(indicator){
        if ([indicator isMemberOfClass:[UIActivityIndicatorView class]]) {
            [indicator stopAnimating];
            [indicator removeFromSuperview]; indicator = nil;
            return;
        }
        
        NSAssert([indicator isMemberOfClass:[UIActivityIndicatorView class]], @"indicator view错误,重复tag");
    }
}

- (void)showIndicatorViewGary
{
    CGPoint point = CGPointMake((self.width-20)/2, (self.height-20)/2);
    UIImageView *indicator = (UIImageView *)[self subviewWithTag:kTagIndicatorViewImg];
    
    if (!indicator) {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingSpinnerSmallGray"]];
        indicator.frame = CGRectMake(point.x, point.y, 28, 28);
        indicator.tag = kTagIndicatorViewImg;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:indicator];
        [self startAnimation:indicator];
    }
    indicator.hidden = NO;
    [self startAnimation:indicator];
}

- (void)startAnimation:(UIImageView *)button{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];///* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    
    [button.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation{
    UIImageView *indicator = (UIImageView *)[self subviewWithTag:kTagIndicatorViewImg];
    
    if (indicator) {
        [indicator.layer removeAllAnimations];
        indicator.hidden = YES;
        [indicator removeFromSuperview];
    }
}

- (void)showIndicatorViewBlue
{
    CGPoint point = CGPointMake((self.width-20)/2, (self.height-20)/2);
    UIImageView *indicator = (UIImageView *)[self subviewWithTag:kTagIndicatorViewImg];
    
    if (!indicator) {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingSpinnerSmallBlue"]];
        indicator.frame = CGRectMake(point.x, point.y, 28, 28);
        indicator.tag = kTagIndicatorViewImg;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:indicator];
        [self startAnimation:indicator];
    }
    indicator.hidden = NO;
    [self startAnimation:indicator];
}

- (void)showIndicatorViewLargeBlue
{
    CGPoint point = CGPointMake((self.width-20)/2, (self.height-20)/2);
    UIImageView *indicator = (UIImageView *)[self subviewWithTag:kTagIndicatorViewImg];
    
    if (!indicator) {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingSpinnerBlue"]];
        indicator.frame = CGRectMake(point.x, point.y, 55, 55);
        indicator.tag = kTagIndicatorViewImg;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:indicator];
        [self startAnimation:indicator];
    }
    indicator.hidden = NO;
    [self startAnimation:indicator];
}

- (void)hideIndicatorViewBlueOrGary
{
//    [self stopAnimation];
//    [self stopAnimation];
//    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
//    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
//    NSTimeInterval delay = (end-start>2.0?0:(2.0-(end-start)));
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:0.3];
}
@end
