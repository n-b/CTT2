#import "CTTSnatcher.h"

@interface _CTTSnatchDelayers : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher*(^none)(void);
@property (readonly) _CTTSnatcher*(^seconds)(NSTimeInterval delay);
@property (readonly) _CTTSnatcher*(^until)(BOOL(^fulfilled_)(void));
@end
