//
//  tools.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "tools.h"
#import "XCAlbumDefines.h"
#import "DataHelper.h"
#import "NSString+Addition.h" 
#pragma  mark 使用Category来计算同一时代（AD|BC）两个日期午夜之间的天数：


@implementation NSCalendar (SameSpecialCalculations)

-(NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate {
	NSInteger startDay=[self ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:startDate];
    
	NSInteger endDay=[self ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:endDate];
    
	return endDay-startDay;
}

@end


@implementation NSObject(ISNULL)

-(BOOL) isKindOfClassOfJson:(NSObject*) obj
{
	if ([obj isKindOfClass:[NSNull class]]) {
		return  YES;
	}
	return NO;
}

@end

#pragma  mark     使用Category来计算不同时代（AD|BC）两个日期的天数：
@implementation NSCalendar (DiffSpecialCal)

-(NSInteger) daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate {
    
	NSCalendarUnit units=NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
	NSDateComponents *comp1=[self components:units fromDate:startDate];
	NSDateComponents *comp2=[self components:units fromDate:endDate];
    
	[comp1 setHour:12];
	[comp2 setHour:12];
    
	NSDate *date1=[self dateFromComponents: comp1];
	NSDate *date2=[self dateFromComponents: comp2];
    
	return [[self components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0] day];
}

@end

@implementation UIColor(Hex)

+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*)colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (UIColor*)whiteColorWithAlpha:(CGFloat)alphaValue
{
    return [UIColor colorWithHex:0xffffff alpha:alphaValue];
}

+ (UIColor*)blackColorWithAlpha:(CGFloat)alphaValue
{
    return [UIColor colorWithHex:0x000000 alpha:alphaValue];
}

@end

//load image from nib
@implementation UIImage(imageNamedTwo)
// load from main bundle
+ (UIImage *)imageNamedTwo:(NSString *)name{
    return  [UIImage imageNamed:name];
//	NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"  inDirectory:@"VillageImages/2/3"];
//	UIImage * bgimage = [UIImage imageWithContentsOfFile:path];
	//return  bgimage;
}

+ (UIImage *)imageNamedType:(NSString *)name
				   TypeName:(NSString *)type
{
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type  inDirectory:@"VillageImages/2/3"];
	UIImage * bgimage = [UIImage imageWithContentsOfFile:path];
	return  bgimage;
}      // load from main bundle
@end

@implementation tools

+(NSString * ) ReturnNewURLBySize:(NSString *) URL lengDp:(int) lengDP status:(NSString*) smb
{
    if (!URL || [URL isKindOfClass:[NSNull class]]) {
        return  @"";
    }
    NSArray * CharArray = [URL componentsSeparatedByString:@"/"];
    if (CharArray && CharArray.count > 0) {
        //获取http://livep-photobarn.stor.sinaapp.com/a79baaac9ec0bed32faae37e6548490fcee14035
        
        NSString * fileMD5Char = [CharArray objectAtIndex:(CharArray.count -1)]; //获取名称md5
        
        if (smb && lengDP > 0) {
            NSString * newMD5Char = [NSString stringWithFormat:@"%d/%@",lengDP,fileMD5Char];
            NSString * returnstr = [URL stringByReplacingOccurrencesOfString:fileMD5Char withString:newMD5Char];
            return returnstr;
        }else{
            return  URL;
        }
    }
	return nil;
}

/*加载视图*/
+ (id)loadController:(Class)classType {
    NSString *className = NSStringFromClass(classType);
    UIViewController *controller = [[classType alloc] initWithNibName:className bundle:nil];
    return controller;
}



+(void) setRoundHeadRotary:(UIView *)view
{
	UIImage *roundCorner=[UIImage imageNamedTwo:@"register_star_avatar_bg"];
	CALayer* roundCornerLayer = [CALayer layer];
	roundCornerLayer.frame = view.bounds;
	roundCornerLayer.contents = (id)[roundCorner CGImage];
	[[view layer] setMask:roundCornerLayer];
}

+(void) setOBHeadRotary:(UIView *)view
{
//	UIImage *roundCorner=[UIImage imageNamedTwo:@"mask_head45"];
	CALayer* roundCornerLayer = [CALayer layer];
//	roundCornerLayer.frame = view.bounds;
//	roundCornerLayer.contents = (id)[roundCorner CGImage];
//	[[view layer] setMask:roundCornerLayer];
    [roundCornerLayer setCornerRadius:15.0f];
}

