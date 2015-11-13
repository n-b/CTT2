#import <XCTest/XCTest.h>
#import "CTTSnatch.h"

@interface CTTSnatch_Tests : XCTestCase
@end

@implementation CTTSnatch_Tests

id SendDemoRequest(NSString* urlString, NSString * path) {
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL][path];
}

- (void) test_demo_mockResponse
{
    [CTTUnitTestSnatch(URLMatcher(@"http://host.com/foo")) respondWith:[[CTTSnatchResponse alloc] initWithJSON:@{@"bar":@42}]];

    XCTAssertEqualObjects(SendDemoRequest(@"http://host.com/foo", @"bar"), @42);
}

- (void) test_demo_verifyRequestIsSent
{
    id snatch = CTTUnitTestSnatch(URLMatcher(@"http://host.com/foo"));
    
    SendDemoRequest(@"http://host.com/foo", @"");
    
    [snatch verify];
}

@end
