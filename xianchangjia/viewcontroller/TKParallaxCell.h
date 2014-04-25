//
//  TKParallaxCell.h
//  laixin
//
//  Created by tinkl on 23/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAImageResizedImageView.h"

@interface TKParallaxCell : UITableViewCell

@property (strong, nonatomic) IBOutlet DAImageResizedImageView *parallaxImage;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
