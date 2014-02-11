//
//  ListItem.h
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ListItem : UIView {
    CGRect textRect;
    CGRect imageRect;
}

@property (nonatomic, retain) NSObject *objectTag;

@property (nonatomic, retain) NSString *imageTitle;

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) NSString *imageurl;
@property (nonatomic, retain) NSString *uid;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle;

- (id)initWithFrame:(CGRect)frame imageUrl:(NSString *)image nick:(NSString *)imageTitle uid:(NSString * ) uid;

- (id)initWithFrame:(CGRect)frame imageUrl:(NSString *)imageurl ;
@end
