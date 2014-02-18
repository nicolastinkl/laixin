//
//  SCJChooseSignOrDesViewControl.m
//  laixin
//
//  Created by apple on 2/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "SCJChooseSignOrDesViewControl.h"
#import "XCAlbumAdditions.h"
#import "AOTag.h" 
#import "UIButton+Bootstrap.h"
#define BUTTONCOLL  5

@interface SCJChooseSignOrDesViewControl ()<UITextViewDelegate,AOTagDelegate>
{
    NSMutableArray * labelArray;
}
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UILabel *labelnumber;
@property (weak, nonatomic) IBOutlet UITableViewCell *choosedCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *labelCell;
@property (retain) AOTagList *tag;
@end

@implementation SCJChooseSignOrDesViewControl

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

    self.title = @"描述和标签";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.choosedCell.height = 80.0f;
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(SureSendPutMMClick:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.textview.textColor = [UIColor lightGrayColor];
    
    
    self.tag = [[AOTagList alloc] initWithFrame:CGRectMake(0.0f,
                                                           7.0f,
                                                           320.0f,
                                                           70.0f)];
    
    [self.tag setDelegate:self];
    [self.choosedCell.contentView addSubview:self.tag];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
    //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString * strJson =  [dictionary valueForKey:@"mmLabel"];
    NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSArray * responseObject =[datajson  objectFromJSONData] ;

    labelArray = [NSMutableArray arrayWithArray:responseObject];
//    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    SLog(@"%@",[data CRC32]);
    __block float prewith;
    __block float preLeft;
    __block float row = 0;
    
    UIView * viewLabel = [self.labelCell.contentView subviewWithTag:1];
    if (responseObject && responseObject.count > 0) {
        [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * str = obj;
            float buttonWeidth = 36 + str.length*10;
            UIButton *iv;
            if ((prewith+buttonWeidth+preLeft+BUTTONCOLL) < 300) {
                iv = [[UIButton alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (30+BUTTONCOLL) * row, buttonWeidth, 30)];
            }else{
                row ++;
                preLeft = 0;
                prewith = 0;
                iv = [[UIButton alloc] initWithFrame:CGRectMake(prewith+preLeft+BUTTONCOLL, (30+BUTTONCOLL) * row, buttonWeidth, 30)];
            }
            prewith = buttonWeidth;
            preLeft = iv.left;
            [iv labelphotoStyle];
            [iv.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [iv setTitle:str forState:UIControlStateNormal];
            [iv addTarget:self action:@selector(selectTagClick:) forControlEvents:UIControlEventTouchUpInside];
            iv.tag = idx;
            [viewLabel addSubview:iv];
        }];
    }
}

-(void) fillDescription:(NSString * ) string withArray:(NSArray * ) array
{
    if (self.textview) {
        
        self.textview.text = string;
        self.labelnumber.textColor = [tools colorWithIndex:0];
        self.labelnumber.text = [NSString stringWithFormat:@"%d",self.textview.text.length];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


-(IBAction)selectTagClick:(id)sender
{
    
    UIButton * button =  (UIButton *) sender;
    if (button.backgroundColor == [UIColor lightGrayColor]) {
        //移除
        button.backgroundColor = [UIColor whiteColor];
        NSString * string = labelArray[button.tag];        
        if(self.tag.tags)
        {
            
            for (AOTag * tag in self.tag.tags) {
                if ([tag.tTitle isEqualToString:string]) {
                    [self.tag removeTag:tag];
                    break;
                }
            } 
        }
        
    }else{
        
        if(self.tag.tags.count >= 4){
            [UIAlertView showAlertViewWithMessage:@"最多添加4个标签,可以通过点击可删除已添加标签"];
        }else{
            //添加
            NSString * string = labelArray[button.tag];
            [self.tag  addTag:string];
            [button setBackgroundColor:[UIColor lightGrayColor]];
        }
        
    }
    
    
}

-(IBAction)SureSendPutMMClick:(id)sender
{
    
//    NSString * string = dict[@"description"];
//    NSArray * array = dict[@"labelArray"];
    if (self.tag.tags.count <=0) {
        if ( [self.textview isFirstResponder]) {
            [self.textview resignFirstResponder];
        }
        [UIAlertView showAlertViewWithMessage:@"请选择至少1个性标签"];
    }else{
        NSMutableArray * ar = [[NSMutableArray alloc] init];
        [self.tag.tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AOTag * tag = obj;
            [ar addObject:tag.tTitle];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLaixinDesLabel" object:@{@"description":self.textview.text,@"labelArray":ar}];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"一句话描述MM"]) {
        textView.text = @"";
        self.textview.textColor = [tools colorWithIndex:0];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length <= 100) {
        self.labelnumber.textColor = [tools colorWithIndex:0];
        self.labelnumber.text = [NSString stringWithFormat:@"%d",textView.text.length];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.labelnumber.textColor = [UIColor redColor];
        self.labelnumber.text = [NSString stringWithFormat:@"-%d",textView.text.length-100];

    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Tag delegate

- (void)tagDidAddTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been added", tag);
}

- (void)tagDidRemoveTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been removed", tag);
    int indextitle = [labelArray indexOfObject:tag.tTitle];
    UIView * viewLabel = [self.labelCell.contentView subviewWithTag:1];
    UIButton * button =  (UIButton *)viewLabel.subviews[indextitle];
    //移除
    button.backgroundColor = [UIColor whiteColor];
}

- (void)tagDidSelectTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been selected", tag);
}

#pragma mark - Tag delegate

- (void)tagDistantImageDidLoad:(AOTag *)tag
{
    NSLog(@"Distant image has been downloaded for tag > %@", tag);
}

- (void)tagDistantImageDidFailLoad:(AOTag *)tag withError:(NSError *)error
{
    NSLog(@"Distant image has failed to download > %@ for tag > %@", error, tag);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
