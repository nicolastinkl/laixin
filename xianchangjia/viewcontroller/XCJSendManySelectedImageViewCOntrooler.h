//
//  XCJSendManySelectedImageViewCOntrooler.h
//  laixin
//
//  Created by apple on 14-2-12.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDetailViewController.h"

@interface XCJSendManySelectedImageViewCOntrooler : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextView *TextMsg;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic,strong) NSMutableArray * array;

@property (nonatomic,strong) NSString * gID;
@property (nonatomic,weak) BaseDetailViewController *needRefreshViewController;
@end
