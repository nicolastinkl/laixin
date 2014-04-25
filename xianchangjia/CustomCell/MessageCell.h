//
//  MessageCell.h
//  ISClone
//
//  Created by Molon on 13-12-6.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;
@interface MessageCell : UITableViewCell

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) BOOL isDisplayOnlyContent;

@end
