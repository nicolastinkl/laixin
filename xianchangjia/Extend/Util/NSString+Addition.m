//
//  NSString+Addition.m
//
//  Created by Molon on 13-11-12.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "NSString+Addition.h"

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
