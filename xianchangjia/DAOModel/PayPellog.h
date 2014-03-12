//
//  PayPellog.h
//  laixin
//
//  Created by apple on 3/7/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "Model.h"

@interface PayPellog : Model

@property (nonatomic, copy  ) NSString  *orderid;
@property (nonatomic, assign) NSInteger payid;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, copy  ) NSString  *productname;
@property (nonatomic, copy  ) NSString  *productdesc;

@property (nonatomic, assign) NSInteger amount;   //金额
@property (nonatomic, assign) NSInteger ex_people;  //服务员数
@property (nonatomic, assign) NSInteger productcatalog;  //商品分类
@property (nonatomic, assign) NSInteger paystate;
@property (nonatomic, assign) double    create_time;


@end



@interface PayOrderHistorylog : Model

/*"orderid":"1394352157-875",
 "remain":38,
 "create_time":1394352157,
 "uid":1,
 "ex_people":12,
 "paystate":0,
 "paytime":null,
 "refundtime":null,
 "mid":1*/
@property (nonatomic, copy  ) NSString  *orderid;
@property (nonatomic, assign) NSInteger remain;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger mid;

@property (nonatomic, assign) double paytime;
@property (nonatomic, assign) NSInteger ex_people;
@property (nonatomic, assign) double refundtime;
@property (nonatomic, assign) NSInteger paystate;
@property (nonatomic, assign) double    create_time;


@end





@interface privatePhotoListInfo : Model

/*
 "picture":"http://kidswant.u.qiniudn.com/FpjyuFcobuiOCziqNptk1vZV7MOW",
 "uid":5,
 "did":5,
 "text":"b6RZt0MXicse7o9",
 "height":1504,
 "width":2256,
 "time":1394591837.0,
 "type":"pic"*/
@property (nonatomic, copy  ) NSString  *picture;
@property (nonatomic, copy  ) NSString  *uid;
@property (nonatomic, copy  ) NSString  *did;
@property (nonatomic, copy  ) NSString  *text;
@property (nonatomic, copy  ) NSString  *type;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) double time;


@end





