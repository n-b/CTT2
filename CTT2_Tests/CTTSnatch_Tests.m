//
//  CTTRequestSnatcher_Tests.m
//  CTT2
//
//  Created by Nicolas Bouilleaud on 09/12/2014.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CTTSnatch.h"

@interface CTTSnatch_Tests : XCTestCase
@end

@interface Demo : NSObject
@property id result;
@end

@implementation Demo
{
    NSString* _host;
}

- (instancetype) initWithHost:(NSString*)host_
{
    self = [super init];
    if (self) {
        _host = host_;
    }
    return self;
}

- (void) request:(NSString*)path_
{
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSString * urlString = [NSString stringWithFormat:@"http://%@/%@",_host, path_];
    NSData * data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                          returningResponse:&response error:&error];
    self.result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL][path_];
}

@end


// response: error or data, status, headers

// mocking, filtering and verification are distinct operations

@implementation CTTSnatch_Tests

- (void) test_demo_mockedResponse
{
    // Mock the response for all the requests in the test
    [[[self ctt_snatch] snatchURL:@"http://host.com/foos"] respondWithJSON:@{@"foos":@42}];
    [[[self ctt_snatch] snatchURL:@"http://host.com/bars"] respondWithJSON:@{@"bars":@43}];

    [[[self ctt_snatch] snatchURL:@"http://host.com/baz"] respondWithJSON:@{@"baz":@43}];

    Demo* demo = [[Demo alloc] initWithHost:@"host.com"];

    [demo request:@"foos"];
    XCTAssertEqualObjects(demo.result, @42);

    [demo request:@"bars"];
    XCTAssertEqualObjects(demo.result, @43);
    
    XCTAssertThrows([self ctt_verify]);
}

- (void) test_demo_mockedResponsesForSpecifcRequests
{
    // Mock the response differently depending on the request
}

- (void) test_demo_verifyRequestIsSent
{
    // Check attributes of the request, fail the test if the attributes don’t match.
}

- (void) test_demo_verifySeveralRequests
{
    // Check several requests are made in order
}

- (void)test_ExampleOfRealTest
{
    // given
    // mock server response
//a    CTTSnatcher.snatchRequest(@"http://host.com/path").respondWithJSONData(@42);
//b    CTTSnatcher.respondToAllWithJSONData(@42);
//c    CTTSnatch.autoRespondWithFiles(); // use files saved previously with CTTSnatch.logAllRequests()
    
    // when
    // calling a system that performs a request and analyses its response
//    id demo = [DemoObject new];
//    [demo askForFoos];
    
    // then
    // the request has been made
//a    CTTSnatcher.verifyAll();
//b    CTTSnatcher.verifyRequest(@"http://host.com/path");
//c

    // the response has been correctly analysed
//    XCTAssertEqual([demo fooCount], 42);
    
    // features
    
    // response mocking
    //   of data, status, headers, and error
    // filtered mocking
    //   depending on the request path/host/post data/custom block
    //   this is kinda broken with NSURLSession, as the post data isn’t set, and headers are missing
    // registration and passthrough
    
    // verification of the requests a posteriori
    //   including all the data this time
    //   including order of the requests
    
    // automatic deregistration at the end of the test

    // recording of all requests during regular sessions
    // automatic replay of recorded responses
}

@end
