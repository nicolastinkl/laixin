//
//  XCJChatSendInfoView.h
//  laixin
//
//  Created by apple on 14-1-25.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XCJChatSendInfoViewDelegate <NSObject>

@required
- (void)takePhotoClick;
- (void)choseFromGalleryClick;
- (void)choseLocationClick;
- (void)sendMyfriendsClick;
- (void)moreClick;


@end


@interface XCJChatSendInfoView : UIView
@property (nonatomic, weak) id<XCJChatSendInfoViewDelegate> delegate;
@end
