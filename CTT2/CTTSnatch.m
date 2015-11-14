#import "CTTSnatch.h"

#pragma mark - Request Matching

RequestMatcher SNATCH_OVERLOADABLE Matcher(NSURL* url_) {
    return ^(NSURLRequest * req) { return [req.URL isEqual:url_]; };
}
RequestMatcher SNATCH_OVERLOADABLE Matcher(NSString* urlString_) {
    return ^(NSURLRequest * req) { return [req.URL.absoluteString isEqualToString:urlString_]; };
}
RequestMatcher SNATCH_OVERLOADABLE Matcher(NSRegularExpression* regexp_) {
    return ^(NSURLRequest * req) {
        NSString * url = req.URL.absoluteString;
        NSUInteger count = [regexp_ numberOfMatchesInString:url options:0 range:NSMakeRange(0, url.length)];
        return (BOOL)(count>0);
    };
}

#pragma mark - Snatch URLProtocol

@interface CTTSnatch ()
- (void) respond:(NSURLProtocol*)protocol_;
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
    [snatch respond:self];
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
    RequestResponder _responder;
}

- (instancetype)initWithMatcher:(RequestMatcher)matcher_
{
    self = [super init];
    if (self) {
        _matcher = [matcher_ copy];
        _responder = Responder();
        CTTSnatcherAdd(self);
    }
    return self;
}

- (void)stop
{
    CTTSnatcherRemove(self);
}

- (instancetype(^)(RequestResponder))respondWith
{
    return ^(RequestResponder responder) {
        self->_responder = responder;
        return self;
    };
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

- (void)respond:(NSURLProtocol*)protocol_
{
    [self hit];
    _responder(protocol_);
}

@end

#pragma mark - Response

RequestResponder SNATCH_OVERLOADABLE Respond(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_)
{
    return ^(NSURLProtocol * protocol) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:protocol.request.URL
                                                                     statusCode:statusCode_
                                                                    HTTPVersion:@"HTTP/1.1"
                                                                   headerFields:headers_];
        [protocol.client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [protocol.client URLProtocol:protocol didLoadData:data_];
        
        if(saveCookies_) {
            NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:protocol.request.URL];
            [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies
                                                             forURL:protocol.request.URL
                                                    mainDocumentURL:protocol.request.URL];
        }
        [protocol.client URLProtocolDidFinishLoading:protocol];
    };
}

RequestResponder SNATCH_OVERLOADABLE Responder(void)
{
    return ^(NSURLProtocol * protocol) {
        [protocol.client URLProtocolDidFinishLoading:protocol];
    };
}

RequestResponder SNATCH_OVERLOADABLE Responder(id jsonObject)
{
    NSData * data = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL];
    NSDictionary * headers = @{ @"Content-Type": @"application/json; charset=utf-8" };
    return Respond(200, headers, data, NO);
}

RequestResponder SNATCH_OVERLOADABLE Responder(NSError* error_)
{
    return ^(NSURLProtocol * protocol) {
        [protocol.client URLProtocol:protocol didFailWithError:error_];
    };
}

RequestResponder SNATCH_OVERLOADABLE Responder(NSTimeInterval delay_, RequestResponder responder_)
{
    return ^(NSURLProtocol * protocol) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, delay_, false);
        responder_(protocol);
    };
}

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
