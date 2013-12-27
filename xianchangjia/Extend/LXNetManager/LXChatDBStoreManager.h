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
- (void)setFCUserDescriptionObject:(FCUserDescription *) fcuserdesp
                    withCompletion:(CompletionBlockTinkl) completion ;
- (void)setFCUserObject:(LXUser *) fcuserdesp
                    withCompletion:(CompletionBlockTinkl) completion ;
- (void)setFriendsObject:(LXUser *) fcuserdesp;


-(NSArray * ) fetchAlAccounts;

@end
