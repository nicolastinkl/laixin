//
//  SJAvatarBrowser.h
//  laixin
//
//  Created by apple on 14-2-12.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJAvatarBrowser : NSObject
/**
 *	@brief	浏览头像
 *
 *	@param 	oldImageView 	头像所在的imageView
 */
+(void)showImage:(UIImageView*)avatarImageView withURL:(NSString *) url;

/*!
 *  显示二维码
 *
 *  @param holdimageview <#holdimageview description#>
 *
 *  @since <#version number#>
 */
+(void)showImage:(UIImageView*)holdimageview;

@end
