//
//  FCAccount.h
//  FacebookChat
//
//  Created by Kanybek Momukeev on 8/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FCAccountID :NSManagedObjectID
{
    
}
@end
@class FCUserDescription;
@interface FCAccount : NSManagedObject

@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *conversation;
@property (nonatomic, retain) FCUserDescription *fcindefault;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FCAccountID*)objectID;
@end

@interface FCAccount (CoreDataGeneratedAccessors)

- (void)addConversationObject:(NSManagedObject *)value;
- (void)removeConversationObject:(NSManagedObject *)value;
- (void)addConversation:(NSSet *)values;
- (void)removeConversation:(NSSet *)values;

@end
