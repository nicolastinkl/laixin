//
//  MLCanPopUpImageView.m
//  RefreshTable
//
//  Created by Molon on 13-11-13.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MLCanPopUpImageView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "XCAlbumDefines.h"
#import "UIView+Additon.h"

#define kFullScreenImageAnimationDuration .35f

@interface UIImageView (Addtion)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage displayProgress:(BOOL)displayProgress completed:(SDWebImageCompletedBlock)completedBlock;

@end

@implementation UIImageView (Addtion)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage*)placeholderImage displayProgress:(BOOL)displayProgress completed:(SDWebImageCompletedBlock)completedBlock
{
    if (!displayProgress) {
        [self setImageWithURL:url placeholderImage:self.image completed:completedBlock];
        return;
    }
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhite;
    if (!placeholderImage) {
        style = UIActivityIndicatorViewStyleGray;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    CGRect activityFrame = activityIndicator.frame;
//    activityIndicator.backgroundColor = ios7BlueColor;
    activityIndicator.color = ios7BlueColor;
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
        //执行原block
        completedBlock(image,error,cacheType);
    }];
}
@end

@interface UIView (FindAndResignFirstResponder)

- (BOOL)findAndResignFirstResponder;

@end

@implementation UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end

/**
 *  显示图片view
 */

@interface MLCanPopUpImageView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *imageBackgroundView_FullScreen;
@property (nonatomic, strong) UIView *imageMaskView_FullScreen;
@property (nonatomic, strong) UIImageView *imageView_FullScreen;
@property (nonatomic, strong) UIScrollView *scrollview;

//放大和移动手势用到的
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) CGFloat firstX;
@property (nonatomic, assign) CGFloat firstY;

@end

@implementation MLCanPopUpImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        //给自身添加点击事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [super addGestureRecognizer:tapGesture];
        [tapGesture addTarget:self action:@selector(imageViewTap:)];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        //给自身添加点击事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [super addGestureRecognizer:tapGesture];
        [tapGesture addTarget:self action:@selector(imageViewTap:)];
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

- (CGFloat)getFullScreenAnimationDuration
{
    if (_fullScreenAnimationDuration<=0) {
        _fullScreenAnimationDuration = kFullScreenImageAnimationDuration;
    }
    return _fullScreenAnimationDuration;
}

#pragma mark - 避免设置的处理下
- (void)setContentMode:(UIViewContentMode)contentMode
{
    if (contentMode!=UIViewContentModeScaleAspectFill) {
        return;
    }
    [super setContentMode:contentMode];
}

//不可添加其他的实现。
- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2)
{
    return;
}

#pragma mark - 主要实现
//根据aspectFill的frame和图片的比例，来获取能显示同样区域的aspectFit的frame
- (CGRect)aspectFitFrameForAspectFillBounds:(CGRect)bounds andImageSize:(CGSize)imageSize
{
    if (imageSize.width>imageSize.height) {
        CGFloat origWidth = bounds.size.width;
        bounds.size.width = bounds.size.height*(imageSize.width/imageSize.height);
        bounds.origin.x -= (bounds.size.width-origWidth)/2;
    }else if(imageSize.width<imageSize.height) {
        CGFloat origHeight = bounds.size.height;
        bounds.size.height = bounds.size.width*(imageSize.height/imageSize.width);
        bounds.origin.y -= (bounds.size.height-origHeight)/2;
    }
    return bounds;
}

//根据frame和图片长宽来获取AspectFit真正的无空闲空间的frame。
- (CGRect)realFrameForAspectFitFrame:(CGRect)frame andImageSize:(CGSize)imageSize
{
    if (imageSize.width>imageSize.height) {
        CGFloat origHeight = frame.size.height;
        frame.size.height = frame.size.width*(imageSize.height/imageSize.width);
        frame.origin.y += (origHeight-frame.size.height)/2;
    }else if(imageSize.width<imageSize.height) {
        CGFloat origWidth = frame.size.width;
        frame.size.width = frame.size.height*(imageSize.width/imageSize.height);
        frame.origin.x += (origWidth-frame.size.width)/2;
    }
    return frame;
}

