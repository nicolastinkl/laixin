//
//  XCJContentTypesCell.m
//  laixin
//
//  Created by apple on 4/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJContentTypesCell.h"

@implementation XCJContentTypesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initWithContentMessage:(XCJGroupPost_list*)Postlist
{
    
}
 
+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(XCJGroupPost_list *) Postlist
{
    return 0.0f;
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

@end
