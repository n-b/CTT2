@import XCTest;

#import "CTT.h"

@interface CTTSnatch_Tests : XCTestCase
@end

@implementation CTTSnatch_Tests

id SendDemoRequest(NSString* urlString, NSString * path) {
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL][path];
}

- (void) test_demo_mockResponse
{
    CTT.snatch.stop.afterTest(self).match.url(@"http://host.com/foo").respond.json(@{@"bar":@42}).log.urls();
    XCTAssertEqualObjects(SendDemoRequest(@"http://host.com/foo", @"bar"), @42);
}

- (void) test_demo_verifyRequestIsSent
{
    id snatch = CTTSnatchForXCTest(self).match.url(@"http://host.com/foo");
    SendDemoRequest(@"http://host.com/foo", @"");
    [snatch verify];
}

- (void) test_demo_archive
{
    CTT.snatch
    .stop.afterTest(self)
    .match.url(@"http://host.com/foo")
    .respond.json(@{@"bar":@42})
    .log.archive([NSProcessInfo.processInfo.environment[@"SIMULATOR_HOST_HOME"] stringByAppendingPathComponent:@"Desktop/demo"]);

    SendDemoRequest(@"http://host.com/foo", @"");
    SendDemoRequest(@"http://host.com/foo", @"");
    SendDemoRequest(@"http://host.com/foo", @"");
    SendDemoRequest(@"http://host.com/foo", @"");
}

@end
