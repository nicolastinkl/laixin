//
//  MLActionSheet.h
//  MLActionSheet
//
//  Created by Molon on 13-11-22.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLActionSheetDelegate;

typedef NS_OPTIONS(NSUInteger, MLActionButtonStyleMask) {
    MLActionButtonStyleNone = 0,
    MLActionButtonStyleCorner = 1 << 0,
    MLActionButtonStyleRedText = 1 << 1,
};

@interface MLActionSheet : UIView

@property(nonatomic,weak) id<MLActionSheetDelegate> delegate;
@property(nonatomic,copy) NSString *title;

@property(nonatomic,readonly) NSInteger numberOfButtons;

//这三者没有就是-1
@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic) NSInteger destructiveButtonIndex;
@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;

@property(nonatomic,readonly,getter=isVisible) BOOL visible;

//常用的
- (id)initWithTitle:(NSString *)title delegate:(id<MLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
//其实这个View没鸡巴用,顶多是跟随获得一些样式啥的，暂时没这些功能
- (void)showInView:(UIView *)view;


- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

//自定义的一个东西
- (NSInteger)addButtonWithTitle:(NSString *)title withStyleMask:(MLActionButtonStyleMask)styleMask;

@end


@protocol MLActionSheetDelegate <NSObject>
@optional

- (void)actionSheet:(MLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

//这个暂时不用。不知道有什么用。
//- (void)actionSheetCancel:(MLActionSheet *)actionSheet;

- (void)willPresentActionSheet:(MLActionSheet *)actionSheet;
- (void)didPresentActionSheet:(MLActionSheet *)actionSheet;

- (void)actionSheet:(MLActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)actionSheet:(MLActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
