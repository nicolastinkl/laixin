//
//  MLActionSheet.m
//  MLActionSheet
//
//  Created by Molon on 13-11-22.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MLActionSheet.h"

#define kActionButtonHeight 43
#define kAnimateDuration .30f

#define kMainOpacity 0.96f
#define kBackOpacity 0.4f
#define kBorderColor [UIColor colorWithWhite:0.674 alpha:1.000].CGColor
#define kViewBackgroundColor [UIColor colorWithWhite:0.936 alpha:1.000]
#define kCommonTextColor [UIColor colorWithRed:0.092 green:0.253 blue:0.537 alpha:1.000]

#define kCommonFont [UIFont boldSystemFontOfSize:17]

const UIWindowLevel UIWindowLevelMLActionSheet = 1999.0;

#pragma mark - MLActionSheet interface
@interface MLActionSheet()

@property(nonatomic,strong) NSMutableArray *buttons;

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIView *containerView;

@property(nonatomic,assign) BOOL isVisible;

//主要的View
@property(nonatomic,strong) UIView *mainView;
//背景黑层View
@property (nonatomic, strong) UIView *backgroundView;

//使用其处理旋转事件
@property(nonatomic,strong) UIWindow *actionWindow;

@end


#pragma mark - MLActionSheetViewController

@interface MLActionSheetViewController : UIViewController

@property (nonatomic, strong) MLActionSheet *actionSheet;

@end

@implementation MLActionSheetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.actionSheet.frame = self.view.bounds;
    self.actionSheet.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    //self.view 对autoresizingMask不感冒。就不直接设置其为actionSheet了
    [self.view addSubview:self.actionSheet];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.actionSheet setNeedsLayout];
}

@end

#pragma mark - MLActionSheet implementation

@implementation MLActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //默认值
        self.buttons = [NSMutableArray arrayWithCapacity:1];
        self.cancelButtonIndex = -1;
        self.destructiveButtonIndex = -1;
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

