//
//  XCJContentTypesCell.h
//  laixin
//
//  Created by apple on 4/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCJGroupPost_list.h"

@interface XCJContentTypesCell : UITableViewCell


/**
 *  是否已经完成加载图片
 */
@property (nonatomic, assign) BOOL isloadingphotos;

#pragma mark - Initialization

/**
 *   Initializes a message cell and returns it to the caller.
 *
 *  @param Postlist        data
 *  @param reuseIdentifier reuse
 *
 *  @return id
 */
- (void)initWithContentMessage:(XCJGroupPost_list*)Postlist;


#pragma mark - Class methods

/**
 *  Computes and returns the minimum necessary height of a `XCJContentTypesCell` needed to display its contents.
 *
 *  @param message   An object that conforms to the `JSMessageData` protocol to display in the cell.
 *  @param hasAvatar A boolean value indicating whether or not the cell has an avatar.
 *
 *  @return The height required for the frame of the cell in order for the cell to display the entire contents of its subviews.
 */
+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(XCJGroupPost_list *) Postlist;

@end
