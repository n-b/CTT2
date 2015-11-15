#import "CTTSnatchForXCTest.h"
@import ObjectiveC;
@import XCTest;

@interface _CTTSnatcherTestContext ()
@property XCTestCase * test;
@property const char * file;
@property int line;
@end

@implementation _CTTSnatcherTestContext
- (instancetype)initWithTest:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_
{
    self = [super init];
    if(self) {
        _test = test_;
        _file = file_;
        _line = line_;
    }
    return self;
}
@end

@implementation _CTTSnatcher (_CTTSnatcherTestContext)
- (instancetype) withXCTestContext:(_CTTSnatcherTestContext*)context
{
    objc_setAssociatedObject(self, @selector(withXCTestContext:), context, OBJC_ASSOCIATION_RETAIN);
    return self;
}
@end

@implementation _CTTSnatcher (XCTestSupport)
- (BOOL)verify
{
    BOOL verified = self.hitCount != 0;
    
    _CTTSnatcherTestContext * context = objc_getAssociatedObject(self, @selector(withXCTestContext:));
    if (context && !verified) {
        _XCTFailureHandler(context.test, YES, context.file, context.line, @"Snatcher not hit", nil);
    }
    return verified;
}
@end