- (void)imageViewTap:(UIGestureRecognizer *)gesture
{
    if (!self.image) {
        return;
    }
    //最上层View
    UIView *topView = [UIApplication sharedApplication].delegate.window;
    [topView findAndResignFirstResponder];
    
    //设置全屏背景
    UIView *blackColorView = [[UIView alloc] initWithFrame:topView.bounds];
    blackColorView.backgroundColor = [UIColor clearColor];
    [topView addSubview:self.imageBackgroundView_FullScreen = blackColorView];
    
    //设置一个maskView
    CGRect frame = [self.superview convertRect:self.frame toView:topView];
    UIView *maskView = [[UIView alloc]initWithFrame:frame];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.clipsToBounds = YES;
    [topView addSubview:self.imageMaskView_FullScreen = maskView]; // change by tinkl
    
    self.scrollview=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];//申明一个scrollview
    self.scrollview.delegate=self;//需要在.h中引用scrollview的delegate
    self.scrollview.backgroundColor=[UIColor clearColor];
    self.scrollview.alpha=1.0;
    self.scrollview.scrollEnabled = YES;
    self.scrollview.scrollsToTop = YES;
    self.scrollview.bouncesZoom = YES;
    self.scrollview.clipsToBounds = YES;
    self.scrollview.showsHorizontalScrollIndicator = YES;
    self.scrollview.showsVerticalScrollIndicator = YES;
    [self.imageMaskView_FullScreen addSubview:self.scrollview];
    //图片放大，设置大图片的网址
    CGRect imageframe = [self aspectFitFrameForAspectFillBounds:self.bounds andImageSize:self.image.size];
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithFrame:imageframe];
    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
    //UIViewContentModeScaleAspectFill;
    // UIViewContentModeScaleAspectFit;
//    [maskView addSubview:self.imageView_FullScreen = fullScreenImageView];
    
    [self.scrollview addSubview:self.imageView_FullScreen = fullScreenImageView];
    
    
    
    //设置全屏图片，并且设置此图片点击后的selector
    UITapGestureRecognizer *fullScreenImageSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageEvent:)];
    [fullScreenImageView addGestureRecognizer:fullScreenImageSingleTap];
 
    //TODO:Molon 下面俩手势未完成，不好使
//    //双指放大
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//    [fullScreenImageView addGestureRecognizer:pinchRecognizer];
//
//    //移动
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//    [panRecognizer setMinimumNumberOfTouches:1];
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [fullScreenImageView addGestureRecognizer:panRecognizer];

    
    fullScreenImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    //imageView的新frame,默认设置
    CGRect toFrame = CGRectInset(topView.bounds, 20, 40);
    fullScreenImageView.image = self.image;
    
    //根据url判断是否之前已经缓存过此图片
    if (_fullScreenImageURL) {
        NSString *key = [_fullScreenImageURL absoluteString];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if (manager.cacheKeyFilter)
        {
            key = manager.cacheKeyFilter(_fullScreenImageURL);
        }
        UIImage *cacheImage = [manager.imageCache imageFromMemoryCacheForKey:key];
        if (!cacheImage) {
            cacheImage = [manager.imageCache imageFromDiskCacheForKey:key];
        }
        if (cacheImage) {
            toFrame = topView.bounds;
            //直接设置缓存里图片
            fullScreenImageView.image = cacheImage;
        }
        
//        float minimumScale = fullScreenImageView.height / fullScreenImageView.width;//设置缩放比例
//        [self.scrollview setMinimumZoomScale:minimumScale];//设置最小的缩放大小
//        [self.scrollview setZoomScale:minimumScale];//设置scrollview的缩放
//        [self scrollViewDidZoom:self.scrollview];

    }else{
        toFrame = topView.bounds;
    }
    
