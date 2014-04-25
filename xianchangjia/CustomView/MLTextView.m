//
//  MLTextView.m
//  ISClone
//
//  Created by Molon on 13-12-6.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MLTextView.h"

@interface MLTextView ()

@property (strong, nonatomic) NSLayoutConstraint *descriptionHeightConstraint;

@end

@implementation MLTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Initialization code
        //高度的限制
        self.descriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:33];
        
        [self addConstraint:self.descriptionHeightConstraint];
        
    }
    return self;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//在contentSize变动的时候会调用此方法
-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    CGFloat height = self.contentSize.height;
    //最高60
    height = height>60?60:height;
    self.descriptionHeightConstraint.constant = height;
    [self setNeedsUpdateConstraints];
}

@end
