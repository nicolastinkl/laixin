//
//  XCJSeeJiuShuiViewController.h
//  laixin
//
//  Created by apple on 3/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKSTableView.h"
#import "Model.h"

@interface JiuSInfo : Model
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSArray * list;
@end


@interface JiuSInfoSub : Model
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * price;
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSString * other;
@property (nonatomic,strong) NSString * unit;

@end



@interface XCJSeeJiuShuiViewController : UIViewController<SKSTableViewDelegate>

@property (nonatomic, weak) IBOutlet SKSTableView *tableView;

@end
