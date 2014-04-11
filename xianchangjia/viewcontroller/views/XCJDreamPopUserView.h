//
//  XCJDreamPopUserView.h
//  laixin
//
//  Created by apple on 4/11/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XCJDreamPopUserViewDelegate <NSObject>

@optional
-(void) closeView;
-(void) sendLike;
-(void) targetUserinfo;
@end


@interface XCJDreamPopUserView : UIView


@property (weak, nonatomic) IBOutlet UIImageView *image_user;
@property (weak, nonatomic) IBOutlet UILabel *label_number;
@property (weak, nonatomic) IBOutlet UIButton *button_like;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property ( nonatomic,unsafe_unretained) id<XCJDreamPopUserViewDelegate> delegate;


- (IBAction)closeview:(id)sender;


- (IBAction)targetuserinfoClick:(id)sender;

@end
