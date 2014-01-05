//
//  XCJErWeiCodeViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJErWeiCodeViewController.h"
#import "XCAlbumAdditions.h"

@interface XCJErWeiCodeViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *Image_erwei;
@property (weak, nonatomic) IBOutlet UILabel *label_nick;
@property (weak, nonatomic) IBOutlet UIImageView *Image_user;

@end

@implementation XCJErWeiCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)ShowMoreClick:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存二维码到手机", nil];
    [sheet showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.Image_erwei setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://qr.liantu.com/api.php?text=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]]]];
    self.label_nick.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
    [self.Image_user setImageWithURL:[NSURL URLWithString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic]]];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // save photo to local
        if (self.Image_erwei.image) {
            
            UIImageWriteToSavedPhotosAlbum(self.Image_erwei.image, nil, nil, nil);
            
//            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"myErweiCode.jpg"];
//            NSData *webData = UIImageJPEGRepresentation(self.Image_erwei.image , 1);
//            [webData writeToFile:filePath atomically:YES];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
