//
//  FCAccount.m
//  FacebookChat
//
//  Created by Kanybek Momukeev on 8/3/13.
//
//

#import "FCAccount.h"
#import <CoreData/NSManagedObject.h>


@implementation FCAccount

@dynamic facebookId;
@dynamic name;
@dynamic conversation;
@synthesize userdesp;

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
    
    return nil;
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

- (void)setFCUserDescriptionsObject:(FCUserDescription*)value_
{

}
- (void)FCUserDescriptionsObject:(FCUserDescription*)value_
{
    
}

@end

@implementation FCAccountID


@end














