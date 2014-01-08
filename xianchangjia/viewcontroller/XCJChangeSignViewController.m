//
//  XCJChangeSignViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJChangeSignViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"

@interface XCJChangeSignViewController ()<UITextViewDelegate>

@end

@implementation XCJChangeSignViewController

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
    UITextView * nicktext = (UITextView *)  [self.view subviewWithTag:1];
    nicktext.delegate = self;
    nicktext.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_signature];
    UILabel * label_num = (UILabel *)  [self.view subviewWithTag:2];
    label_num.text = [NSString stringWithFormat:@"%d",nicktext.text.length];
    [nicktext becomeFirstResponder];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{
    UITextView * nicktext = (UITextView *)  [self.view subviewWithTag:1];
    if (![nicktext.text isNilOrEmpty]) {
        if (nicktext.text.length > 1000) {
            return;
        }
        [SVProgressHUD show];
        //        if ([nicktext.text isEqualToString:[USER_DEFAULT stringForKey:<#(NSString *)#>]]) {}
        NSDictionary * parames = @{@"signature":nicktext.text};
        //nick, signature,sex, birthday, marriage, height
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
            [SVProgressHUD dismiss];
            [USER_DEFAULT setObject:nicktext.text forKey:KeyChain_Laixin_account_user_signature];
            [USER_DEFAULT synchronize];
            [self  dismissThisNavi:nil];

        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  // return NO to not change text
{
    if (textView.text.length > 1115) {
        return NO;
    }
    UILabel * label_num = (UILabel *)  [self.view subviewWithTag:2];
    
    if (textView.text.length > 1000) {
        label_num.textColor = [UIColor redColor];
        label_num.text = [NSString stringWithFormat:@"-%d",textView.text.length - 1000];
    }else{
        label_num.textColor = [UIColor lightGrayColor];
        label_num.text = [NSString stringWithFormat:@"%d",textView.text.length];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
