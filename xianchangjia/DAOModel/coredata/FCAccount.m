//
//  FCAccount.m
//  FacebookChat
//
//  Created by Kanybek Momukeev on 8/3/13.
//
//

#import "FCAccount.h"
#import <CoreData/NSManagedObject.h>
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "MLNetworkingManager.h"
#import "FCUserDescription.h"

@implementation FCAccount

@dynamic facebookId;
@dynamic name;
@dynamic conversation;
@synthesize fcindefault;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
{
    NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FCAccount" inManagedObjectContext:moc_];
}
+ (NSString*)entityName
{
    return @"FCAccount";
}
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_
{
    NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FCAccount" inManagedObjectContext:moc_];
}
- (FCAccountID*)objectID
{
    return (FCAccountID*)[super objectID];
}

-(FCUserDescription * )userdesp
{
    //MARK Base fbid to find userdesp object,, if userdesp is nil, will select from networking
   __block FCUserDescription * localdespObject = nil;
    
   localdespObject  =[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:self.facebookId];
    if (localdespObject) {
        return localdespObject;
    }else{
        //from networking by ID
        
        NSDictionary * parames = @{@"uid":@[self.facebookId]};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
            if (userArray && userArray.count > 0) {
                NSDictionary * dict = userArray[0];
                LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
                [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
                    localdespObject = response;
                }];
            }
        } failure:^(MLRequest *request, NSError *error) {
        }];
    }
    
    return localdespObject;
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	return keyPaths;
}

///
- (void)addConversationObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"conversation" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"conversation"] addObject:value];
    [self didChangeValueForKey:@"conversation" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeConversationObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"conversation" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"conversation"] removeObject:value];
    [self didChangeValueForKey:@"conversation" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addConversation:(NSSet *)values
{
    
}

- (void)removeConversation:(NSSet *)values
{
    
}


@end

@implementation FCAccountID


@end














