//
//  XianchangjiaAlbumDefines.h
//  XianchangjiaAlbum
//
//  Created by JIJIA &&&&& ljh on 12-12-9.
//  Copyright (c) 2012年 SlowsLab. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#ifndef DoubanAlbum_DoubanAlbumDefines_h
#define DoubanAlbum_DoubanAlbumDefines_h

typedef enum {
    kTagareascene = 1,
    kTagrecommentscene = 2,
    kTagmusicscene = 3,
}kSceneType;

//msgType;	 //0默认文本类型  1录音类型  2图片类型 3 位置信息类型
typedef enum {
	KMessage_private_Default = 0, //text
	KMessage_private_Audio = 1, //audio
	KMessage_private_Image = 2, //image
	KMessage_private_Location = 3, //location
} KMessage_private_user_Msg_type;

//#warning Release
#define NEED_OUTPUT_LOG                     1   // 0 relese  1 debug

#define ipAddress							@"im.xianchangjia.com"
#define systemUser							@"register@im.xianchangjia.com"
#define systemPushUser						@"system_push@im.xianchangjia.com"
#define systemPushUser_name					@"system_push"
#define systemXmppResource					@"Ocean"  //PS:Upperscase lowercase
#define enterInvite							@"enter"
#define leaveInvite							@"leave"

#define FromOtherUser						@0
#define FromMe								@1
#define KBMapAPIKEY							@"4EFD73542AA0452489B5297EF4420994DCEF8CA4"
#define kAppkeyForYoumeng					@"526a4d8f56240b8ecf035ab7"
#define kAPpkeyForWeiChat					@"wx3c91c9881ed7d8ef"
#define kAppKey								@"2824743419"
#define kAppSecret							@"9c152c876ec980df305d54196539773f"
#define kAppRedirectURI						@"http://1.livep.sinaapp.com/api/weibo_manager_impl/sina_weibo/callback.php"

#define kidswantURL                         @"http://api.xianchangjia.com/"//@"http://app.kidswant.com.cn"
#define xianchangjiaURI						@"2824743419://com.liveplus"
#define LaixinWebsocketURL                  @"ws://127.0.0.1:8000/ws"

#define USER_DEFAULT                [NSUserDefaults standardUserDefaults]
#define FILE_MANAGER                [NSFileManager defaultManager]
#define LocalServiceIP               @"http://192.168.8.247"

#define SystemKidsColor             0xfcd412
#define TableName                   @"KidswantProject.db"

#define APP_CACHES_PATH             [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define APP_SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define APP_SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

#define APP_SCREEN_CONTENT_HEIGHT   ([UIScreen mainScreen].bounds.size.height-20.0)

#define IS_4_INCH                   (APP_SCREEN_HEIGHT > 480.0)

#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define APP_STORE_LINK_http         @"https://itunes.apple.com/cn/app/xian-chang-jia//id541873451?ls=1&mt=8"
#define APP_STORE_LINK_iTunes       @"itms-apps://itunes.apple.com/cn/app/541873451?mt=8"

#define APP_COMMENT_LINK_iTunes     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=541873451"

/*keychain group*/
#define KeyChain_Laixin_account_phone           @"lifestyle.laixin.chengdu.account_phone"
#define KeyChain_Laixin_account_pwd             @"lifestyle.laixin.chengdu.account_pwd"
#define KeyChain_Laixin_account_user_id         @"lifestyle.laixin.chengdu.account_user_id"
#define KeyChain_Laixin_account_user_nick       @"KeyChain_Laixin_account_user_nick"
#define KeyChain_Laixin_account_user_headpic    @"KeyChain_Laixin_account_user_headpic"
#define KeyChain_Laixin_account_user_signature    @"KeyChain_Laixin_account_user_signature"
#define KeyChain_Laixin_account_user_position    @"KeyChain_Laixin_account_user_position"
#define KeyChain_Laixin_account_sessionid       @"KeyChain_Laixin_account_sessionid"

#define KeyChain_Laixin_systemconfig_websocketURL     @"KeyChain_Laixin_systemconfig_websocketURL"



/*-----------------------------
 1. 类型1----新的好友动态
 2. 类型2----新的被人评论
 3. 类型3----新的被添加好友
 4. 类型4----新的商家消息
 5. 类型5----新的小主播消息
 6. 类型6----新的现场推荐
 7. 类型7----新的用户推荐
 8. 类型8 -- 提示”哪些“我的好友也在使用现场加
 8. 类型100----用户间私信		
 */
typedef enum {
    XCXmppMessageType_NewFrendsStuts		= 1,
    XCXmppMessageType_CommentbyOthers		= 2,
    XCXmppMessageType_AddedFriendsByOthers  = 3,
    XCXmppMessageType_Businesses			= 4,
    XCXmppMessageType_SmarllScense			= 5,
	XCXmppMessageType_Scense_Recommend		= 6,
	XCXmppMessageType_User_Recommend		= 7,
	XCXmppMessageType_NotityUserUseXC		= 8,
	XCXmppMessageType_User_Private			= 100,
} _XCXmppMessageType;

