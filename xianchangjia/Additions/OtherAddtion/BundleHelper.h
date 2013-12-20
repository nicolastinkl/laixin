//
//  DASettingViewController.h 
// 
//

#import <Foundation/Foundation.h>

@interface BundleHelper : NSObject

+ (NSString *)bundleApplicationId;

+ (NSString *)bundleNameString;

+ (NSString *)bundleDisplayNameString;

+ (NSString *)bundleShortVersionString;

+ (NSString *)bundleBuildVersionString;

+ (NSString *)bundleIdentifierString;

+ (NSArray *)bundleURLTypes;

/////
+ (NSString *)bundleUnderlineVersionString;

+ (NSString *)bundleFullVersionString;
@end
