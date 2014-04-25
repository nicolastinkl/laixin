//
//  XCJCommentView.h
//  laixin
//
//  Created by apple on 3/9/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCJCommentViewDelegate <NSObject>

@optional
-(void) closeView;
-(void) sendContentWith:(NSString*) content;

@end

@interface XCJCommentView : UIView<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonsend;
@property (weak, nonatomic) IBOutlet UILabel *label_count;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIView *viewbg;

@property ( nonatomic,unsafe_unretained) id<XCJCommentViewDelegate> delegate;

@end