//    CGRect newImageViewFrame = [self realFrameForAspectFitFrame:toFrame andImageSize:self.image.size];

    _imageView_FullScreen.userInteractionEnabled = NO;
    [UIView animateWithDuration:self.fullScreenAnimationDuration
                     animations:^{
                         _imageBackgroundView_FullScreen.backgroundColor = [UIColor blackColor];
                         _imageMaskView_FullScreen.frame = toFrame;
//                         _imageView_FullScreen.frame = newImageViewFrame;
                     }
                     completion:^(BOOL finished) {
                         _imageView_FullScreen.userInteractionEnabled = YES;
                         //如果现在就是最终大小，说明从缓存里直接取图片了，不需要再次取
                         if (!CGRectEqualToRect(toFrame, topView.bounds)) {
//                            CGRect finallyImageViewFrame = [self realFrameForAspectFitFrame:topView.bounds andImageSize:self.image.size];
                             
                             __weak MLCanPopUpImageView *weak_self = self;
                             [_imageView_FullScreen setImageWithURL:_fullScreenImageURL placeholderImage:self.image displayProgress:YES completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 
                                 [UIView animateWithDuration:weak_self.fullScreenAnimationDuration
                                                  animations:^{
                                                      weak_self.imageMaskView_FullScreen.frame = topView.bounds;
//                                                      weak_self.imageView_FullScreen.frame = finallyImageViewFrame;
                                                  }];
                             }];

                         }
                    }];
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView//scrollview的delegate事件。需要设置缩放才会执行。
{
    return self.imageView_FullScreen;
}

//让图片居中
//- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
//{
//    CGFloat offsetX = (self.scrollview.width > self.scrollview.contentSize.width)?
//    (self.scrollview.width - self.scrollview.contentSize.width) * 0.5 : 0.0;
//    CGFloat offsetY = (self.scrollview.height > self.scrollview.contentSize.height)?
//    (self.scrollview.height - self.scrollview.contentSize.height) * 0.5 : 0.0;
//    
//     self.imageView_FullScreen.center = CGPointMake(self.scrollview.contentSize.width * 0.5 + offsetX,  self.scrollview.contentSize.height * 0.5 + offsetY);
//}


- (void)fullScreenImageEvent:(id)sender
{
    //最上层View
    UIView *topView = [UIApplication sharedApplication].delegate.window;
    CGRect maskFrame = [self.superview convertRect:self.frame toView:topView];
//    CGRect imageframe = [self aspectFitFrameForAspectFillBounds:self.bounds andImageSize:self.image.size];
    _imageView_FullScreen.userInteractionEnabled = NO;
    
    //必须主动去停止进度条。
    [_imageView_FullScreen cancelCurrentImageLoad];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[_imageView_FullScreen viewWithTag:8888];
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    
    _imageView_FullScreen.image = self.image;
    [UIView animateWithDuration:self.fullScreenAnimationDuration
                     animations:^{
                         _imageView_FullScreen.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                         
                         _imageMaskView_FullScreen.frame = maskFrame;
//                         _imageView_FullScreen.frame = imageframe;
                         _imageBackgroundView_FullScreen.backgroundColor = [UIColor clearColor];
                         
                     }
                     completion:^(BOOL finished) {
                         [_imageMaskView_FullScreen removeFromSuperview];
                         [_imageBackgroundView_FullScreen removeFromSuperview];
                         [_imageView_FullScreen removeFromSuperview];
                     }];
}

// 缩放
-(void)scale:(id)sender {
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0;
    }else if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (_imageView_FullScreen.transform.a<1) {
            [UIView animateWithDuration:.25f
                             animations:^{
                                 _imageView_FullScreen.transform = _imageView_FullScreen.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                             }];
            return;
        }else if (_imageView_FullScreen.transform.a>2){
            [UIView animateWithDuration:.25f
                             animations:^{
                                 _imageView_FullScreen.transform = _imageView_FullScreen.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 2.0);
                             }];
            return;
        }
    }
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale])/_imageView_FullScreen.transform.a;
    
    CGAffineTransform currentTransform = _imageView_FullScreen.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [_imageView_FullScreen setTransform:newTransform];
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

// 移动
-(void)move:(id)sender {
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:_imageView_FullScreen];
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = _imageView_FullScreen.center.x;
        _firstY = _imageView_FullScreen.center.y;
    }
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    _imageView_FullScreen.center = translatedPoint;
}

@end
