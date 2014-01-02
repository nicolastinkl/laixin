//
//  NSString+Addition.h
//
//  Created by Molon on 13-11-12.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Addition)

+ (BOOL)IsNilOrEmpty:(NSString *)str;

- (BOOL)isNilOrEmpty;

///
/// 判断是否是电话格式
///
- (BOOL) isValidPhone;



- (CGFloat)heightForWidth:(CGFloat)width
                     font:(UIFont *)font;

//用作只有一行文字的实际宽度
- (CGFloat)realWidthForWidth:(CGFloat)width
                        font:(UIFont *)font;


//- (NSString *)htmlEncode;
//- (NSString *)htmlDecode;

//- (CGFloat)heightForWidth:(CGFloat)width
//                     font:(UIFont *)font;
//
////用作只有一行文字的实际宽度
//- (CGFloat)realWidthForWidth:(CGFloat)width
//                        font:(UIFont *)font;



@end