+(NSString *) FormatStringForDate:(NSDate *)date  //格式时间格式  1月前  1天前
{
	if (date == nil) {
		return @"";
	}
    
    //	static NSDateFormatter* shortdateformat=nil;
	static NSDateFormatter* tomorrowdateformat=nil;
	static NSDateFormatter* todayformat=nil;
	static NSDateFormatter* yesterdayformat=nil;
	static NSDateFormatter* fortureformat=nil;
	
	NSDate *now=[NSDate date];
	NSDateComponents* parts=nil;
	
	//const unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	parts = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
	NSDate *todayBegin=[[NSCalendar currentCalendar] dateFromComponents:parts];
	NSTimeInterval timediff=[date timeIntervalSinceDate:todayBegin];
	if(timediff>=24*60*60)
	{
		if(tomorrowdateformat==nil)
		{
			tomorrowdateformat=[[NSDateFormatter alloc] init];
			[tomorrowdateformat setDateFormat:@"明天 HH:mm"];
		}
		return  [tomorrowdateformat stringFromDate:date];
	}
	
	if(timediff>=0)
	{
		if(todayformat==nil)
		{
			todayformat=[[NSDateFormatter alloc] init];
			[todayformat setDateFormat:@"今天 HH:mm"];
		}
		return  [todayformat stringFromDate:date];
	}
	
	if(timediff>=-24*60*60)
	{
		if(yesterdayformat==nil)
		{
			yesterdayformat=[[NSDateFormatter alloc] init];
			[yesterdayformat setDateFormat:@"昨天 HH:mm"];
		}
		return  [yesterdayformat stringFromDate:date];
	}
	
	NSInteger days = [[NSCalendar currentCalendar] daysWithinEraFromDate:now toDate:date];
	if ((days + 90) < 0) {
		//一个月以前了
		if(fortureformat==nil)
		{
			fortureformat=[[NSDateFormatter alloc] init];
			[fortureformat setDateFormat:@"Y-MM-dd"];
		}
		return [fortureformat stringFromDate:date];
	}else{
		return [NSString stringWithFormat:@"%d%@",-days, @"天前"];
	}
	
	return @"";
	
}

+(NSDateFormatter*) shortDateFormat:(NSDate*) date
{
	static NSDateFormatter* shortdateformat=nil;
	static NSDateFormatter* tomorrowdateformat=nil;
	static NSDateFormatter* todayformat=nil;
	static NSDateFormatter* yesterdayformat=nil;
	static NSDateFormatter* fortureformat=nil;
	
	NSDate *now=[NSDate date];
	NSDateComponents* parts=nil;
	
	//const unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	parts = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
	NSDate *todayBegin=[[NSCalendar currentCalendar] dateFromComponents:parts];
	NSTimeInterval timediff=[date timeIntervalSinceDate:todayBegin];
	if(timediff>=2*24*60*60)
	{
		if(fortureformat==nil)
		{
			fortureformat=[NSDateFormatter new];
            //			[fortureformat setDateFormat:@"Y-M-d HH:mm"];
			[fortureformat setDateFormat:@"Y-MM-dd"];
		}
		return fortureformat;
	}
	
	if(timediff>=24*60*60)
	{
		if(tomorrowdateformat==nil)
		{
			tomorrowdateformat=[[NSDateFormatter alloc] init];
			[tomorrowdateformat setDateFormat:@"明天 HH:mm"];
		}
		return tomorrowdateformat;
	}
	
	if(timediff>=0)
	{
		if(todayformat==nil)
		{
			todayformat=[[NSDateFormatter alloc] init];
			[todayformat setDateFormat:@"今天 HH:mm"];
		}
		return todayformat;
	}
	
	if(timediff>=-24*60*60)
	{
		if(yesterdayformat==nil)
		{
			yesterdayformat=[[NSDateFormatter alloc] init];
			[yesterdayformat setDateFormat:@"昨天 HH:mm"];
		}
		return yesterdayformat;
	}
	
	if(shortdateformat==nil)
    {
        shortdateformat = [NSDateFormatter new];
        //[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        //        [shortdateformat setDateFormat:@"Y-M-d HH:mm"];
		[shortdateformat setDateFormat:@"Y-MM-dd"];
    }
	return shortdateformat;
}

+(NSNumberFormatter*) rownumberFormat
{
	static NSNumberFormatter * rownumberformat=nil;
    if(rownumberformat==nil)
    {
        rownumberformat = [NSNumberFormatter new];
        [rownumberformat setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return rownumberformat;
}
+(NSNumber*) numberFromObject:(id)obj
{
	if([obj isKindOfClass:[NSNumber class]])
		return obj;
	if([obj isKindOfClass:[NSString class]])
	{
		return [[tools rownumberFormat] numberFromString:obj];
	}
	if([obj isKindOfClass:[NSNull class]])
		return nil;
	return nil;
}

+ (NSDate*) convertToUTC:(NSDate*)sourceDate
{
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;
	
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate];
    return destinationDate;
}

+(NSString *)StringForDate:(NSDate *)date
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:kCFDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *fixString = [dateFormatter stringFromDate:date];
	return fixString;
}

+ (NSString *)fixStringForDate:(NSDate *)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:kCFDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *fixString = [dateFormatter stringFromDate:date];
	return fixString;
}

