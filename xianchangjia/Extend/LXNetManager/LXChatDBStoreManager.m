//
//  LXChatDBStoreManager.m
//  laixin
//
//  Created by apple on 13-12-27.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXChatDBStoreManager.h"
#import "Conversation.h"
#import "FCConversationModel.h"
#import "CoreData+MagicalRecord.h"
#import "FCUserDescription.h"
#import "LXUser.h"
#import "FCFriends.h"
#import "FCAccount.h"

@implementation LXChatDBStoreManager


/**
 *  friends list
 *
 *  @param friendsArray <#friendsArray description#>
 *  @param completion   <#completion description#>
 */
- (void)differenceOfFriendsIdWithNewConversation:(NSArray *)friendsArray
                                  withCompletion:(CompletionBlockTinkl) completion
{
    NSArray *cachedFriends = [FCFriends MR_findAll];
    NSMutableArray *cachedConversations = [NSMutableArray new];
    [cachedFriends enumerateObjectsUsingBlock:^(FCFriends *conversation, NSUInteger idx, BOOL *stop){
        FCConversationModel *model = [[FCConversationModel alloc] initWithFacebookId:conversation.friendID
                                                                    withFacebookName:@""];
        [cachedConversations addObject:model];
    }];
    
    NSMutableArray *newConversations = [NSMutableArray new];
    [friendsArray enumerateObjectsUsingBlock:^(NSDictionary *frinedDict, NSUInteger idx, BOOL *stop){
        
//        NSString *name    = [NSString stringWithFormat:@"%@",[frinedDict objectForKey:@"name"]];
        NSString *frienId = [NSString stringWithFormat:@"%@",[frinedDict objectForKey:@"uid"]];
        FCConversationModel *model = [[FCConversationModel alloc] initWithFacebookId:frienId
                                                                    withFacebookName:@""];
        [newConversations addObject:model];
    }];
    
    
    NSSet *firstSet = [NSSet setWithArray:cachedConversations];
    NSMutableSet *secondSet = [NSMutableSet setWithArray:newConversations];
    
    
    NSLog(@"newConversations.count = %d", secondSet.count);
    [secondSet minusSet:firstSet];
    NSLog(@"AFTER MINUS newConversations.count = %d", secondSet.count);
    
    
    NSArray *afterMinusArray = [secondSet allObjects];
    if (afterMinusArray.count == 0) {
        if (completion)
            completion(@(YES), nil);
    }
    
    // Get the local context
    NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_contextForCurrentThread];
    [afterMinusArray enumerateObjectsUsingBlock:^(FCConversationModel *model, NSUInteger idx, BOOL *stop){
//        Conversation *conversation = [Conversation MR_createInContext:localContext];
//        conversation.facebookId = model.facebookId;
//        conversation.facebookName = model.facebookName;
//        conversation.badgeNumber = [NSNumber numberWithInt:0];
        FCFriends * account = [FCFriends MR_createInContext:localContext];
        account.friendID = model.facebookId;
    }];
    
    // Save the modification in the local context
    // With MagicalRecords 2.0.8 or newer you should use the MR_saveNestedContexts
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL sucess, NSError *error){
        if (sucess) {
            NSLog(@"GOOD");
            if (completion)
                completion(@(sucess), nil);
        }else {
            if (completion)
                completion(nil, error);
        }
    }];
}

- (void)saveContext
{
    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL sucess, NSError *error){
        if (sucess) {
            NSLog(@"GOOD");
        }else {
            NSLog(@"ERROR %@",error.userInfo);
        }
    }];
}


- (NSMutableArray *)fetchAllMessagesInConversation:(Conversation *)conversation
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sentDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	NSMutableArray *sortedMessages = [[NSMutableArray alloc] initWithArray:[conversation.messages allObjects]];
	[sortedMessages sortUsingDescriptors:sortDescriptors];
    return [NSMutableArray arrayWithArray:sortedMessages];
}

-(FCUserDescription *)fetchFCUserDescriptionByUID:(NSString * ) UserID
{
    NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"FCUserDescription" inManagedObjectContext:localContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    
    NSPredicate * qcmd = [NSPredicate predicateWithFormat:@"uid = %@ ",UserID];
    
    [fetch setPredicate:qcmd];
    
    NSArray * obs = [localContext executeFetchRequest:fetch error:nil];
    if (obs && obs.count > 0) {
        return (FCUserDescription * )obs[0];
    }
    return nil;
}

