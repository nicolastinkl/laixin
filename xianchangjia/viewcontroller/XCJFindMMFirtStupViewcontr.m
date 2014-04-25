//
//  XCJFindMMFirtStupViewcontr.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJFindMMFirtStupViewcontr.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "UIButton+AFNetworking.h" 
#import "UIImageView+Addtion.h"
#define BUTTONCOLL 3

@interface XCJFindMMFirtStupViewcontr ()
@property (weak, nonatomic) IBOutlet UIView *view_bg;
@property (weak, nonatomic) IBOutlet UIImageView *image_big;
@property (weak, nonatomic) IBOutlet UILabel *label_like;
@property (weak, nonatomic) IBOutlet UILabel *label_age;
@property (weak, nonatomic) IBOutlet UIView *view_label;
@property (weak, nonatomic) IBOutlet UIButton *button_Lists;
@property (weak, nonatomic) IBOutlet UILabel *label_pay;
@property (weak, nonatomic) IBOutlet UILabel *label_content;

@property (weak, nonatomic) IBOutlet UIButton *button_qiang;

@end

@implementation XCJFindMMFirtStupViewcontr

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
    
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"抢(1/3)";
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"抢一抢" style:UIBarButtonItemStyleDone target:self action:@selector(SureSendPutMMClick:)];
    self.navigationItem.rightBarButtonItem = item;
    [self.button_qiang infoStyle];
    
    self.label_content.textColor = [UIColor grayColor];//[tools colorWithIndex:0];
    self.label_like.textColor = [tools colorWithIndex:0];
    
    self.label_content.text  = self.data.recommend_word;
    float height = [self heightForCellWithPost:self.data.recommend_word];
    [self.label_content setHeight:height];
    [self.label_content sizeToFit];
    [self.label_content setWidth:290.0f];
    
    [self.tableView.tableHeaderView setHeight:(self.label_content.top + self.label_content.height + 5)];
    
    if (self.data.buy_count == 0) {
        self.label_pay.text = @"还没有被抢过";
    }else{
        self.label_pay.text = [NSString stringWithFormat:@"已被%d人抢过",self.data.buy_count];
    }
    
    self.label_pay.textColor =[tools colorWithIndex:0];
    //290
    if (self.data.age.length > 0) {
        self.label_age.text = self.data.age;
        float buttonWeidth = 36 + self.data.age.length*10;
        [self.label_age setWidth:buttonWeidth];
        int colorindex = arc4random()%7;
        [self.label_age setBackgroundColor:[tools colorWithIndex:colorindex]];
    }else{
        self.label_age.text = @"";
        [self.label_age setBackgroundColor:[UIColor clearColor]];
    }
    
    if (self.data.like_count > 0) {
        self.label_like.text = [NSString stringWithFormat:@"%d",self.data.like_count];
    }else{
        self.label_like.text = @"0";
    }
    self.view_bg.layer.cornerRadius = 4;
    self.view_bg.layer.masksToBounds = YES;

    //self.view_label
    __block float prewith;
    __block float preLeft;
    __block float row = 0;
    [self.data.labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * str = obj;
        float buttonWeidth = 25 + str.length*10;
        UILabel *iv;
        if ((prewith+buttonWeidth+preLeft+BUTTONCOLL) < 300) {
            iv = [[UILabel alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (20+BUTTONCOLL) * row, buttonWeidth, 20)];
        }else{
            row ++;
            preLeft = 0;
            prewith = 0;
            iv = [[UILabel alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (20+BUTTONCOLL) * row, buttonWeidth, 20)];
        }
        prewith = buttonWeidth;
        preLeft = iv.left;
        [iv setFont:[UIFont systemFontOfSize:14.0f]];
        [iv setTextColor:[UIColor whiteColor]];
        iv.text = str;
        iv.textAlignment = NSTextAlignmentCenter;
        int ramd =  arc4random() % 9;
        iv.backgroundColor = [tools colorWithIndex:ramd];
        
        [self.view_label addSubview:iv];
    }];
    
    
    //button_Lists
    
    [self.data.medias enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [self.image_big setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:obj Size:640]]];
        }
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake((50 + BUTTONCOLL)*idx + BUTTONCOLL, self.button_Lists.top, 50, 50)];
        [button setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[tools getUrlByImageUrl:obj Size:100]]];
        button.tag = idx;
        [button addTarget:self action:@selector(Changeimageurl:) forControlEvents:UIControlEventTouchUpInside];
        [self.view_bg addSubview:button];
    }];
}

-(IBAction)Changeimageurl:(id)sender
{
    UIButton * button = (UIButton*)sender;
    NSString *url = self.data.medias[button.tag];
    [self.image_big setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:url Size:320]] placeholderImage:[UIImage imageNamed:@"photo_browser_no_photo"] displayProgress:YES];
    
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(290.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(20.0f, sizeToFit.height + 10.0f );
}

-(IBAction)SureSendPutMMClick:(id)sender
{
    [UIAlertView showAlertViewWithMessage:@"抱歉,您的等级不够,不能抢她"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
