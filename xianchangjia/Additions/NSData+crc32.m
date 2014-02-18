//
//  NSData+crc32.m
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "NSData+crc32.h"
#import <zlib.h>

@implementation NSData (crc32)
+ (NSString *)CRC32With:( NSData *)input
{
    uLong crcValue = crc32(0L, NULL, 0L);
    crcValue = crc32(crcValue, (const Bytef*)input.bytes, input.length);
    
    return [NSString stringWithFormat:@"%lx", crcValue];
}
- (NSString *)CRC32
{
       return [NSData CRC32With:self];
}
@end
