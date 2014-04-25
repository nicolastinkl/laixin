//
//  XCJSelectAgeModefilViewContr.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSelectAgeModefilViewContr.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#define BUTTONCOLL  10



@interface XCJSelectAgeModefilViewContr ()
{
    NSMutableArray * labelArray;
}
@end

@implementation XCJSelectAgeModefilViewContr

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
    
    self.title = @"选择年龄段";
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"aboutLaixinInfo" ofType:@"plist"];
    //    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString * strJson =  [dictionary valueForKey:@"ageDes"];
    NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
    NSArray * responseObject =[datajson  objectFromJSONData] ;
    __block float prewith;
    __block float preLeft;
    __block float row = 0;
    
    labelArray = [NSMutableArray arrayWithArray:responseObject];
    UIView * viewLabel = [self.view subviewWithTag:1];
    [viewLabel setTop:80];
    if (responseObject && responseObject.count > 0) {
        [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * str = obj;
            float buttonWeidth = 46 + str.length*10;
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
//            [iv labelphotoStyle];
            int ramd =  arc4random() % 9;
            iv.backgroundColor = [tools colorWithIndex:ramd];
            [iv setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];

            [iv.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
            [iv setTitle:str forState:UIControlStateNormal];
            [iv addTarget:self action:@selector(selectTagClick:) forControlEvents:UIControlEventTouchUpInside];
            iv.tag = idx;
            [viewLabel addSubview:iv];
        }];
    }
	// Do any additional setup after loading the view.
}



-(IBAction)selectTagClick:(id)sender
{
    
    UIButton * button =  (UIButton *) sender;
    NSString * string = labelArray[button.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLaixinAgaeDesLabel" object:string];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
