
#import <CoreData/CoreData.h>

enum messageStutes_type {
    messageStutes_incoming = 1,
    messageStutes_outcoming = 2,
    messageStutes_error = 3,
    };

@class FCMessage;
@class FCAccount;
@interface Conversation : NSManagedObject {

}

@property (nonatomic, strong) id lastMessage;
@property (nonatomic, strong) NSSet *messages;
@property (nonatomic, strong) NSString *facebookName;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSNumber *badgeNumber;
@property (nonatomic, strong) NSNumber *messageStutes;
@property (nonatomic, strong) NSNumber *messageType;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSDate   *lastMessageDate;

@property (nonatomic, retain)  FCAccount *account;
- (void)addMessagesObject:(FCMessage *)value;
- (void)removeMessagesObject:(FCMessage *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end
