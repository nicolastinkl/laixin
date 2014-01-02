//
//  NSString+Addition.m
//
//  Created by Molon on 13-11-12.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "NSString+Addition.h"




int getIndex (char ch);
BOOL isNumber (char ch);

@implementation NSString (Addition)

+ (BOOL)IsNilOrEmpty:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    
	if (str == nil) {
		return YES;
	}
	
	NSMutableString *string = [[NSMutableString alloc] init];
	[string setString:str];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)string);
	if([string length] == 0)
	{
		return YES;
	}
	return NO;
}

- (BOOL)isNilOrEmpty
{
    return [NSString IsNilOrEmpty:self];
}



int getIndex (char ch) {
    if ((ch >= '0'&& ch <= '9')||(ch >= 'a'&& ch <= 'z')||
        (ch >= 'A' && ch <= 'Z')|| ch == '_') {
        return 0;
    }
    if (ch == '@') {
        return 1;
    }
    if (ch == '.') {
        return 2;
    }
    return -1;
}

BOOL isNumber (char ch)
{
    if (!(ch >= '0' && ch <= '9')) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL) isValidPhone
{
    NSString * value = self;
    const char *cvalue = [value UTF8String];
    int len = strlen(cvalue);
    if (len != 11) {
        return FALSE;
    }
    if (![self isValidNumber:value])
    {
        return FALSE;
    }
    NSString *preString = [[NSString stringWithFormat:@"%@",value] substringToIndex:2];
    if ([preString isEqualToString:@"13"] ||
        [preString isEqualToString: @"15"] ||
        [preString isEqualToString: @"18"])
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
    return TRUE;
}

- (BOOL) isValidNumber:(NSString*)value{
    const char *cvalue = [value UTF8String];
    int len = strlen(cvalue);
    for (int i = 0; i < len; i++) {
        if(!isNumber(cvalue[i])){
            return FALSE;
        }
    }
    return TRUE;
}



/**
 * 计算字符串使用指定宽度和指定字体的情况下所使用的高度
 * @return CGFloat 字符串的高度
 */
- (CGFloat)heightForWidth:(CGFloat)width
                     font:(UIFont *)font {
    CGSize textSize = {0, 0};
    if (![NSString IsNilOrEmpty:self]){
        textSize = [self sizeWithFont:font
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
    return textSize.height;
}

- (CGFloat)realWidthForWidth:(CGFloat)width
                        font:(UIFont *)font {
    CGSize textSize = {0, 0};
    if (![NSString IsNilOrEmpty:self]){
        textSize = [self sizeWithFont:font
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByTruncatingTail];
    }
    return textSize.width;
}


//- (NSString *)htmlEncode{
//    NSString *str = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
//    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
//    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
//    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    str = [str stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
//    return str;
//}
//
//- (NSString *)htmlDecode{
//    NSString *str = [self stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//    str = [str stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    str = [str stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//    str = [str stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//    str = [str stringByReplacingOccurrencesOfString:@"<BR>" withString:@"\n"];
//    str = [str stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
//    str = [str stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
//    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
//    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
//    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
//    str = [str stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"\""];
//    str = [str stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"\""];
//    str = [str stringByReplacingOccurrencesOfString:@"&lsquo;" withString:@"'"];
//    str = [str stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"'"];
//    return str;
//}

//- (CGFloat)heightForWidth:(CGFloat)width
//                     font:(UIFont *)font {
//    CGSize textSize = {0, 0};
//    if (![NSString IsNilOrEmpty:self]){
//        textSize = [self sizeWithFont:font
//                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
//                        lineBreakMode:NSLineBreakByWordWrapping];
//    }
//    return textSize.height;
//}
//
//- (CGFloat)realWidthForWidth:(CGFloat)width
//                        font:(UIFont *)font {
//    CGSize textSize = {0, 0};
//    if (![NSString IsNilOrEmpty:self]){
//        textSize = [self sizeWithFont:font
//                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
//                        lineBreakMode:NSLineBreakByTruncatingTail];
//    }
//    return textSize.width;
//}

@end
