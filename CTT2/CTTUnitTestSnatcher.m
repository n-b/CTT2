#import "CTTUnitTestSnatcher.h"

#pragma mark - XCUnit integration

@import XCTest;

@interface _CTTUnitTestSnatcher () <XCTestObservation>
@end

@implementation _CTTUnitTestSnatcher
{
    XCTestCase * _test;
    const char * _file;
    int _line;
}

- (instancetype)initWithTest:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_
{
    self = [super init];
    if(self) {
        _test = test_;
        _file = file_;
        _line = line_;
        
        [XCTestObservationCenter.sharedTestObservationCenter addTestObserver:self];
    }
    return self;
}

- (void)testCaseDidFinish:(XCTestCase *)testCase
{
    if (testCase==_test) {
        [self stop];
        //        [XCTestObservationCenter.sharedTestObservationCenter removeTestObserver:self]; // This crashes sometimes, XCTestObservationCenter doesn’t support mutating its list.
    }
}

- (BOOL)verify
{
    BOOL verified = self.hitCount != 0;
    if (!verified && _test) {
        _XCTFailureHandler(_test, YES, _file, _line, @"Snatcher not hit", nil);
    }
    return verified;
}

@end
