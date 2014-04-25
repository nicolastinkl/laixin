//
//  UIImage+Addition.h
//
//  Created by Molon on 13-10-1.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addition)

//将根据所定尺寸，截取或放大图片，中间部位，多余的除去。
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

//拍照获取从相册选取照片会翻转。这个方法来修正
- (UIImage *)fixOrientation;
//返回图片的黑白灰色版本
- (UIImage*)grayImage;
@end