/**
 *  设置新用户信息
 *
 *  @param fcuserdesp object
 *  @param completion block
 */
- (void)setFCUserDescriptionObject:(FCUserDescription *) fcuserdesp withCompletion:(CompletionBlockTinkl) completion
{
    NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_contextForCurrentThread];
    FCUserDescription * newFcObj = [FCUserDescription MR_createInContext:localContext];
    newFcObj.uid  = fcuserdesp.uid;
    newFcObj.nick = fcuserdesp.nick;
    newFcObj.headpic = fcuserdesp.headpic;
    newFcObj.background_image = fcuserdesp.background_image;
    newFcObj.sex = fcuserdesp.sex;
    newFcObj.create_time = fcuserdesp.create_time;
    newFcObj.marriage = fcuserdesp.marriage;
    newFcObj.signature = fcuserdesp.signature;
    newFcObj.birthday = fcuserdesp.birthday;
    newFcObj.height = fcuserdesp.height;
    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL sucess, NSError *error){
        if (sucess) {
            NSLog(@"GOOD");
            if (completion)
                completion(newFcObj, nil);
        }else {
            if (completion)
                completion(newFcObj, error);
        }
    }];
}

/**
 *  by json to store db
 *
 *  @param fcuserdesp <#fcuserdesp description#>
 */
- (void)setFCUserObject:(LXUser *) fcuserdesp withCompletion:(CompletionBlockTinkl) completion
{
    FCUserDescription* old =  [self fetchFCUserDescriptionByUID:fcuserdesp.uid];
    if (old && [old.nick isEqualToString:fcuserdesp.nick] ) {
        
    }else{
        NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_contextForCurrentThread];
        FCUserDescription * newFcObj = [FCUserDescription MR_createInContext:localContext];
        newFcObj.uid  = fcuserdesp.uid;
        newFcObj.nick = fcuserdesp.nick;
        newFcObj.headpic = fcuserdesp.headpic;
        newFcObj.background_image = fcuserdesp.background_image;
        newFcObj.sex = @(fcuserdesp.sex);
        newFcObj.create_time = @(fcuserdesp.create_time);
        newFcObj.marriage = fcuserdesp.marriage;
        newFcObj.signature = fcuserdesp.signature;
        newFcObj.birthday = fcuserdesp.birthday;
        newFcObj.height = @(fcuserdesp.height);
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL sucess, NSError *error){
            if (sucess) {
                NSLog(@"GOOD");
                if (completion)
                    completion(newFcObj, nil);
            }else {
                if (completion)
                    completion(newFcObj, error);
            }
        }];
    }
    
}

- (void)setFriendsObject:(LXUser *) fcuserdesp
{
    //查看friend是否存在
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"friendID ==  %@",fcuserdesp.uid];
    NSArray * result = [FCFriends MR_findAllWithPredicate:pre];
    if (result && result.count > 0) {
    }else{
        NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
        FCFriends *newfriends = [FCFriends MR_createInContext:localContext];
        newfriends.friendID = fcuserdesp.uid;
        FCUserDescription * newFcObj =[FCUserDescription MR_createInContext:localContext];
        newFcObj.uid  = fcuserdesp.uid;
        newFcObj.nick = fcuserdesp.nick;
        newFcObj.headpic = fcuserdesp.headpic;
        newFcObj.background_image = fcuserdesp.background_image;
        newFcObj.sex = @(fcuserdesp.sex);
        newFcObj.create_time = @(fcuserdesp.create_time);
        newFcObj.marriage = fcuserdesp.marriage;
        newFcObj.signature = fcuserdesp.signature;
        newFcObj.birthday = fcuserdesp.birthday;
        newFcObj.height = @(fcuserdesp.height);
        newfriends.friendRelation = newFcObj;
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

/**
 *  fetch All User by uids
 */
-(NSArray * ) fetchAlAccounts
{
    return  [FCFriends MR_findAll];
//    
//    NSMutableArray * array = [[NSMutableArray alloc] init];
//    NSArray *cachedFriends = [FCAccount MR_findAll];
//    [cachedFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        FCAccount * account = obj;
//        [array addObject:account.userdesp];
//    }];
//    return array;
    //MARK Base fbid to find userdesp object,, if userdesp is nil, will select from networking
//    FCUserDescription * localdespObject =[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:self.facebookId];
//    if (localdespObject) {
//        return localdespObject;
//    }
    
}


@end