//
//  XCJRecommendLSFriendViewcontr.m
//  laixin
//
//  Created by apple on 2/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJRecommendLSFriendViewcontr.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"


@interface XCJRecommendLSFriendViewcontr ()
@property (weak, nonatomic) IBOutlet UILabel *text_nick;
@property (weak, nonatomic) IBOutlet UILabel *text_age;
@property (weak, nonatomic) IBOutlet UILabel *text_address;
@property (weak, nonatomic) IBOutlet UILabel *text_laixinID;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end

@implementation XCJRecommendLSFriendViewcontr

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(SureSendPutMMClick:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.button sendMessageStyle];
}

-(IBAction)SureSendPutMMClick:(id)sender
{
    
}
- (IBAction)addphotoClick:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SLog(@" %d  %d",indexPath.section,indexPath.row);
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 1) {
                //更改昵称
                UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入妹妹的名称或昵称:"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
                
                
                prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [prompt textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeDefault;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;

                prompt.tag = 1; // change name or nick
                [prompt show];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                //性别
            }else
            if (indexPath.row == 1) {
                //年龄
                UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"请输入妹妹的年龄:"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
                
                   prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [prompt textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeNumberPad;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;

                prompt.tag = 2; // change name or nick
                [prompt show];
            }else
            if (indexPath.row == 2) {
                //居住地
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                //联系方式
            }else if (indexPath.row == 1) {
                //详细资料
            }
            
        }
            break;
        case 3:
        {
            if (indexPath.row == 0) {
                //标签
                
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *tf = [alertView textFieldAtIndex:0];
    switch (alertView.tag) {
        case 1:
        {
             // NICK
            if (tf.text.length > 0) {
                self.text_nick.text = tf.text;
                self.text_nick.textColor = [tools colorWithIndex:0];
            }
        }
            break;
        case 2:
        {
            //AGE
            if (tf.text.length > 0) {
                int age = [tf.text intValue];
                if (age > 100) {
                    [UIAlertView showAlertViewWithMessage:@"你个老逼,这么老了还玩App 赶紧滚回去睡觉."];
                }else if(age < 18){
                    [UIAlertView showAlertViewWithMessage:@"你太小了,不适合用这么高档的App."];
                }else{
                    self.text_age.text = tf.text;
                    self.text_age.textColor = [tools colorWithIndex:0];
                }
                
            }
        }
            break;
            
        default:
            break;
    }
    
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
