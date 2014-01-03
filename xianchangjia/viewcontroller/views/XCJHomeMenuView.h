//
//  XCJHomeMenuView.h
//  laixin
//
//  Created by apple on 14-1-3.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCJHomeMenuViewDelegate <NSObject>

@required
- (void) hiddenSelfViewClick;

- (void) createGroupClick;

- (void) addFriendClick;

- (void) findandfindCodeClick;

@end


@interface XCJHomeMenuView : UIView
@property (nonatomic, weak) id<XCJHomeMenuViewDelegate> delegate;
@end
