//
//  User.h
//  RefreshTable
//
//  Created by Molon on 13-11-11.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface User : Model

@property (nonatomic,copy) NSString *avatarURL;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,copy) NSString *backgroundImageURL;

@end
