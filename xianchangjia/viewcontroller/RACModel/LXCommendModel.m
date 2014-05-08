//
//  LXCommendModel.m
//  laixin
//
//  Created by tinkl on 7/5/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "LXCommendModel.h"
#import "XCAlbumAdditions.h"
#import <ReactiveViewModel.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LXCommendModel ()
@property (nonatomic, strong) RACSubject *updatedContentSignal;

// Private Access
@property (nonatomic, strong) NSString *recipeName;
@property (nonatomic, strong) NSString *recipeUID;
@property (nonatomic, strong) NSArray *cirleArray;

@end

@implementation LXCommendModel

-(id)init
{
    self = [super init];
    
    self.updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"LXCommendModel updatedContentSignal"];
    
    self.recipeName =@"";
    self.recipeUID = @"";
    
    RAC(self, cirleName) = [RACObserve(self, recipeName) map:^id(id value) {
        return [NSString stringWithFormat:@"%@",value];
    }];
    RAC(self, cirleLevel) = [RACObserve(self, recipeUID) map:^id(id value) {
        return [NSString stringWithFormat:@"%@",value];
    }];
    
    @weakify(self)
    [self.didBecomeActiveSignal subscribeNext:^(id x) {
        @strongify(self);
        [self initAllData];
    }];
    
    return self;
}

-(RACSignal *)modelIsValidArray
{
    @weakify(self);
    return [RACObserve(self, cirleArray) map:^id(id value) {
        @strongify(self);
        return  self.cirleArray;
    }];
}

-(void) initAllData
{
    [[MLNetworkingManager sharedManager] sendWithAction:@"circle.users" parameters:@{@"cid":@"1"} success:^(MLRequest *request, id responseObject) {
        NSDictionary * result =  responseObject[@"result"];
        NSArray *array = result[@"users"];
        if (array) {
            self.cirleArray = array;
            NSDictionary * dict = array[0];
            self.recipeName =  [DataHelper getStringValue:dict[@"time"] defaultValue:@""];
            self.recipeUID = [DataHelper getStringValue:dict[@"uid"] defaultValue:@""];
//            self.updatedSignal = [RACObserve(self, cirleArray) map:^id(id value) {
//                return value;
//            }];
        }else{
            self.cirleArray = @[];
        }
        
    } failure:^(MLRequest *request, NSError *error) {
        
    }];
}

@end
