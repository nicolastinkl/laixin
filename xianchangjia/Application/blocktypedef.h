//
//  blocktypedef.h
//  XianchangjiaAlbum 
//

#ifndef DoubanAlbum_blocktypedef_h
#define DoubanAlbum_blocktypedef_h

typedef void(^SLBlock)(void);
typedef void(^SLBlockBlock)(SLBlock block);
typedef void(^SLObjectBlock)(id obj);
typedef void(^SLArrayBlock)(NSArray *array);
typedef void(^SLMutableArrayBlock)(NSMutableArray *array);
typedef void(^SLDictionaryBlock)(NSDictionary *dic);
typedef void(^SLErrorBlock)(NSError *error);
typedef void(^SLIndexBlock)(NSInteger index);
typedef void(^SLFloatBlock)(CGFloat afloat);

typedef void(^SLCancelBlock)(id viewController);
typedef void(^SLFinishedBlock)(id viewController, id object);
typedef void(^SLSendRequestAndResendRequestBlock)(id sendBlock, id resendBlock);

typedef void(^SLNetBlock)(NSArray *posts, NSError *error);

/* net working */
typedef void (^CompletionBlock)(id, NSError *);
typedef void (^ComplexBlock)(id, id, id);
typedef void (^SimpleBlock)(void);
typedef void (^InfoBlock)(id);
typedef void (^ConfirmationBlock)(BOOL);
typedef BOOL (^BoolBlock)(id);
typedef void (^DownloadProgressBlock)(NSUInteger bytesRead, long long totalBytes, long long totalBytesExp);


#endif
