#import "CTTSnatchLoggers.h"

@interface CTTSnatchArchiver : CTTSnatchLogger
- (instancetype)initWithDirectory:(NSString*)path_ URL:(NSURL*)url_ counter:(NSUInteger)counter_;
@property NSString* directory;
@end


@interface _CTTSnatchLoggers (CTTSnatchArchiver)
@property (readonly) _CTTSnatcher* (^archive)(NSString* directory);
@end