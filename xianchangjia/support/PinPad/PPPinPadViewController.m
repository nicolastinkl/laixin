//
//  VTPinPadViewController.m
//  PinPad
//
//  Created by Aleks Kosylo on 1/15/14.
//  Copyright (c) 2014 Aleks Kosylo. All rights reserved.
//

#import "PPPinPadViewController.h"
#import "PPPinCircleView.h"
#import "NSString+Addition.h"


@interface PPPinPadViewController () {
    NSInteger _shakes;
    NSInteger _direction;
    bool twiceTimes;
}

@end

static  CGFloat kVTPinPadViewControllerCircleRadius = 6.0f;
@implementation PPPinPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCircles];
    
    if (self.inputModel == 1) {
        self.Textview_toast.text = @"输入密码";
        self.Lable_alert.text = @"密码错误";
    }else if (self.inputModel == 2) {
        self.Textview_toast.text = @"请设置您的密码";
        _errorView.hidden = NO;
        self.Lable_alert.text = @"每次进入'来抢'时都会要求输入密码,以保护个人隐藏";
    }
    twiceTimes = NO;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissPinPad {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Status Bar
- (void)changeStatusBarHidden:(BOOL)hidden {
    _errorView.hidden = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    return !_errorView.hidden;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark Actions

- (IBAction)cancelClick:(id)sender {
    [self dismissPinPad];
}

- (IBAction)resetClick:(id)sender {
    [self addCircles];
    _inputPin = [NSMutableString string];
}


- (IBAction)numberButtonClick:(id)sender {
    
    if(!_inputPin) {
        _inputPin = [NSMutableString new];
    }
    
    if (self.inputModel == 1) {
        
        if(!_errorView.hidden) {
            [self changeStatusBarHidden:YES];
        }
    }
    
    
    [_inputPin appendString:[((UIButton*)sender) titleForState:UIControlStateNormal]];
    [self fillingCircle:_inputPin.length - 1];
    
    if (self.inputModel  == 1 ) {
        if ([self checkPin:_inputPin]) {
            NSLog(@"Correct pin");
            if([self.delegate respondsToSelector:@selector(CorrectRight)]) {
                [self.delegate CorrectRight];
            }
            [self dismissPinPad];
            
        }
        else if ([self pinLenght] == _inputPin.length) {
            _direction = 1;
            _shakes = 0;
            [self shakeCircles:_pinCirclesView];
            [self changeStatusBarHidden:NO];
            if([self.delegate respondsToSelector:@selector(CorrectError)]) {
                [self.delegate CorrectError];
            }
//            SLog(@"Not correct pin");
        }
    }else{
        if ([self pinLenght] == _inputPin.length)
        {
            //第一次输入
            if (twiceTimes) {
                
                NSString * Pin = [[NSUserDefaults standardUserDefaults] stringForKey:PWdString];
                // get md5
                NSString * newmd5Str = [_inputPin md5Hash];
                if ([newmd5Str isEqualToString:Pin]) {
                    if([self.delegate respondsToSelector:@selector(CorrectRight)]) {
                        [self.delegate CorrectRight];
                    }
                    [self dismissPinPad];
                } else{
                    twiceTimes = NO;
                    _direction = 1;
                    _shakes = 0;
                    [self shakeCircles:_pinCirclesView];
                    [self changeStatusBarHidden:NO];
                    self.Textview_toast.text = @"两次密码不一致,请重新输入";
                    
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.Textview_toast.text = @"请设置您的密码";
                    });
                    _errorView.hidden = NO;
                    self.Lable_alert.text = @"每次进入'来抢'时都会要求输入密码,以保护个人隐藏";
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:PWdString];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else{
                NSString * newmd5Str = [_inputPin md5Hash];
                [[NSUserDefaults standardUserDefaults] setValue:newmd5Str forKey:PWdString];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.Textview_toast.text = @"请确认您的密码";
                _errorView.hidden = NO;
                self.Lable_alert.text = @"每次进入'来抢'时都会要求输入密码,以保护个人隐藏";
                twiceTimes = YES;
                [self resetClick:nil];
            }
            
           
           
        }
    }
    
   
}

#pragma mark Delegate & methods

- (void)setDelegate:(id<PinPadPasswordProtocol>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
        [self addCircles];
    }
}

- (BOOL)checkPin:(NSString *)pinString {
    if([self.delegate respondsToSelector:@selector(checkPin:)]) {
        return [self.delegate checkPin:pinString];
    }
    return YES;
}

- (NSInteger)pinLenght {
    if([self.delegate respondsToSelector:@selector(pinLenght)]) {
        return [self.delegate pinLenght];
    }
    return 4;
}

#pragma mark Circles


- (void)addCircles {
    if([self isViewLoaded] && self.delegate) {
        [[_pinCirclesView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_circleViewList removeAllObjects];
        _circleViewList = [NSMutableArray array];
        
        CGFloat neededWidth =  [self pinLenght] * kVTPinPadViewControllerCircleRadius;
        CGFloat shiftBetweenCircle = (_pinCirclesView.frame.size.width - neededWidth )/([self pinLenght] +2);
        CGFloat indent= 1.5* shiftBetweenCircle;
        if(shiftBetweenCircle > kVTPinPadViewControllerCircleRadius * 5.0f) {
            shiftBetweenCircle = kVTPinPadViewControllerCircleRadius * 5.0f;
            indent = (_pinCirclesView.frame.size.width - neededWidth  - shiftBetweenCircle *([self pinLenght] > 1 ? [self pinLenght]-1 : 0))/2;
        }
        for(int i=0; i < [self pinLenght]; i++) {
            PPPinCircleView * circleView = [PPPinCircleView circleView:kVTPinPadViewControllerCircleRadius];
            CGRect circleFrame = circleView.frame;
            circleFrame.origin.x = indent + i * kVTPinPadViewControllerCircleRadius + i*shiftBetweenCircle;
            circleFrame.origin.y = (CGRectGetHeight(_pinCirclesView.frame) - kVTPinPadViewControllerCircleRadius)/2.0f;
            circleView.frame = circleFrame;
            [_pinCirclesView addSubview:circleView];
            [_circleViewList addObject:circleView];
        }
    }
}

- (void)fillingCircle:(NSInteger)symbolIndex {
    if(symbolIndex>=_circleViewList.count)
        return;
    PPPinCircleView *circleView = [_circleViewList objectAtIndex:symbolIndex];
    circleView.backgroundColor = [UIColor whiteColor];
}

-(void)shakeCircles:(UIView *)theOneYouWannaShake
{
    [UIView animateWithDuration:0.03 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*_direction, 0);
     }
                     completion:^(BOOL finished)
     {
         if(_shakes >= 15)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             [self resetClick:nil];
             return;
         }
         _shakes++;
         _direction = _direction * -1;
         [self shakeCircles:theOneYouWannaShake];
     }];
}
@end
