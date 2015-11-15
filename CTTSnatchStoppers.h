#import "CTTSnatcher.h"

@class XCTestCase;

@interface _CTTSnatchStoppers : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher*(^never)(void);
@property (readonly) _CTTSnatcher*(^afterHits)(NSUInteger count);
@property (readonly) _CTTSnatcher*(^when)(BOOL(^condition_)(void));
@end


@class XCTestCase;

@interface _CTTSnatchStoppers (XCTestSupport)
@property (readonly) _CTTSnatcher*(^afterTest)(XCTestCase*);
@end
