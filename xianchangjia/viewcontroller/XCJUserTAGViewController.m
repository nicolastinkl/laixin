//
//  XCJUserTAGViewController.m
//  laixin
//
//  Created by apple on 3/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJUserTAGViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"

@interface XCJUserTAGViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

@end

@implementation XCJUserTAGViewController

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
    
    self.title = @"设置个性标签";
    
    self.hidesBottomBarWhenPushed = YES;
    
    UILabel * label =  (UILabel * ) [self.view subviewWithTag:1];
    [label setText:self.tags];
    int colorindex = arc4random() % 6 + 1 ;

    if (colorindex > 7) {
        colorindex = 6;
    }
    
    UITextView * textview =  (UITextView * ) [self.view subviewWithTag:5];
    if (IS_4_INCH)
        [textview setHeight:250.0f];
    else
        [textview setHeight:150.0f];
    
    
    UIImageView * imview =  (UIImageView * ) [self.view subviewWithTag:3];
    imview.layer.cornerRadius = 5;
    imview.layer.masksToBounds = YES;
    imview.image = [UIImage imageNamed:[NSString stringWithFormat:@"med-name-bg-%d",colorindex]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(SeetingsClick:)];
    
    if ([self.tags isEqualToString:@"小萝莉"]) {
        textview.text = @"性格活泼开朗、天真可爱又很爱帮助别人，别看年龄已经不小了，脑子却根本没有进化，上高中的孩子却爱踩着喜欢的人的影子走路，二十多岁时还用名字做自称，在小萝莉心里，永远相信这个世界是美好的，永远相信自己爱的人也是爱自己的，她们不想多想，因为她们不想去恨别人，因为这样她们会失去她们的快乐，她们不想长大，因为相信长大了自己就不会被爱着了，即使有痛,她们也会忍着,也会在自己爱的人面前强颜欢笑,她们不想自己爱的人为她们担心,真正难能可贵的就是小萝莉们金子般的心 。";
    }else if ([self.tags isEqualToString:@"少女时代"]) {
        textview.text = @"突出都市气息，凸现新鲜亮丽的城市少女、海派少女的气质与风格";
    }else if ([self.tags isEqualToString:@"豆蔻年华"]) {
        textview.text = @"无";
    }else if ([self.tags isEqualToString:@"青春无敌"]) {
        textview.text = @"无";
    }else if ([self.tags isEqualToString:@"学生妹"]) {
        textview.text = @"无";
    }else if ([self.tags isEqualToString:@"童颜巨乳"]) {
        textview.text = @"长着幼小天真的童真面貌，却有着成熟女人望尘莫及的巨大乳房;童颜巨乳目前具有“国家”级的热度。她们是媒体以及商界的宠儿，引起“国家”级单位的批判，成为全民茶余饭后的谈资。她们引发各种讨论：有人说“国家”介入的方式不妥；有人说美少女被物化；有人说巨乳美少女不美又不健康自然，必然被时代潮流淘汰。";
    }else if ([self.tags isEqualToString:@"含苞待放"]) {
        textview.text = @"";
    }else if ([self.tags isEqualToString:@"少有韵味"]) {
        textview.text = @"成熟女人的韵味在于：情韵上，把握男人的脉搏；神韵上；潜入男人的灵魂；意韵上，走进男人的心灵深处。+成熟女人的韵味在于：名声上，看得淡；情感上，看得开；仕途上，看得清；钱财上，看得透。+成熟女人的韵味在于：把握自己的健康，把握自己的心态，把握自己的生活，把握自己的命脉。";
    }else if ([self.tags isEqualToString:@"破瓜之年"]) {
        textview.text = @"出 处 宋·陆游《无题》诗：“碧玉当年未破瓜，学成歌舞入侯家。”";
    }else if ([self.tags isEqualToString:@"碧玉年华"]) {
        textview.text = @"无";
    }else if ([self.tags isEqualToString:@"桃李年华"]) {
        textview.text = @"无";
    }else if ([self.tags isEqualToString:@"花信年华"]) {
        textview.text = @"无";
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     [self.navigationController popViewControllerAnimated:YES];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [SVProgressHUD showWithStatus:@"正在处理中..."];
        
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.update" parameters:@{@"tags":@[self.tags]} success:^(MLRequest *request, id responseObject) {
            if (responseObject) {
                [SVProgressHUD dismiss];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"设置成功" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        } failure:^(MLRequest *request, NSError *error) {
            [SVProgressHUD dismiss];
            [UIAlertView showAlertViewWithMessage:@"设置失败,请重试"];
        }];

    }
}
-(IBAction)SeetingsClick:(id)sender
{
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确定设置标签后将不可修改" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定设置" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
