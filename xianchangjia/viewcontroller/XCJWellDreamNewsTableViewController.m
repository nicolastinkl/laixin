//
//  XCJWellDreamNewsTableViewController.m
//  laixin
//
//  Created by apple on 4/8/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJWellDreamNewsTableViewController.h"
#import "XCAlbumAdditions.h"
#import "XCJGroupPost_list.h"


#import <OHAttributedLabel/OHAttributedLabel.h>
#import <OHAttributedLabel/NSAttributedString+Attributes.h>
#import <OHAttributedLabel/OHASBasicMarkupParser.h>

#define kAttributedLabelTag 211

@interface XCJWellDreamNewsTableViewController ()<OHAttributedLabelDelegate,UIActionSheetDelegate>
{
    XCJGroup_list * currentGroup;
    NSString * CurrentUrl;
//    NSMutableAttributedString* currentmas;
}
@end

@implementation XCJWellDreamNewsTableViewController

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
    self.title = @"新闻";
//    [self showErrorText:@"敬请期待"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorInfoWithRetryNot:) name:showErrorInfoWithRetryNotifition  object:nil];
    
     [self.tableView reloadData];
    
//    [self reloadData];
}


-(void) reloadData
{
    [self.view showIndicatorViewLargeBlue];
    NSDictionary * paramess = @{@"gid":@[@"61"]};
    [[MLNetworkingManager sharedManager] sendWithAction:@"group.info"  parameters:paramess success:^(MLRequest *request, id responseObjects) {
        NSDictionary * groupsss = responseObjects[@"result"];
        NSArray * groupsDicts =  groupsss[@"groups"];
        [groupsDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0) {
                XCJGroup_list * list = [XCJGroup_list turnObject:obj];
                currentGroup = list;
            }
        }];
        
//        NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@",currentGroup.group_board]];
//        [mas setFont:[UIFont systemFontOfSize: 16.0f]];
//        [mas setTextColor:[UIColor blackColor]];
//        [mas setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping];
//        [OHASBasicMarkupParser processMarkupInAttributedString:mas];
//        currentmas = mas;
        [self.view hideIndicatorViewBlueOrGary];
        [self.tableView reloadData];
    } failure:^(MLRequest *request, NSError *error) {
        [self.view hideIndicatorViewBlueOrGary];
        [self showErrorInfoWithRetry];
    }];
}


-(void) showErrorInfoWithRetryNot:(NSNotification * ) notify
{
    [self hiddeErrorInfoWithRetry];
    // start retry
    
    [self reloadData];
}


#pragma mark - XLSwipeContainerItemDelegate

-(id)swipeContainerItemAssociatedSegmentedItem
{
    return @"新闻";
}

-(UIColor *)swipeContainerItemAssociatedColor
{
    return [UIColor whiteColor];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}


-(float) textHeight:(NSString *) text
{
    
//    NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:text];
//    [mas setFont:[UIFont systemFontOfSize: 16.0f]];
//    [mas setTextColor:[UIColor blackColor]];
//    [mas setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping];
//    [OHASBasicMarkupParser processMarkupInAttributedString:mas];
//    CGSize sizeToFit = [currentmas sizeConstrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX)];
//    return sizeToFit.height + 20;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.height + 15 );
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return APP_SCREEN_HEIGHT - 64;
    
    if (currentGroup)
    return  [self textHeight:currentGroup.group_board];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEWSCELL" forIndexPath:indexPath];
    
//    if (!currentGroup) {
//        return cell;
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    /*// Configure the cell...
    UILabel* labelContent = (UILabel*)[cell viewWithTag:kAttributedLabelTag];
    if (labelContent == nil) {
        labelContent = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        labelContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        labelContent.centerVertically = YES;
//        labelContent.automaticallyAddLinksForType = NSTextCheckingAllTypes;
//        labelContent.delegate = self;
        labelContent.highlightedTextColor = [UIColor whiteColor];
        labelContent.tag = kAttributedLabelTag;
        
        labelContent.numberOfLines  = 0;
        labelContent.lineBreakMode = NSLineBreakByCharWrapping;
        [cell addSubview:labelContent];
        //    labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
    }
  
    
//    labelContent.attributedText = currentmas;
      labelContent.text = currentGroup.group_board;
    [labelContent sizeToFit];
//    CGSize sizeToFit = [currentmas sizeConstrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX)];
    
    [labelContent setWidth:300.0f];
    [labelContent setHeight:[self textHeight:currentGroup.group_board]];
    [labelContent setTop:10.0f];
    [labelContent setLeft:10.0f];
    */
    
    {
        UITextView* labelContent = (UITextView*)[cell viewWithTag:1];
//        labelContent.text = currentGroup.group_board;
        labelContent.hidden = YES;
        labelContent.height = APP_SCREEN_HEIGHT - 64;
    }
    
    {
       UIWebView *webview = (UIWebView*)[cell viewWithTag:2];
       [ webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mp.weixin.qq.com/s?__biz=MjM5MDI0MzMxMw==&mid=200246465&idx=1&sn=76577eebb9c4a89e30f073e9e3267a4a"]]];
        webview.height = APP_SCREEN_HEIGHT - 64;
    }
   
    
    return cell;
}



/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Method
/////////////////////////////////////////////////////////////////////////////

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    
    //    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    //        return YES;
    //        else
    //        // Unsupported link type (especially phone links are not supported on Simulator, only on device)
    //        return NO;
    CurrentUrl =  [NSString stringWithFormat:@"%@",linkInfo.extendedURL];
    if (linkInfo.extendedURL ) {
        NSString * url = CurrentUrl;
        NSString * toastText;
        if ([url isHttpUrl]) {
            toastText = @"浏览器打开";
        }else if([url isValidPhone])
        {
            toastText = @"电话打开";
        }else{
            toastText = url;
        }
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消 " destructiveButtonTitle:@"复制" otherButtonTitles:toastText, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }else{
        NSAttributedString * newStr = [attributedLabel.attributedText  attributedSubstringFromRange:linkInfo.range];
        CurrentUrl = newStr.string;
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制" otherButtonTitles:nil, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }
    
    return NO;
}


#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:[NSString stringWithFormat:@"%@",CurrentUrl]];
    }else if(buttonIndex == 1)
    {
        NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (![ title  isEqualToString:@"取消"]) {
            
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:CurrentUrl]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CurrentUrl]];
            }else{
                [UIAlertView showAlertViewWithMessage:@"打开失败"];
            }
        }
        
    }
}

@end
