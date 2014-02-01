//
//  UIImageView+Addtion.m
//  RefreshTable
//
//  Created by Molon on 13-11-13.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "UIImageView+Addtion.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (Addtion)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage displayProgress:(BOOL)displayProgress
{
    if (!displayProgress) {
        [self setImageWithURL:url placeholderImage:self.image];
        return;
    }
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhite;
    if (!placeholderImage) {
        style = UIActivityIndicatorViewStyleGray;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    CGRect activityFrame = activityIndicator.frame;
    
    CGFloat side = 20;
    if (self.frame.size.height<20||self.frame.size.width<20) {
        if (self.frame.size.height<self.frame.size.width) {
            side = self.frame.size.height;
        }else{
            side = self.frame.size.width;
        }
    }
    
    activityFrame.size = CGSizeMake(side, side);
    activityIndicator.frame = activityFrame;
    activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.tag = 8888;
    [self addSubview:activityIndicator];
    
    [self setImageWithURL:url placeholderImage:self.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSUInteger receivedSize, long long expectedSize) {
        [activityIndicator startAnimating];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
    }];
}

@end