+(NSDateFormatter*) serverDateFormat
{
	static NSDateFormatter* servrdataformat=nil;
    if(servrdataformat==nil)
    {
        servrdataformat = [[NSDateFormatter alloc] init];
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        [servrdataformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return servrdataformat;
}


+(NSDateFormatter*) serverShortDateFormat
{
	static NSDateFormatter* servrdataformat=nil;
    if(servrdataformat==nil)
    {
        servrdataformat = [[NSDateFormatter alloc] init];
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        [servrdataformat setDateFormat:@"yyyy-MM-dd"];
    }
    return servrdataformat;
}

+(NSDate*) datebyStr:(NSString *) strTime
{
	NSDate *fromDate;
	if (strTime) {
		NSDateFormatter *format=[[NSDateFormatter alloc] init];
		[format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSDate *fromdate=[format dateFromString:strTime];
		NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
		NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
		fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
	}
	return fromDate;
}


+ (NSString*)timeLabelTextOfTime:(NSTimeInterval)time
{
    if (time<=0) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *text = [dateFormatter stringFromDate:date];
    //最近时间处理
    NSInteger timeAgo = [[NSDate date] timeIntervalSince1970] - time;
    if (timeAgo > 0 && timeAgo < 60) {
        text = [NSString stringWithFormat:@"%ld秒前", (long)timeAgo];
    }else if (timeAgo >= 60 && timeAgo < 3600) {
        NSInteger timeAgoMinute = timeAgo / 60;
        text = [NSString stringWithFormat:@"%ld分钟前", (long)timeAgoMinute];
    }else if (timeAgo >= 3600 && timeAgo < 86400) {
        [dateFormatter setDateFormat:@"HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }else if (timeAgo >= 86400 && timeAgo < 86400*2) {
        [dateFormatter setDateFormat:@"昨天HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }else if (timeAgo >= 86400*2 && timeAgo < 86400*3) {
        [dateFormatter setDateFormat:@"前天HH:mm"];
        text = [dateFormatter stringFromDate:date];
    }
    return text;
}

+ (NSString*)timeLabelTextOfTimeMoth:(NSTimeInterval)time
{
    if (time<=0) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *text = [dateFormatter stringFromDate:date];
    //最近时间处理
    NSInteger timeAgo = [[NSDate date] timeIntervalSince1970] - time;
    if (timeAgo > 0 && timeAgo < 60) {
        return @"今天";
    }else if (timeAgo >= 60 && timeAgo < 3600) {
        return @"今天";
    }else if (timeAgo >= 3600 && timeAgo < 86400) {
        return @"今天";
    }else if (timeAgo >= 86400 && timeAgo < 86400*2) {
       return @"昨天";
    }else if (timeAgo >= 86400*2 && timeAgo < 86400*3) {
        return @"前天";
    }
    return text;
}


//+(NSString * ) serverTimeFormatLocalTime:(NSString * ) timess
//{
//    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
//    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
//    NSString *fromTimeZone = @"America/Los_Angeles"; //服务器时区
//    NSString *date_fromTimeZone = [NSString stringWithUTF8String:timess]; //time是服务器返回的时间字符串
//    
//    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithName:fromTimeZone]];
//    NSDate *dateOfGMT = [dateFormatter2 dateFromString:date_fromTimeZone]; //转换为GMT时间
//    
//    NSTimeZone* totimeZone = [NSTimeZone localTimeZone]; //获得本地时区
//    [dateFormatter2 setTimeZone:totimeZone]; //
//    NSString *dateStrDst = [dateFormatter2 stringFromDate:dateOfGMT]; //由GMT时间转换为本地时间
//    return dateStrDst;
//}


+(NSURL*)UrlFromString:(NSString*) str
{
    if(str==nil || [str isKindOfClass:[NSNull class]])
        return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",str]];
}



#pragma mark - other Common

+ (NSString*)randomStringWithLength:(NSUInteger)length
{
    char data[length];
    for (int i=0;i<length;data[i++] = (char)('A' + arc4random_uniform(26)));
    NSString *result = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]]) {
            return object;
        } else if ([object isKindOfClass:[NSNumber class]]) {
            return [object stringValue];
        }
    }
    return defaultValue;
}

+ (NSString *) getUrlByImageUrl:(NSString * ) url Size:(NSInteger) value
{
    if ([url isNilOrEmpty]) {
        return @"";
    }
    url = [DataHelper getStringValue:url defaultValue:@""];
    return [NSString stringWithFormat:@"%@?imageView/1/w/%d/h/%d/q/85",url,value,value];
}

+ (NSString *) getUrlByImageUrl:(NSString * ) url width:(NSInteger) width height:(NSInteger) height
{
    if ([url isNilOrEmpty]) {
        return @"";
    }
    url = [DataHelper getStringValue:url defaultValue:@""];
    return [NSString stringWithFormat:@"%@?imageView/1/w/%d/h/%d/q/85",url,width,height];
    
}
+(UIColor *) colorWithIndex:( int ) strIndex
{
    if (strIndex >= 7) {
      return [UIColor colorWithPatternImage:[UIImage imageNamed:@"med-name-bg-0"]];
    }
    
    return  [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"med-name-bg-%d",strIndex]]];
}

@end
