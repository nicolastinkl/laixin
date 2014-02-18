//
//  XCJFindMMView.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJFindMMView.h"
#import "XCAlbumAdditions.h"

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
    self.label_des.textColor = [tools colorWithIndex:0];
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
        self.label_like = 0;
    }
    
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
