//
//  LXCommendModel.h
//  laixin
//
//  Created by tinkl on 7/5/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "RVMViewModel.h"

@interface LXCommendModel : RVMViewModel

@property (nonatomic, readonly) NSString *cirleName;
@property (nonatomic, readonly) NSString *cirleLevel;

@property (nonatomic, readonly) RACSignal *updatedSignal;

-(void) initAllData;

-(RACSignal *)modelIsValidArray;

@end
