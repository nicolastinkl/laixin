//
//  XCJFindMMView.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJFindMMView.h"
#import "XCAlbumAdditions.h"
#define  BUTTONCOLL 2
@implementation XCJFindMMView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setupThisData:(XCJFindMM_list*) findmmData
{
    self.label_des.textColor = [UIColor grayColor];//[tools colorWithIndex:0];
    self.label_like.textColor = [tools colorWithIndex:0];
    
    self.label_des.text  = findmmData.recommend_word;
    
    if (findmmData.age.length > 0) {
        self.label_age.text = findmmData.age;
        float buttonWeidth = 36 + findmmData.age.length*10;
        [self.label_age setWidth:buttonWeidth];
        int colorindex = arc4random()%7;
        [self.label_age setBackgroundColor:[tools colorWithIndex:colorindex]];
    }else{
         self.label_age.text = @"";
        [self.label_age setBackgroundColor:[UIColor clearColor]];
    }
    
    if (findmmData.like_count > 0) {
        self.label_like.text = [NSString stringWithFormat:@"%d",findmmData.like_count];
    }else{
        self.label_like.text = @"0";
    }
    
    //self.view_label
    __block float prewith;
    __block float preLeft;
    __block float row = 0;
    [findmmData.labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
