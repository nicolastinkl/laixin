
#import <CoreData/CoreData.h>

@interface FCMessage : NSManagedObject {

}

@property (nonatomic, strong) NSDate *sentDate;
@property (nonatomic, strong) NSNumber *read;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *messageStatus;
@end
