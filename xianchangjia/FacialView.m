//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"
#import "UIView+Additon.h"
@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        faces = @[@"sticker_126361874215276",
                  @"sticker_126361884215275",
                  @"sticker_126361890881941",
                  @"sticker_126361900881940",
                  @"sticker_126361910881939",
                  @"sticker_126361920881938",
                  @"sticker_126361957548601",
                  @"sticker_126361967548600",
                  @"sticker_126361974215266",
                  @"sticker_126361987548598",
                  @"sticker_126361994215264",
                  @"sticker_126362007548596",
                  @"sticker_126362027548594",
                  @"sticker_126362034215260",
                  @"sticker_126362044215259",
                  @"sticker_126362064215257",
                  @"sticker_126362074215256",
                  @"sticker_126362080881922",
                  @"sticker_126362087548588",
                  @"sticker_126362100881920",
                  @"sticker_126362107548586",
                  @"sticker_126362117548585",
                  @"sticker_126362124215251",
                  @"sticker_126362130881917",
                  @"sticker_126362137548583",
                  @"sticker_126362160881914",
                  @"sticker_126362167548580",
                  @"sticker_126362180881912",
                  @"sticker_126362187548578",
                  @"sticker_126362230881907",
                  @"sticker_126362207548576",
                  @"sticker_126362197548577"];
    }
    return self;
}

-(void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
	for (int i=0; i<2; i++) {
		//column numer
		for (int y=0; y<4; y++) {
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(10+y*size.width,10+i*size.height,64, 64)];
            [button setImage:[UIImage imageNamed:faces[i + y*2 +(page*8)]] forState:UIControlStateNormal];
            button.tag = i + y*2 +(page*8);
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
//            button.top = 10;
//            button.left = 10;
		}
	}
}


-(void)selected:(UIButton*)bt
{
    NSString *str=[faces objectAtIndex:bt.tag];
    [delegate selectedFacialView:str];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/ 
@end
