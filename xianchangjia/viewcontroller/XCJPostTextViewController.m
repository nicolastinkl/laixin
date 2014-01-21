//
//  XCJPostTextViewController.m
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJPostTextViewController.h"

#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "BaseDetailViewController.h"
#import "XCJGroupPost_list.h"


@interface XCJPostTextViewController ()<UITextViewDelegate>

@end

@implementation XCJPostTextViewController
@synthesize needRefreshViewController= _needRefreshViewController;

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
        if (nicktext.text.length > 10000) {
            return;
        }
        [nicktext resignFirstResponder];
        [SVProgressHUD show];
        
        //if ([nicktext.text isEqualToString:[USER_DEFAULT stringForKey:<#(NSString *)#>]]) {}
        
        NSDictionary * parames = @{@"gid":self.gID,@"content":nicktext.text};
        //nick, signature,sex, birthday, marriage, height
        [[MLNetworkingManager sharedManager] sendWithAction:@"post.add"  parameters:parames success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                NSDictionary * result = responseObject[@"result"];
                [SVProgressHUD dismiss];
                NSString *postID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                XCJGroupPost_list *glist = [[XCJGroupPost_list alloc] init];
                glist.postid = postID;
                glist.imageURL = @"";
                glist.content = nicktext.text;
                glist.uid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id];
                glist.ilike = NO;
                glist.like = 0;
                glist.replycount = 0;
                glist.group_id = self.gID;
                glist.time = [NSDate timeIntervalSinceReferenceDate];// [[NSDate date] timeIntervalSinceNow];
                
                [_needRefreshViewController.activities insertObject:glist atIndex:0];
                [_needRefreshViewController.cellHeights insertObject:@0 atIndex:0];
                [_needRefreshViewController reloadSingleActivityRowOfTableView:0 withAnimation:YES];
                
                [self  dismissThisNavi:nil];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"发送失败"];
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    SLog(@"Length : %d",textView.text.length);
    UILabel * label_num = (UILabel *)  [self.view subviewWithTag:2];
    
    if (textView.text.length > 10000) {
        label_num.textColor = [UIColor redColor];
        label_num.text = [NSString stringWithFormat:@"-%d",textView.text.length - 10000];
    }else{
        label_num.textColor = [UIColor lightGrayColor];
        label_num.text = [NSString stringWithFormat:@"%d",textView.text.length];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  // return NO to not change text
{
    if (textView.text.length > 10000) {
        return NO;
    }
  
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end