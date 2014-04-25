//
//  TKParallaxCell.m
//  laixin
//
//  Created by tinkl on 23/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "TKParallaxCell.h"


@implementation TKParallaxCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    if (view) {
        CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
        
        float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
        float difference = CGRectGetHeight(self.parallaxImage.frame) - CGRectGetHeight(self.frame);
        float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
        
        CGRect imageRect = self.parallaxImage.frame;
        imageRect.origin.y = -(difference/2)+move; 
        self.parallaxImage.frame = imageRect;
    }
   
}

@end