- (id)initWithTitle:(NSString *)title delegate:(id<MLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    //没有按钮，干个屁啊。
    if (cancelButtonTitle.length<=0&&destructiveButtonTitle.length<=0&&otherButtonTitles.length<=0) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        self.title = title;
        self.delegate = delegate;
        
        if (destructiveButtonTitle.length>0) {
            //添加警告按钮
            self.destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle withStyleMask:MLActionButtonStyleRedText];
        }
        
        //根据otherButtonTitles添加按钮
        if (otherButtonTitles != nil) {
            id eachObject;
            va_list argumentList;
            if (otherButtonTitles) {
                [self addButtonWithTitle:otherButtonTitles];
                va_start(argumentList, otherButtonTitles);
                while ((eachObject = va_arg(argumentList, id))) {
                    [self addButtonWithTitle:eachObject];
                }
                va_end(argumentList);
            }
        }
        
        if (cancelButtonTitle.length>0) {
            //添加取消按钮,此按钮因为不在容器View内，单独处理吧
            UIButton *button = [self getButtonWithStyleMask:MLActionButtonStyleCorner];
            [button setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [self.mainView addSubview:button];
            [self.buttons addObject:button];
            self.cancelButtonIndex = [self.buttons indexOfObject:button];
            
            button.tag = self.cancelButtonIndex+100;
            [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

#pragma mark - present and dismiss
- (void)showInView:(UIView *)view
{
    if (self.isVisible) {
        return;
    }
    
    //自己建立的window,很高的level
    MLActionSheetViewController *viewController = [[MLActionSheetViewController alloc] init];
    viewController.actionSheet = self;
    if (!self.actionWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelMLActionSheet;
        window.rootViewController = viewController;
        self.actionWindow = window;
    }
    [self.actionWindow makeKeyAndVisible];
    
    //强制刷新
    [self layoutIfNeeded];
    
    self.isVisible = YES;
    
    CGRect frame = self.mainView.frame;
    frame.origin.y = CGRectGetHeight(self.frame);
    self.mainView.frame = frame; //跑到最底
    
    frame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(self.mainView.frame);
    
    //执行动画
    if (self.delegate&&[self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    self.backgroundView.layer.opacity = 0;
    [UIView animateWithDuration:kAnimateDuration
                     animations:^{
                         self.mainView.frame = frame; //跑到最底
                         self.backgroundView.layer.opacity = kBackOpacity;
                     }
     completion:^(BOOL finished) {
         if (self.delegate&&[self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
             [self.delegate didPresentActionSheet:self];
         }
     }];
    
}


- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (buttonIndex<0||buttonIndex>=self.buttons.count) {
        return;
    }
    
    if (animated) {
        //消失动画
        CGRect newFrame = self.mainView.frame;
        newFrame.origin.y = CGRectGetHeight(self.frame);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self willDismissWithButtonIndex:buttonIndex];
        }
        [UIView animateWithDuration:kAnimateDuration
                         animations:^{
                             self.mainView.frame = newFrame; //跑到最底
                             self.backgroundView.layer.opacity = 0;
                         }
                         completion:^(BOOL finished) {
                             if (self.delegate&&[self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                                 [self.delegate actionSheet:self didDismissWithButtonIndex:buttonIndex];
                             }
                             [self removeFromSuperview];
                             self.isVisible = NO;
                             
                             [self.actionWindow removeFromSuperview];
                             self.actionWindow = nil;
                         }];
        return;
    }
    
    [self removeFromSuperview];
    self.actionWindow = nil;
}

- (void)buttonEvent:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger buttonIndex = button.tag - 100;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
        
//        if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
//            if (buttonIndex == self.cancelButtonIndex) {
//                [self.delegate actionSheetCancel:self];
//            }
//        }
    }
    //消失动画
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


- (void)tapBackground
{
    //没有取消按钮的情况下无效的。取消按钮下标默认是-1
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:YES];
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:self.backgroundView];
    [self bringSubviewToFront:self.mainView];
    
    CGFloat cellWidth = CGRectGetWidth(self.mainView.superview.frame)-10*2;
    //调整标题Label的frame
    CGFloat yOffset = 0;
    if (self.title) {
        self.titleLabel.hidden = NO;
        self.titleLabel.frame = CGRectMake(10, yOffset, cellWidth, 50);
        [self.titleLabel sizeToFit];
        CGRect frame = self.titleLabel.frame;
        frame.size.height += 29;
        frame.size.width = cellWidth;
        self.titleLabel.frame = frame;
        
        yOffset += CGRectGetHeight(self.titleLabel.frame);
    }else{
        self.titleLabel.hidden = YES;
        yOffset += 10;
    }
    
    //内容View
    if (self.destructiveButtonIndex>-1
        ||(self.cancelButtonIndex>-1&&self.buttons.count>1)
        ||(self.cancelButtonIndex<=-1&&self.buttons.count>0)
        ) {
        self.containerView.hidden = NO;
        
        CGRect frame = self.containerView.frame;
        frame.origin = CGPointMake(10, yOffset);
        frame.size.width = cellWidth;
        self.containerView.frame = frame;
        
        CGFloat cYOffset = 0;
        
        if (self.destructiveButtonIndex>-1) {
            //其必须放在第一个位置
            [self buttonAtIndex:self.destructiveButtonIndex].frame = CGRectMake(0, cYOffset, cellWidth, kActionButtonHeight);
            cYOffset += kActionButtonHeight;
        }
        //遍历其他的按钮
        for (NSInteger i=0; i<self.buttons.count; i++) {
            if (i==self.destructiveButtonIndex||i==self.cancelButtonIndex) {
                continue;
            }
            [self buttonAtIndex:i].frame = CGRectMake(0, cYOffset-0.5, cellWidth, kActionButtonHeight);
            cYOffset += kActionButtonHeight-0.5;
        }
        //容器View的高度
        frame = self.containerView.frame;
        frame.size.height = cYOffset;
        self.containerView.frame = frame;
        
        yOffset += CGRectGetHeight(self.containerView.frame)+10;
    }else{
        self.containerView.hidden = YES;
    }
    
    //调整取消Button的frame
    if (self.cancelButtonIndex>-1) {
        [self buttonAtIndex:self.cancelButtonIndex].frame = CGRectMake(10, yOffset, cellWidth, kActionButtonHeight);
        yOffset += kActionButtonHeight+10;
    }
    
    self.mainView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-yOffset, CGRectGetWidth(self.frame), yOffset);
    self.backgroundView.frame = self.bounds;
}

