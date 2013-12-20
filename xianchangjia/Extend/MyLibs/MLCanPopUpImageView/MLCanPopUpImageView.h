//
//  MLCanPopUpImageView.h
//  RefreshTable
//
//  Created by Molon on 13-11-13.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  此ImageView只有从AspectFill到AspectFit全屏的一种模式。
 *  请避免对其设置contentMode
 */
@interface MLCanPopUpImageView : UIImageView

@property (nonatomic,strong) NSURL *fullScreenImageURL;
@property (nonatomic,assign,getter = getFullScreenAnimationDuration) CGFloat fullScreenAnimationDuration;

@end
