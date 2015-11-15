#import "CTTSnatchStoppers.h"

@import XCTest;
@import ObjectiveC;

@interface _CTTSnatchStoppers () <XCTestObservation> // I would have declared protocol conformance in a category, but XCTestObservationCenter checks for conformance at runtime. Seriously, who does that?
@end

@implementation _CTTSnatchStoppers

- (_CTTSnatcher*(^)(void))never
{
    return ^(void){
        self.snatcher.stopper = ^() {
            return NO;
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher*(^)(NSUInteger))afterHits
{
    return ^(NSUInteger count_){
        self.snatcher.stopper = ^() {
            return (BOOL)(self.snatcher.hitCount>=count_);
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher*(^)(BOOL(^)(void)))when
{
    return ^(BOOL(^condition_)(void)){
        self.snatcher.stopper = ^() {
            return condition_();
        };
        return self.snatcher;
    };
}

@end


@implementation _CTTSnatchStoppers (XCTestSupport)

- (_CTTSnatcher*(^)(XCTestCase*))afterTest
{
    return ^(XCTestCase* test_){
        objc_setAssociatedObject(self, @selector(afterTest), test_, OBJC_ASSOCIATION_RETAIN);
        [XCTestObservationCenter.sharedTestObservationCenter addTestObserver:self]; // retains
        self.snatcher.stopper = ^() { return NO; };
        return self.snatcher;
    };
}

- (void)testCaseDidFinish:(XCTestCase *)testCase_
{
    if (testCase_==objc_getAssociatedObject(self, @selector(afterTest))) {
        [self.snatcher stopNow];
        self.snatcher.stopper = ^() { return YES; };
        dispatch_async(dispatch_get_main_queue(), ^{
            // Ugly hack. We’re removing ourselves from the observers list, which is implemented by XCTestObservationCenter as an NSMutableSet.
            // It calls the observers using a for..in loop, which means we would be mutating the collection being enumerated.
            [XCTestObservationCenter.sharedTestObservationCenter removeTestObserver:self];
        });
    }
}

@end
