 

#import <Foundation/Foundation.h>
#import "blocktypedef.h"
@interface GCDHelper : NSObject

+ (void)resizeImageInBackground:(SLBlock)block completion:(SLBlock)completion;

+ (void)loadCachedImage:(SLBlock)block completion:(SLBlock)completion;

// dispatch repeat
+ (void)repeatBlock:(SLBlock)block withCount:(NSUInteger)count;

// dispatch block
+ (void)dispatchBlock:(SLBlock)block completion:(SLBlock)completion;

// dispatch  once in the activity
+(void) dispatchOnceBlock:(SLBlock)block;
@end