typedef enum {
	XCMessageActivity_photocomment				= 1,
	XCMessageActivity_beingAddingFriends		= 2,
	XCMessageActivity_MusicCheckin				= 3,
	XCMessageActivity_UserPrivateMessage		= 4,
	XCMessageActivity_SceneSmallanchor			= 5,
	XCMessageActivity_SceneBusniessMessage		= 6,
	XCMessageActivity_NotityUserUseXC			= 7,
} _XCMessageActivity;
 
#define  XCMessageActivity_photocomment_str @"comment-added"
#define  XCMessageActivity_beingAddingFriends_str @"friends-added"
#define  XCMessageActivity_musiccheckin_str @"musiccheckin-added"
#define  XCMessageActivity_User_privateMessage @"User_privateMessage-added"
#define  XCMessageActivity_str_SceneSmallanchorMessage @"SceneSmallanchorMessage-added"
#define  XCMessageActivity_str_SceneBusniessMessage @"SceneBusniessMessage-added"
#define  XCMessageActivity_str_NotityUserUseXC @"NotityUserUseXC-added"

#define IMAGE_CACHE					[SDImageCache sharedImageCache]
#define NOTIFICATION_CENTER         [NSNotificationCenter defaultCenter]

#pragma mark - Core Data
#define SystemTextColor				[UIColor colorWithHex:0x51575a]
#define SystembackgroundColor		[UIColor colorWithHex:0xe2e2dd]
#define SystemTextFont				19.0f

#define CoreDataName				@"xiangchangjia.sqlite"
#define CoreDataDirName				@"xianchangjiaCoreData"

#define SlidTabView_offset					floorf(25.0)

#define Notify_MainViewTitleChangetext			@"Notify_MainViewTitleChangetext"

#define MOCSave(managedObjectContext) { \
NSError __autoreleasing *error = nil; \
NSAssert([managedObjectContext save:&error], @"-[NSManagedObjectContext save] error:\n\n%@", error); }

#define MOCCount(managedObjectContext, fetchRequest) \
NSManagedObjectContextCount(self, _cmd, managedObjectContext, fetchRequest)

#define MOCCountAll(managedObjectContext, entityName) \
MOCCount(_managedObjectContext, [NSFetchRequest fetchRequestWithEntityName:entityName])

#define MOCFetch(managedObjectContext, fetchRequest) \
NSManagedObjectContextFetch(self, _cmd, managedObjectContext, fetchRequest)

#define MOCFetchAll(managedObjectContext, entityName) \
MOCFetch(_managedObjectContext, [NSFetchRequest fetchRequestWithEntityName:entityName])

#define MOCDelete(managedObjectContext, fetchRequest, cascadeRelationships) \
NSManagedObjectContextDelete(self, _cmd, managedObjectContext, fetchRequest, cascadeRelationships)

#define MOCDeleteAll(managedObjectContext, entityName, cascadeRelationships) \
MOCDelete(managedObjectContext, [NSFetchRequest fetchRequestWithEntityName:entityName], cascadeRelationships)

#define FRCPerformFetch(fetchedResultsController) { \
NSError __autoreleasing *error = nil; \
NSAssert([fetchedResultsController performFetch:&error], @"-[NSFetchedResultsController performFetch:] error:\n\n%@", error); }

NS_INLINE NSUInteger NSManagedObjectContextCount(id self, SEL _cmd, NSManagedObjectContext *managedObjectContext, NSFetchRequest *fetchRequest) {
    NSError __autoreleasing *error = nil;
    NSUInteger objectsCount = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
//    NSAssert(objectsCount != NSNotFound, error);
    return objectsCount;
}

NS_INLINE NSArray *NSManagedObjectContextFetch(id self, SEL _cmd, NSManagedObjectContext *managedObjectContext, NSFetchRequest *fetchRequest) {
    NSError __autoreleasing *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

NS_INLINE void NSManagedObjectContextDelete(id self, SEL _cmd, NSManagedObjectContext *managedObjectContext, NSFetchRequest *fetchRequest, NSArray *cascadeRelationships) {
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesPendingChanges = NO;
    fetchRequest.relationshipKeyPathsForPrefetching = cascadeRelationships;
    NSArray *fetchedObjects = MOCFetch(managedObjectContext, fetchRequest);
    for (NSManagedObject *fetchedObject in fetchedObjects) {
        [managedObjectContext deleteObject:fetchedObject];
    }
}

#if NEED_OUTPUT_LOG

    #define SLog(xx, ...)   NSLog(xx, ##__VA_ARGS__)
    #define SLLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

    #define SLLogRect(rect) \
    SLLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
    rect.size.width, rect.size.height)

    #define SLLogPoint(pt) \
    SLLog(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

    #define SLLogSize(size) \
    SLLog(@"%s w=%f, h=%f", #size, size.width, size.height)

    #define SLLogColor(_COLOR) \
    SLLog(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

    #define SLLogSuperViews(_VIEW) \
    { for (UIView* view = _VIEW; view; view = view.superview) { SLLog(@"%@", view); } }

    #define SLLogSubViews(_VIEW) \
    { for (UIView* view in [_VIEW subviews]) { SLLog(@"%@", view); } }

#else

    #define SLog(xx, ...)  ((void)0)
    #define SLLog(xx, ...)  ((void)0)

#endif

#endif
