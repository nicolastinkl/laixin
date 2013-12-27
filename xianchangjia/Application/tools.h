//
//  tools.h
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UIColor (Hex)
+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*)colorWithHex:(NSInteger)hexValue;
+ (UIColor*)whiteColorWithAlpha:(CGFloat)alphaValue;
+ (UIColor*)blackColorWithAlpha:(CGFloat)alphaValue;
@end

//load image from nib
@interface UIImage(imageNamedTwo)
+ (UIImage *)imageNamedTwo:(NSString *)name;      // load from main bundle
+ (UIImage *)imageNamedType:(NSString *)name
                   TypeName:(NSString *)type;      // load from main bundle
@end
@interface NSCalendar (SameSpecialCalculations)
-(NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate ;
@end

@interface NSCalendar (DiffSpecialCal)
-(NSInteger) daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate ;
@end

@interface NSObject(ISNULL)
-(BOOL) isKindOfClassOfJson:(NSObject*) obj;
@end
@interface tools : NSObject
+(NSString * ) ReturnNewURLBySize:(NSString *) URL lengDp:(int) lengDP status:(NSString*) smb;
+(void) setRoundHeadRotary:(UIView *)view;
+(void) setOBHeadRotary:(UIView *)view;
+ (id) loadController:(Class)classType ;
+(NSString *) FormatStringForDate:(NSDate *)date;
+(NSDateFormatter*) shortDateFormat:(NSDate*) date;
+(NSNumberFormatter*) rownumberFormat;
+(NSNumber*) numberFromObject:(id)obj;
+(NSDateFormatter*) serverDateFormat;
+(NSDateFormatter*) serverShortDateFormat;
+(NSDate*) datebyStr:(NSString *) strTime;
+(NSString *)fixStringForDate:(NSDate *)date;
+(NSString *)StringForDate:(NSDate *)date;
+ (NSDate*) convertToUTC:(NSDate*)sourceDate;
+(NSURL*)UrlFromString:(NSString*) str;
+ (NSString*)timeLabelTextOfTime:(NSTimeInterval)time;
+ (NSString*)randomStringWithLength:(NSUInteger)length;
+ (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue;

@end
