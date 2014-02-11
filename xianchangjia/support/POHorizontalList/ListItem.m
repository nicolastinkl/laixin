//
//  ListItem.m
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import "ListItem.h"
#import "UIImageView+AFNetworking.h"
#import "tools.h"

@implementation ListItem

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.image = image;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[UIColor lightGrayColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        
        UILabel *title = [[UILabel alloc] init];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setFont:[UIFont boldSystemFontOfSize:12.0]];
        [title setOpaque: NO];
        [title setText:imageTitle];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor darkGrayColor];
        imageRect = CGRectMake(0.0, 0.0, 75.0, 75.0);
        textRect = CGRectMake(0.0, imageRect.origin.y + imageRect.size.height + 5.0, 80.0, 20.0);
        
        [title setFrame:textRect];
        [imageView setFrame:imageRect];
        
        [self addSubview:title];
        [self addSubview:imageView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame imageUrl:(NSString *)image nick:(NSString *)imageTitle uid:(NSString * ) uid
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.imageurl = image;
        self.uid = uid;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:image Size:160]] placeholderImage:[UIImage imageNamed:@"sticker_placeholder_list"]];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[UIColor lightGrayColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        
        UILabel *title = [[UILabel alloc] init];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setFont:[UIFont boldSystemFontOfSize:12.0]];
        [title setOpaque: NO];
        [title setText:imageTitle];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor darkGrayColor];
        imageRect = CGRectMake(0.0, 0.0, 75.0, 75.0);
        textRect = CGRectMake(0.0, imageRect.origin.y + imageRect.size.height + 0.0, 80.0, 20.0);
        
        [title setFrame:textRect];
        [imageView setFrame:imageRect];
        
        [self addSubview:title];
        [self addSubview:imageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageUrl:(NSString *)imageurl
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageurl = imageurl;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:imageurl Size:200]] placeholderImage:[UIImage imageNamed:@"sticker_placeholder_list"]];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:1.0];
        [roundCorner setBorderColor:[UIColor lightGrayColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        
        imageRect = CGRectMake(0.0, 0.0, 75.0, 75.0);
        [imageView setFrame:imageRect];
        
        [self addSubview:imageView];
    }
    return self;
}


@end
