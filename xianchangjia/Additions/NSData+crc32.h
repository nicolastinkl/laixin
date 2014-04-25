//
//  NSData+crc32.h
//  laixin
//
//  Created by apple on 2/18/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (crc32)
+ (NSString *)CRC32With:( NSData *)input;
- (NSString *)CRC32;
@end
