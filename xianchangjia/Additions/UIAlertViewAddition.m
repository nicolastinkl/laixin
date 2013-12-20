//
//  UIAlertViewAddition.h
//  XianchangjiaAlbum
//
//  Created by JIJIA &&&&& ljh on 12-12-10.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//

#import "UIAlertViewAddition.h"

@implementation UIAlertView (Addition)

/**
 *  <#Description#>
 *
 *  @param title   <#title description#>
 *  @param message <#message description#>
 */
+(void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:title message:message  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

/**
 *  <#Description#>
 *
 *  @param message <#message description#>
 */
+(void) showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

@end