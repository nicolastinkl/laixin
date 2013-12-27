
#import <CoreData/CoreData.h>

@class FCMessage;
@class FCAccount;
@interface Conversation : NSManagedObject {

}

@property (nonatomic, strong) id lastMessage;
@property (nonatomic, strong) NSSet *messages;
@property (nonatomic, strong) NSString *facebookName;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSNumber *badgeNumber;
@property (nonatomic, retain)  FCAccount *account;
- (void)addMessagesObject:(FCMessage *)value;
- (void)removeMessagesObject:(FCMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end
