//
//  XCJAddressBook.h
//  laixin
//
//  Created by apple on 13-12-20.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCJAddressBook : NSObject
{
    NSInteger sectionNumber;
    NSInteger recordID;
    NSString *name;
    NSString *email;
    NSString *tel;

}

@property NSInteger sectionNumber;
@property NSInteger recordID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *tel;
@end
