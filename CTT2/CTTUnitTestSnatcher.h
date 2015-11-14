#import "CTTSnatcher.h"

@class XCTestCase;

@interface _CTTUnitTestSnatcher : _CTTSnatcher
- (instancetype) initWithTest:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_;
- (BOOL) verify;
@end


