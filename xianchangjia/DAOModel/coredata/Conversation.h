
#import <CoreData/CoreData.h>

@class FCMessage;

@interface Conversation : NSManagedObject {

}

@property (nonatomic, strong) id lastMessage;
@property (nonatomic, strong) NSSet *messages;
@property (nonatomic, strong) NSString *facebookName;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSNumber *badgeNumber;

- (void)addMessagesObject:(FCMessage *)value;
- (void)removeMessagesObject:(FCMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end
