//
//  XCJUserInfoController.m
//  laixin
//
//  Created by apple on 13-12-31.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJUserInfoController.h"
#import "XCAlbumAdditions.h"
#import "FCFriends.h"
#import "FCUserDescription.h"

@interface XCJUserInfoController ()
@property (weak, nonatomic) IBOutlet UIImageView *Image_user;
@property (weak, nonatomic) IBOutlet UIImageView *Image_sex;
@property (weak, nonatomic) IBOutlet UILabel *Label_nick;
@property (weak, nonatomic) IBOutlet UIButton *Button_Sendmsg;
@property (weak, nonatomic) IBOutlet UIImageView *Image_btnBG;
@property (weak, nonatomic) IBOutlet UILabel *Label_sign;
@property (weak, nonatomic) IBOutlet UILabel *Label_address;

@end

@implementation XCJUserInfoController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.Label_nick.text  = self.frend.friendRelation.nick;
    self.Label_sign.text  = self.frend.friendRelation.signature;
    self.Label_address.text = @"成都";
    if ([self.frend.friendRelation.sex intValue] == 1) {
        self.Image_sex.image = [UIImage imageNamed:@"md_boy"];
    }else if ([self.frend.friendRelation.sex intValue] == 2) {
        self.Image_sex.image = [UIImage imageNamed:@"md_girl"];
    }
    
    [self.Image_user setImageWithURL:[NSURL URLWithString:[tools getStringValue:self.frend.friendRelation.headpic defaultValue:@""]]];
    
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnDown:) forControlEvents:UIControlEventTouchDown];
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.Button_Sendmsg addTarget:self action:@selector(touchBtnUpOut:) forControlEvents:UIControlEventTouchUpOutside];
    
}

-(IBAction)touchBtnUpOut:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_normal"]];
}

-(IBAction)touchBtnDown:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_highlighted"]];
}

-(IBAction)touchBtnUp:(id)sender
{
    [self.Image_btnBG setImage:[UIImage imageNamed:@"fbc_promobutton_28_2_5_2_5_normal"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
