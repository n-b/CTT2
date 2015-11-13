#import "CTTSnatch.h"

#pragma mark - Request Matching

RequestMatcher __attribute__((overloadable)) URLMatcher(NSURL* url_) {
    return ^(NSURLRequest * req) { return [req.URL isEqual:url_]; };
}
RequestMatcher __attribute__((overloadable)) URLMatcher(NSString* urlString_) {
    return ^(NSURLRequest * req) { return [req.URL.absoluteString isEqualToString:urlString_]; };
}
RequestMatcher HostMatcher(NSString* host_) {
    return ^(NSURLRequest * req) { return [req.URL.host isEqualToString:host_]; };
}

#pragma mark - Snatch URLProtocol

@interface CTTSnatch ()
- (void) hit;
@property (readonly) NSUInteger hitCount;
@property (readonly) CTTSnatchResponse * response;
@end

CTTSnatch* CTTSnatcherForRequest(NSURLRequest* request);

@interface CTTSnatchProtocol : NSURLProtocol
@end

@implementation CTTSnatchProtocol

// mandatory implementation for NSURLProtocol
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request { return request; }
- (void)stopLoading { }

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return CTTSnatcherForRequest(request)!=nil;
}

- (void) startLoading
{
    CTTSnatch * snatch = CTTSnatcherForRequest(self.request);
    [snatch hit];
    CTTSnatchResponse * response = [snatch response];
    if(response.error) {
        [self.client URLProtocol:self didFailWithError:response.error];
        return;
    }

    if(response.delay) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, response.delay, false);
    }

    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:response.statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:response.headers];
    [self.client URLProtocol:self didReceiveResponse:urlResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:response.data];
    
    if(response.saveCookies) {
        NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:urlResponse.allHeaderFields forURL:self.request.URL];
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies
                                                         forURL:self.request.URL
                                                mainDocumentURL:self.request.URL];
    }
    [self.client URLProtocolDidFinishLoading:self];
}

@end

#pragma mark - Snatcher Store

static NSMutableArray * CTTSnatchers;

void CTTSnatcherAdd(CTTSnatch* snatcher_)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CTTSnatchers = [NSMutableArray new];
    });
    if(CTTSnatchers.count==0) {
        [NSURLProtocol registerClass:CTTSnatchProtocol.class];
    }
    [CTTSnatchers addObject:snatcher_];
}

void CTTSnatcherRemove(CTTSnatch* snatcher_)
{
    [CTTSnatchers removeObject:snatcher_];
    if(CTTSnatchers.count==0) {
        [NSURLProtocol unregisterClass:CTTSnatchProtocol.class];
    }
}

CTTSnatch* CTTSnatcherForRequest(NSURLRequest* request)
{
    for (CTTSnatch * snatcher in CTTSnatchers) {
        if(snatcher.matcher(request)) {
            return snatcher;
        }
    }
    return nil;
}

#pragma mark - CTTSnatch

@implementation CTTSnatch
{
    RequestMatcher _matcher;
    CTTSnatchResponse * _response;
}

- (instancetype)initWithMatcher:(RequestMatcher)matcher_
{
    self = [super init];
    if (self) {
        _matcher = [matcher_ copy];
        _response = [CTTSnatchResponse new];
        
        CTTSnatcherAdd(self);
    }
    return self;
}

- (void)stop
{
    CTTSnatcherRemove(self);
}

- (void)hit
{
    ++_hitCount;
}

- (BOOL)shouldSnatch:(NSURLRequest*)req
{
    BOOL hit = _matcher(req);
    if(hit) { ++_hitCount; }
    return hit;
}

- (void) respondWith:(CTTSnatchResponse*)response_
{
    _response = response_;
}

@end

#pragma mark - Response

@implementation CTTSnatchResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.statusCode = 200;
        self.headers = @{};
        self.saveCookies = YES;
    }
    return self;
}

- (instancetype)initWithJSON:(id)jsonObject
{
    self = [self init];
    if(self) {
        self.data = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL];
        NSMutableDictionary * headers = [NSMutableDictionary dictionaryWithDictionary:self.headers];
        [headers addEntriesFromDictionary:@{ @"Content-Type": @"application/json; charset=utf-8" }];
        self.headers = headers;
    }
    return self;
}

@end


#pragma mark - XCUnit integration

@import XCTest;

@interface UnitTestSnatch () <XCTestObservation>
@end

@implementation UnitTestSnatch
{
    XCTestCase * _test;
    const char * _file;
    int _line;
}

- (instancetype)initWithMatcher:(RequestMatcher)matcher_ test:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_
{
    self = [super initWithMatcher:matcher_];
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
        [XCTestObservationCenter.sharedTestObservationCenter removeTestObserver:self]; // This crashes sometimes, XCTestObservationCenter doesn’t support mutating its list.
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
