//
//  LXChatDBStoreManager.h
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlockTinkl)(id, NSError *);
@class Conversation;
@class LXUser;
@class FCUserDescription;
@interface LXChatDBStoreManager : NSObject
/**
 *  <#Description#>
 *
 *  @param friendsArray <#friendsArray description#>
 *  @param completion   <#completion description#>
 */
- (void)differenceOfFriendsIdWithNewConversation:(NSArray *)friendsArray
                                  withCompletion:(CompletionBlockTinkl) completion ;
- (void)saveContext;

- (NSMutableArray *)fetchAllMessagesInConversation:(Conversation *)conversation;

- (FCUserDescription *)fetchFCUserDescriptionByUID:(NSString * ) UserID;

/**
 *  用户信息
 *
 *  @param fcuserdesp <#fcuserdesp description#>
 *  @param completion <#completion description#>
 */
- (void)setFCUserObject:(LXUser *) fcuserdesp
                    withCompletion:(CompletionBlockTinkl) completion ;

/**
 *  设置我的好友
 */
- (void)setFriendsObject:(LXUser *) fcuserdesp;

/**
 *  设置我的好友
 */
- (void)setFriendsUserDescription:(FCUserDescription *) fcuserdesp;
/**
 *  获取所有好友数据
 */
-(NSArray * ) fetchAllFCFriends;


/**
 *      // 查找是否是我的好友
 */
-(BOOL) fetchFCFriendsWithUid:(NSString *) userid;

@end
