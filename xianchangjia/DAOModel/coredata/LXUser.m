//
//  LXUser.m
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXUser.h"
#import "tools.h"
#import "DataHelper.h"

@implementation LXUser


/*
 "background_image" = "<null>";
 birthday = "<null>";
 "create_time" = 1388138065;
 headpic = "http://breadtripimages.qiniudn.com/photo_2013_07_22_ae40a8c7b07988c19ad8ec6c6fc5876d.jpg";
 height = 0;
 marriage = "<null>";
 nick = "\U5218\U6770\U7ea2tinkl";
 sex = 0;
 signature = "\U571f\U8c6a\U3002\U4fee\U6b63\U4f60\U7684\U6700\U7231\Uff0c\U62c5\U5fc3\U79bd\U6d41\U611f\U3002\U7136\U540e\Uff1a\U795d\U8d3a\U5f00\U5f20\U5927\U5409\Uff01\U8d22\U6e90\U6eda\U6eda\Uff01";
 uid = 8;
*/
- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        _uid = [tools getStringValue:dic[@"uid"] defaultValue:@""];
        _nick = [tools getStringValue:dic[@"nick"] defaultValue:@""];
        _background_image = [tools getStringValue:dic[@"background_image"] defaultValue:@""];
        _birthday = [tools getStringValue:dic[@"birthday"] defaultValue:@""];
        _create_time = [DataHelper getDoubleValue:dic[@"create_time"] defaultValue:0.0];
        _headpic = [tools getStringValue:dic[@"headpic"] defaultValue:@""];
        _height = [[tools getStringValue:dic[@"height"] defaultValue:@""] intValue];
        _marriage = [tools getStringValue:dic[@"marriage"] defaultValue:@""];
        _sex = [[tools getStringValue:dic[@"sex"] defaultValue:@""] intValue];
        _active_by = [[tools getStringValue:dic[@"active_by"] defaultValue:@""] intValue];
        _active_level = [[tools getStringValue:dic[@"active_level"] defaultValue:@""] intValue];
        _actor = [[tools getStringValue:dic[@"active_level"] defaultValue:@""] intValue];
        _actor_level = [[tools getStringValue:dic[@"actor_level"] defaultValue:@""] intValue];
        _signature = [tools getStringValue:dic[@"signature"] defaultValue:@""];
        _position = [tools getStringValue:dic[@"position"] defaultValue:@""];
        _phone =[tools getStringValue:dic[@"phone"] defaultValue:@""];
        
        //exinfo
        NSDictionary * exinfoDict = [DataHelper getDictionaryValue:dic[@"exinfo"] defaultValue:nil];
        if (exinfoDict) {
            _like_me_count = [DataHelper getIntegerValue:exinfoDict[@"like_me_count"] defaultValue:0];
        }
        
        if (_circelArray) {
            [_circelArray removeAllObjects];
        }else{
            _circelArray = [[NSMutableArray alloc] init];
        }
        NSArray * circelArray = [DataHelper getArrayValue:dic[@"circle"] defaultValue:[NSMutableArray array]] ;
        if (circelArray && circelArray.count > 0) {
            [circelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser_circel *circelinfo = [[LXUser_circel alloc] initWithDict:obj];
                [_circelArray addObject:circelinfo];
            }];
        }
    }
    return self;
}
@end

@implementation LXUser_circel
@synthesize by_uid,cid,level,subid,time,title;

- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        cid = [[tools getStringValue:dic[@"cid"] defaultValue:@""] intValue];
        level = [[tools getStringValue:dic[@"level"] defaultValue:@""] intValue];
        subid = [[tools getStringValue:dic[@"subid"] defaultValue:@""] intValue];
        
        title =[tools getStringValue:dic[@"title"] defaultValue:@""];
        by_uid =[tools getStringValue:dic[@"by_uid"] defaultValue:@""];
        time = [DataHelper getDoubleValue:dic[@"time"] defaultValue:0.0];
        
    }
    return self;
}
@end
