//
//  POHorizontalList.h
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "POHorizontalListDelegate.h"

#define DISTANCE_BETWEEN_ITEMS  9.0
#define LEFT_PADDING            9.0
#define ITEM_WIDTH              135.0
#define TITLE_HEIGHT            40.0
#define TITLE_jianxi            2.5

@interface POHorizontalList : UIView <UIScrollViewDelegate> {
    CGFloat scale;
}

@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, assign) id<POHorizontalListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSMutableArray *)items;
- (id)initWithFrame:(CGRect)frame  items:(NSMutableArray *)items;
@end
