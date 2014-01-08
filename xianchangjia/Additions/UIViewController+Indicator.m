//
//  UIViewController+UIViewController_Indicator.m
//  xianchangjia
//
//  Created by apple on 13-12-9.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "UIViewController+Indicator.h"
#import "UIView+Additon.h"
#import "XCJErrorView.h"
typedef enum {
    kTagIndicatorView = 2900,
    kTaglabelView = 2901,
    kTagErrorView = 2902,
}kUIViewIndicatorTags;


@implementation UIViewController (Indicator)


- (void)showIndicatorView
{
    [self showIndicatorViewAtpoint:CGPointMake((self.view.width-20)/2, (self.view.height-100)/2)];
}


- (void)showIndicatorViewAtpoint:(CGPoint)point{
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    [self showIndicatorViewAtpoint:point indicatorStyle:style];
}

- (void)showIndicatorViewWithStyle:(UIActivityIndicatorViewStyle)style{
    [self showIndicatorViewAtpoint:CGPointMake((self.view.width-20)/2, (self.view.height-20)/2) indicatorStyle:style];
}

- (void)showIndicatorViewAtpoint:(CGPoint)point indicatorStyle:(UIActivityIndicatorViewStyle)style{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.view subviewWithTag:kTagIndicatorView];
    
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        indicator.frame = CGRectMake(point.x, point.y, 20, 20);
        indicator.tag = kTagIndicatorView;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:indicator];
        [indicator startAnimating];
    }
    
    
    UILabel *textLabel = (UILabel *)[self.view subviewWithTag:kTaglabelView];
    if ([textLabel isMemberOfClass:[UILabel class]]) {
        textLabel.text = @"";
    }
    
    [indicator startAnimating];
}

- (void)hideIndicatorView{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.view subviewWithTag:kTagIndicatorView];
    if(indicator){
        if ([indicator isMemberOfClass:[UIActivityIndicatorView class]]) {
            [indicator stopAnimating];
            [indicator removeFromSuperview]; indicator = nil;
            return;
        }
        NSAssert([indicator isMemberOfClass:[UIActivityIndicatorView class]], @"indicator view错误,重复tag");
    }
    
    UILabel * textLabel = (UILabel *)[self.view subviewWithTag:kTaglabelView];
    if (textLabel) {
      if ([textLabel isMemberOfClass:[UILabel class]]) {
          textLabel.text = @"";
          [textLabel removeFromSuperview];
          textLabel = nil;
      }
    }
    
}
/**
 *  处理隐藏失败后然后显示回调处理函数
 *
 *  @param statusContent 文本状态信息
 *  @param voidFun       错误block回调
 */
- (void)hideIndicatorView:(NSString*)statusContent block:(SLBlockBlock) voidFun
{
    [self hideIndicatorView];
    // add text.view to self.view(parent)
    UILabel * textContent = (UILabel *)[self.view subviewWithTag:kTaglabelView];
    if (textContent == nil) {
        CGPoint point = CGPointMake(0, (self.view.height-100)/2);
        textContent = [[UILabel alloc] init];
        textContent.frame = CGRectMake(point.x, point.y, 320, 20);
        textContent.tag = kTaglabelView;
        textContent.textColor = [UIColor grayColor];
        textContent.font = [UIFont systemFontOfSize:14.0f];
        textContent.textAlignment = NSTextAlignmentCenter;
    }
    textContent.text = statusContent;
    [self.view addSubview:textContent];
    /**
     *  show indicator and hide text
    
    SLBlock voidblock =
    ^{
       
        UILabel *textLabel = (UILabel *)[self.view subviewWithTag:kTaglabelView];
        if ([textLabel isMemberOfClass:[UILabel class]]) {
            textLabel.text = @"";
            [textLabel removeFromSuperview];
            textLabel = nil;
        }
        [self showIndicatorView];
        
    };
    voidFun(voidblock);
    */
}

- (void) showErrorInfoWithRetry
{
    XCJErrorView * errorView = [[NSBundle mainBundle] loadNibNamed:@"XCJErrorView" owner:self options:nil][0];
    errorView.tag  = kTagErrorView;
    [self.view addSubview:errorView];
}

- (void) hiddeErrorInfoWithRetry
{
    UIView *textLabel = (UIView *)[self.view subviewWithTag:kTagErrorView];
    if (textLabel) {
        [textLabel removeFromSuperview];
        textLabel = nil;
    }
}

@end
