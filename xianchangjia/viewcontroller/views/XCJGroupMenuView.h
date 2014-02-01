//
//  XCJGroupMenuView.h
//  laixin
//
//  Created by apple on 14-1-10.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol XCJGroupMenuViewDelegate <NSObject>

@required
- (void) hiddenSelfViewClick;
/**
 *  添加成员
 */
- (void) addFriendClick;

/**
 *  查看成员
 */
- (void) findandfindCodeClick;

/**
 *  静音
 */
- (void) MuteMusicClick;

/**
 *  更多
 */
- (void) moreClick;


@end


@interface XCJGroupMenuView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *muteImageview;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (nonatomic, weak) id<XCJGroupMenuViewDelegate> delegate;
@end
