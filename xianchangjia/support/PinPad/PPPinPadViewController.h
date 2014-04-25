//
//  VTPinPadViewController.h
//  PinPad
//
//  Created by Aleks Kosylo on 1/15/14.
//  Copyright (c) 2014 Aleks Kosylo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PWdString @"PWdStringPINS"


@protocol PinPadPasswordProtocol <NSObject>

@required
- (NSInteger)pinLenght;
- (BOOL)checkPin:(NSString *)pin;

- (void)CorrectRight;
- (void)CorrectError;
@end


@interface PPPinPadViewController : UIViewController {
    __weak IBOutlet UIView *_pinCirclesView;
    __weak IBOutlet UIView *_errorView;
    NSMutableString *_inputPin;
    NSMutableArray *_circleViewList;
    
}

@property (nonatomic,assign) id<PinPadPasswordProtocol> delegate;

@property (nonatomic,assign) int inputModel; // 1. default model  2.settings pwd model


@property (weak, nonatomic) IBOutlet UILabel *Textview_toast;
@property (weak, nonatomic) IBOutlet UILabel *Lable_alert;


@end
