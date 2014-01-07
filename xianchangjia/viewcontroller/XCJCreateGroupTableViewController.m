//
//  XCJCreateGroupTableViewController.m
//  laixin
//
//  Created by apple on 14-1-3.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJCreateGroupTableViewController.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "NSString+Addition.h"
#import "DataHelper.h"
#import "XCJGroupPost_list.h"
#import "UIAlertViewAddition.h"
#import "HZAreaPickerView.h"

@interface XCJCreateGroupTableViewController ()<HZAreaPickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *GroupName;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) NSString *areaValue, *cityValue;
@property (weak, nonatomic) IBOutlet UITextField *Label_address;
@property (weak, nonatomic) IBOutlet UITextField *textType;
@end

@implementation XCJCreateGroupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)cancelClick:(id)sender {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XCJSelectCroupTypeViewController" object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)SelectClick:(id)sender {
    [self selectAddress:nil];
}

- (void) cancel
{
    [self cancelLocatePicker];
}

- (void) complate
{
    [self cancelLocatePicker];
}

-(void)setAreaValue:(NSString *)areaValue
{
    if (![_areaValue isEqualToString:areaValue]) {
        self.Label_address.text = areaValue;
    }
}

- (IBAction)ComplateClick:(id)sender {
    /**
     *  16 group.create(name,board,type) 创建群
     Result={“gid”:1}
     */
    if ([self.GroupName.text isNilOrEmpty]) {
        return;
    }
    // self.textType.text
    NSDictionary * parames = @{@"name":self.GroupName.text ,@"board":self.Label_address.text,@"type":@1};
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.create"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //Result={“gid”:1}
        if (responseObject) {
            NSDictionary * dict =  responseObject[@"result"];
            NSString * gid =  [DataHelper getStringValue:dict[@"gid"] defaultValue:@""];
            XCJGroup_list * list = [[XCJGroup_list alloc] init];
            list.gid = gid;
            list.group_name = self.GroupName.text;
            list.group_board = @"";
            list.type  = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_changeDomainID" object:list];
            [self cancelClick:nil];
        }
    } failure:^(MLRequest *request, NSError *error) {
        [UIAlertView showAlertViewWithMessage:@"创建失败"];
    }];
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    if (picker.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        self.areaValue = [NSString stringWithFormat:@"%@ %@ %@", picker.locate.state, picker.locate.city, picker.locate.district];
    }
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
}

- (IBAction)selectAddress:(id)sender
{
    self.locatePicker = [[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCityAndDistrict delegate:self];
    [self.locatePicker showInView:self.view];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XCJSelectCroupTypeViewControllerNotiy:) name:@"XCJSelectCroupTypeViewController" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
  
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
  
}


-(void) XCJSelectCroupTypeViewControllerNotiy:(NSNotification *) noty
{
     if(noty.object)
     {
         self.textType.text = [NSString stringWithFormat:@"%@",noty.object];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
