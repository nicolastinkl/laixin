/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ClockView.h"
#import "ClockLayer.h"
#import <FBKVOController/FBKVOController.h>


typedef void(^TKINTBLOCK)(int index);


typedef NSInteger(^TKINTBL)(NSArray * array,NSDictionary * dict,NSError * error);



#define CLOCK_LAYER(VIEW) ((ClockLayer *)VIEW.layer)

static NSDictionary *layer_style(ClockViewStyle viewStyle)
{
  NSDictionary *dict = nil;
  switch (viewStyle) {
    case kClockViewStyleLight:
      dict = [ClockLayer lightStyle];
      break;
    case kClockViewStyleDark:
      dict = [ClockLayer darkStyle];
      break;
    default:
      break;
  }
  return dict;
}

@implementation ClockView
{
  FBKVOController *_KVOController;
}

+ (Class)layerClass
{
  return [ClockLayer class];
    
}


-(void) test:(TKINTBL) typesss
{
    typesss(@[],@{},nil);
    
    /*
     [self test:^NSInteger(NSArray *array, NSDictionary *dict, NSError *error) {
     
     }];
     */
}
- (instancetype)initWithClock:(Clock *)clock style:(ClockViewStyle)style
{
  self = [super init];
  if (nil != self) {
    CLOCK_LAYER(self).style = layer_style(style);
    
    // create KVO controller instance
    _KVOController = [FBKVOController controllerWithObserver:self];
      [_KVOController observe:clock keyPath:@"date" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
          if ([observer isKindOfClass:[ClockView class]]) {
              // update observer with new value
              CLOCK_LAYER(((ClockView *)observer)).date = change[NSKeyValueChangeNewKey];
          }
      }];
      
      
      return self ;
    // handle clock change, including initial value
    [_KVOController observe:clock keyPath:@"date" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(ClockView *clockView, Clock *clock, NSDictionary *change) {
      // update observer with new value
      CLOCK_LAYER(clockView).date = change[NSKeyValueChangeNewKey];
    }];
  }
  return self;
}




@end
