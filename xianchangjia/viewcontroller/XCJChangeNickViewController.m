//
//  XCJChangeNickViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJChangeNickViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"


@interface XCJChangeNickViewController ()<UITextFieldDelegate>

@end

@implementation XCJChangeNickViewController

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
    UITextField * nicktext = (UITextField *)  [self.view subviewWithTag:1];
    nicktext.delegate = self;
    [nicktext becomeFirstResponder];
    nicktext.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
}


-(IBAction)dismissThisNavi:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)saveAndUpload:(id)sender
{
    UITextField * nicktext = (UITextField *)  [self.view subviewWithTag:1];
    if (![nicktext.text isNilOrEmpty]) {
//        if ([nicktext.text isEqualToString:[USER_DEFAULT stringForKey:<#(NSString *)#>]]) {}
        NSDictionary * parames = @{@"nick":nicktext.text};
        //nick, signature,sex, birthday, marriage, height
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.update"  parameters:parames success:^(MLRequest *request, id responseObject) {
            
            [USER_DEFAULT setObject:nicktext.text forKey:KeyChain_Laixin_account_user_nick];
            [USER_DEFAULT synchronize];
            [self  dismissThisNavi:nil];
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
    if (textField.text.length > 15) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
