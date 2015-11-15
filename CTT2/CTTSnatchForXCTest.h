#import "CTTSnatcher.h"

#define CTTSnatchForXCTest(test)    [CTT.snatch.stop.afterTest(test) withXCTestContext:[[_CTTSnatcherTestContext alloc] initWithTest:test file:__FILE__ line:__LINE__]]

@interface _CTTSnatcher (XCTestSupport)
- (BOOL) verify; // Calls _XCTFailureHandler on failure
@end



@class XCTestCase;
@interface _CTTSnatcherTestContext : NSObject;
- (instancetype) initWithTest:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_;
@end

@interface _CTTSnatcher (_CTTSnatcherTestContext)
- (instancetype) withXCTestContext:(_CTTSnatcherTestContext*)context;
@end