#pragma mark - Button
- (NSInteger)addButtonWithTitle:(NSString *)title withStyleMask:(MLActionButtonStyleMask)styleMask
{
    if (title.length<=0) {
        return -1;
    }
    UIButton *button = [self getButtonWithStyleMask:styleMask];
    [button setTitle:title forState:UIControlStateNormal];
    [self.containerView addSubview:button];
    
    [self.buttons addObject:button];
    
    NSInteger buttonIndex = [self.buttons indexOfObject:button];
    button.tag = buttonIndex+100;
    [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setNeedsLayout];
    
    return buttonIndex;
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return [self addButtonWithTitle:title withStyleMask:MLActionButtonStyleNone];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex>=self.buttons.count||buttonIndex<0) {
        return nil;
    }
    return ((UIButton*)self.buttons[buttonIndex]).titleLabel.text;
}

- (UIButton *)buttonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex>=self.buttons.count||buttonIndex<0) {
        return nil;
    }
    return (UIButton*)self.buttons[buttonIndex];
}


- (UIButton *)getButtonWithStyleMask:(MLActionButtonStyleMask)styleMask
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderColor = kBorderColor;
    button.layer.borderWidth = 0.5f;
    button.backgroundColor = [UIColor whiteColor];
    [button setBackgroundImage:[self pureColorImageWithColor:[UIColor colorWithWhite:0.838 alpha:1.000]] forState:UIControlStateHighlighted];
    button.titleLabel.font = kCommonFont;
    button.exclusiveTouch = YES;
    button.clipsToBounds = YES;
    if (styleMask&MLActionButtonStyleCorner) {
        button.layer.cornerRadius = 5.0f; //按钮圆角
    }
    if (styleMask&MLActionButtonStyleRedText) {
        //警告按钮红色文本
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else{
        [button setTitleColor:kCommonTextColor forState:UIControlStateNormal];
    }
    
    return button;
}

#pragma mark - setter and getter

- (void)setTitle:(NSString *)title
{
    if ([title isEqualToString:_title]||title.length<=0) {
        return;
    }
    _title = title;
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        //没有的话就初始化
        UILabel *label = [[UILabel alloc]init];
        label.font = kCommonFont;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [self.mainView addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UIView *)containerView
{
    if (!_containerView) {
        //没有的话就初始化
        UIView *view = [[UIView alloc]init];
        view.layer.borderColor = kBorderColor;
        view.layer.borderWidth = 0.5f;
        view.layer.cornerRadius = 5.0f; //按钮圆角
        view.clipsToBounds = YES;
        [self.mainView addSubview:view];
        _containerView = view;
    }
    return _containerView;
}

- (UIView *)mainView
{
    if (!_mainView) {
        //没有的话就初始化
        UIView *view = [[UIView alloc]init];
        view.clipsToBounds = YES;
        view.backgroundColor = kViewBackgroundColor;
        view.layer.opacity = kMainOpacity;
        view.layer.borderColor = kBorderColor;
        view.layer.borderWidth = 0.5f;
        [self addSubview:view];
        _mainView = view;
    }
    return _mainView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        //没有的话就初始化
        UIView *view = [[UIView alloc]init];
        view.layer.opacity = kBackOpacity;
        view.backgroundColor = [UIColor blackColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        [view addGestureRecognizer:gesture];
        
        [self addSubview:view];
        _backgroundView = view;
    }
    return _backgroundView;
}

- (NSInteger)numberOfButtons
{
    return self.buttons.count;
}

- (NSInteger)firstOtherButtonIndex
{
    for (NSInteger i=0; i<self.buttons.count; i++) {
        if (i==self.cancelButtonIndex||i==self.destructiveButtonIndex) {
            continue;
        }
        return i;
    }
    return -1;
}

- (BOOL)isVisible
{
    return _isVisible;
}

#pragma mark - Other Common

- (UIImage *)pureColorImageWithColor:(UIColor*)color
{
    CGSize imageSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}
@end
