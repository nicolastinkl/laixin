//
//  XCJChatMessageCell.h
//  laixin
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemoteImgListOperator;
@class FCMessage,Conversation;
@interface XCJChatMessageCell : UITableViewCell
@property (nonatomic, readonly) RemoteImgListOperator *m_objRemoteImgListOper;
- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper;
- (void) SendMessageRemoteImgOper:(RemoteImgListOperator *)objOper WithMessage:(NSMutableDictionary *) dict type:(int) type;

@property (nonatomic,strong) FCMessage * currentMessage;
@property (nonatomic,strong) Conversation * conversation;
@end
