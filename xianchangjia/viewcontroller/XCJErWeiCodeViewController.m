//
//  XCJErWeiCodeViewController.m
//  laixin
//
//  Created by apple on 14-1-5.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJErWeiCodeViewController.h"
#import "XCAlbumAdditions.h"
#import "QRCodeGenerator.h"
#import "LXAPIController.h"
#import "FCHomeGroupMsg.h"
#import "Conversation.h"
#import "CoreData+MagicalRecord.h"

@interface XCJErWeiCodeViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *Image_erwei;
@property (weak, nonatomic) IBOutlet UILabel *label_nick;
@property (weak, nonatomic) IBOutlet UIImageView *Image_user;
@property (weak, nonatomic) IBOutlet UILabel *label_textContent;

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
    
    if (self.gid) {
        //group info        
//        conversation.facebookId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
        self.label_textContent.text = @"扫一扫上面二维码,加入群组";
       
        NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"facebookId == %@",[NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,self.gid]];
        Conversation * fchomeg = [Conversation MR_findFirstWithPredicate:preCMD];
        if (fchomeg) {
//            NSString * newCode = [NSString stringWithFormat:@"[group]-%@",fchomeg.facebookName];
//            self.Image_erwei.image = [QRCodeGenerator qrImageForString:newCode imageSize:216.0f];
            self.label_nick.text = fchomeg.facebookName;
        }else{
            NSPredicate * preCMDTwo = [NSPredicate predicateWithFormat:@"gid == %@", self.gid];
            FCHomeGroupMsg * mesage = [FCHomeGroupMsg MR_findFirstWithPredicate:preCMDTwo];

            self.label_nick.text = mesage.gName;
        }
        NSString * newCode = [NSString stringWithFormat:@"[group]-%@",self.gid];
        self.Image_erwei.image = [QRCodeGenerator qrImageForString:newCode imageSize:216.0f];
         [self.Image_user setImage:[UIImage imageNamed:@"sticker_placeholder_list"]];
    }else{
        //user info
        // Do any additional setup after loading the view.
        NSString * nick = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
        if ([nick isNilOrEmpty]) {
            nick = [LXAPIController sharedLXAPIController].currentUser.nick;
        }
       
        NSString * newCode = [NSString stringWithFormat:@"[user]-%@",nick];
        self.Image_erwei.image = [QRCodeGenerator qrImageForString:newCode imageSize:216.0f];
        //    [self.Image_erwei setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://qr.liantu.com/api.php?text=%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick]]]];
        self.label_nick.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
        [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]]];
        
    }
    
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
