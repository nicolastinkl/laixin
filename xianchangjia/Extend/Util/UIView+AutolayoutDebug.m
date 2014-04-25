//
//  UIView+AutolayoutDebug.m
//  ISClone
//
//  Created by Molon on 13-12-6.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "UIView+AutolayoutDebug.h"

@implementation UIView (AutolayoutDebug)

- (void)exerciseAmiguityInLayoutRepeatedly:(BOOL)recursive {
#ifdef DEBUG
    if (self.hasAmbiguousLayout) {
        [NSTimer scheduledTimerWithTimeInterval:.5
                                         target:self
                                       selector:@selector(exerciseAmbiguityInLayout)
                                       userInfo:nil
                                        repeats:YES];
    }
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview exerciseAmiguityInLayoutRepeatedly:YES];
        }
    }
#endif
}

@end
