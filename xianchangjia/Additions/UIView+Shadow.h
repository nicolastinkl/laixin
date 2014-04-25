//
//  UIView+Shadow.h
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-5-25.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (Shadow)
/* A constraint is typically installed on the closest common ancestor of the views involved in the constraint.
 It is required that a constraint be installed on _a_ common ancestor of every view involved.  The numbers in a constraint are interpreted in the coordinate system of the view it is installed on.  A view is considered to be an ancestor of itself.
 example:
 UIView *sampleView1 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
 [sampleView1 makeInsetShadowWithRadius:3.0 Alpha:0.4];
 [self.view addSubview:sampleView1];
 
 UIView *sampleView2 = [[UIView alloc] initWithFrame:CGRectMake(150, 100, 100, 200)];
 [sampleView2 makeInsetShadowWithRadius:3.0 Color:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4] Directions:[NSArray arrayWithObjects:@"top", @"bottom", nil]];
 [self.view addSubview:sampleView2];
 */
- (void) makeInsetShadow;
- (void) makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha;
- (void) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;

@end
