//
//  NSStrinAddition.h
//  XianchangjiaAlbum
//
//  modify from Three20 by Tonny on 6/5/11.
//  Copyright 2012 SlowsLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Addition.h"
//#import <CoreLocation/CLLocation.h>

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

@property (nonatomic, readonly) NSString* md5Hash;

- (NSComparisonResult)versionStringCompare:(NSString *)other;

- (BOOL)isWhitespaceAndNewlines;

- (BOOL)isEmptyOrWhitespace;

- (BOOL)isEmail;

- (BOOL)isLegalPrice;

- (BOOL)isNumber;

- (BOOL) isHttpUrl;

-(BOOL)isLegalName;

- (BOOL)isOnlyContainNumberOrLatter;

-(unichar) intToHex:(int)n;

-(BOOL) isCharSafe:(unichar)ch;

-(BOOL)containString:(NSString *)string;

-(NSString *)removeSpace;

-(NSString *)replaceSpaceWithUnderline;

- (NSString *)replaceDotWithUnderline;

- (NSString *)encodeString;

-(NSString *)trimmedWhitespaceString;

-(NSString *)trimmedWhitespaceAndNewlineString;

// date
+(NSDate *)dateFromString:(NSString *)string;

- (NSDictionary *)parseURLParams;

- (NSString *)getValueStringFromUrlForParam:(NSString *)param;

- (NSDate *)date;

//formart
+ (id)stringWithActivityMessageType:(NSInteger)typeIndex ZPKID:(NSString*) pkid;

+(NSString * ) stringLocationbyint:(double) value;
@end
