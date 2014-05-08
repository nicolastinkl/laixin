//
//  LXCommendViewController.m
//  laixin
//
//  Created by tinkl on 7/5/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "LXCommendViewController.h"
#import "UIButton+Bootstrap.h"
#import "LXCommendModel.h"
#import <ReactiveViewModel.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface LXCommendViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation LXCommendViewController

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
    // Do any additional setup after loading the view.
    
    self.viewModel = [[LXCommendModel alloc] init];
    
    @weakify(self);
    [self.viewModel.modelIsValidArray subscribeNext:^(id x) {
        @strongify(self);
        if (x) NSLog(@"%@ %@",x,self);
        
    }];
    
    RAC(self.label1, text) = RACObserve(self.viewModel, cirleName);
    RAC(self.label2, text) = RACObserve(self.viewModel, cirleLevel);
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button infoStyle];
    [self.view addSubview:button];
    
    [button addTarget:self.viewModel action:@selector(initAllData) forControlEvents:UIControlEventTouchUpInside];
    
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.label1.hidden = YES;
    }];
    
//    [[[[button rac_signalForControlEvents:UIControlEventTouchUpInside]
//	   skip:1] take:1] subscribeNext:^(id x) {
//		@strongify(self);
//        NSLog(@"x %@",x);
//        
//	}];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewModel.active = YES;

}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    self.viewModel.active = YES;
//    
//}
//
//-(void)dealloc
//{
//    self.viewModel.active = NO;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
