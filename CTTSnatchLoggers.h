#import "CTTSnatcher.h"

@interface _CTTSnatchLoggers : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher* (^none)(void);
@property (readonly) _CTTSnatcher* (^urls)(void);
@property (readonly) _CTTSnatcher* (^headers)(NSString* path);
@property (readonly) _CTTSnatcher* (^archive)(NSString* directory);
@end
