#import "CTTSnatch.h"


@interface _CTTSnatcher ()
typedef BOOL (^CTTSnatchMatcher)(NSURLRequest *);
@property (copy) CTTSnatchMatcher matcher;

typedef void (^CTTSnatchResponder)(NSURLProtocol*);
@property (copy) CTTSnatchResponder responder;

@property NSTimeInterval delayer;

- (void) respond:(NSURLProtocol*)protocol_;
@end



#pragma mark - Request Matching

@implementation _CTTSnatchMatchers
{
    _CTTSnatcher* _snatcher;
}

- (instancetype)initWithSnatcher:(_CTTSnatcher*)snatcher_
{
    self = [super init];
    if (self) {
        _snatcher = snatcher_;
    }
    return self;
}

- (_CTTSnatcher *(^)(id urlOrString))url
{
    return ^(id urlOrString_){
        _snatcher.matcher = ^(NSURLRequest * req) {
            id url = urlOrString_;
            if([url isKindOfClass:NSString.class]) {
                url = [NSURL URLWithString:url];
            }
            if(![url isKindOfClass:NSURL.class]) {
                return NO;
            }
            return [req.URL isEqual:url];
        };
        return _snatcher;
    };
}

- (_CTTSnatcher *(^)(id regexpOrString))regexp
{
    return ^(id regexpOrString_){
        _snatcher.matcher = ^(NSURLRequest * req) {
            id regexp = regexpOrString_;
            if([regexp isKindOfClass:NSString.class]) {
                regexp = [NSRegularExpression regularExpressionWithPattern:regexp options:0 error:NULL];
            }
            if(![regexp isKindOfClass:NSRegularExpression.class]) {
                return NO;
            }
            NSString * url = req.URL.absoluteString;
            NSUInteger count = [regexp numberOfMatchesInString:url options:0 range:NSMakeRange(0, url.length)];
            return (BOOL)(count>0);
        };
        return _snatcher;
    };
}

@end



#pragma mark - Response

@implementation _CTTSnatchResponders
{
    _CTTSnatcher* _snatcher;
}

- (instancetype)initWithSnatcher:(_CTTSnatcher*)snatcher_
{
    self = [super init];
    if (self) {
        _snatcher = snatcher_;
    }
    return self;
}

- (_CTTSnatcher *(^)(void))nothing
{
    return ^(void){
        _snatcher.responder = ^(NSURLProtocol * protocol) {
            [protocol.client URLProtocolDidFinishLoading:protocol];
        };
        return _snatcher;
    };
}

- (_CTTSnatcher *(^)(NSError *))error
{
    return ^(NSError * error_){
        _snatcher.responder = ^(NSURLProtocol * protocol) {
            [protocol.client URLProtocol:protocol didFailWithError:error_];
        };
        return _snatcher;
    };
}

CTTSnatchResponder CTTSnatchResponderHTTP(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_)
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

- (_CTTSnatcher *(^)(NSInteger, NSDictionary *, NSData *, BOOL))http
{
    return ^(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_){
        _snatcher.responder = CTTSnatchResponderHTTP(statusCode_, headers_, data_,saveCookies_);
        return _snatcher;
    };
}

- (_CTTSnatcher *(^)(id))json
{
    return ^(id jsonObject_) {
        NSData * data = [NSJSONSerialization dataWithJSONObject:jsonObject_ options:NSJSONWritingPrettyPrinted error:NULL];
        NSDictionary * headers = @{ @"Content-Type": @"application/json; charset=utf-8" };
        _snatcher.responder = CTTSnatchResponderHTTP(200, headers, data, NO);
        return _snatcher;
    };
}

@end


#pragma mark - Snatch URLProtocol

@interface CTTSnatchProtocol : NSURLProtocol
@end

@implementation CTTSnatchProtocol

static NSMutableArray<_CTTSnatcher*> *CTTSnatchers;
+ (void)initialize
{
    CTTSnatchers = [NSMutableArray new];
}

+ (void)addSnatcher:(_CTTSnatcher*)snatcher_
{
    if(CTTSnatchers.count==0) {
        [NSURLProtocol registerClass:self];
    }
    [CTTSnatchers addObject:snatcher_];
}

+ (void)removeSnatcher:(_CTTSnatcher*)snatcher_
{
    [CTTSnatchers removeObject:snatcher_];
    if(CTTSnatchers.count==0) {
        [NSURLProtocol unregisterClass:CTTSnatchProtocol.class];
    }
}

+ (_CTTSnatcher*) snatcherForRequest:(NSURLRequest*)request_
{
    for (_CTTSnatcher * snatcher in CTTSnatchers) {
        if(snatcher.matcher(request_)) {
            return snatcher;
        }
    }
    return nil;
}

// mandatory implementation for NSURLProtocol
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request { return request; }
- (void)stopLoading { }

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [self snatcherForRequest:request]!=nil;
}

- (void) startLoading
{
    _CTTSnatcher * snatcher = [self.class snatcherForRequest:self.request];
    [snatcher respond:self];
}

@end


#pragma mark - _CTTSnatcher

@implementation _CTTSnatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.match.regexp(@".*");
        self.delay(0);
        self.respond.nothing();
        [CTTSnatchProtocol addSnatcher:self];
    }
    return self;
}

- (void)stop
{
    [CTTSnatchProtocol removeSnatcher:self];
}

- (_CTTSnatchMatchers*)match
{
    return [[_CTTSnatchMatchers alloc] initWithSnatcher:self];
}

- (_CTTSnatchResponders *)respond
{
    return [[_CTTSnatchResponders alloc] initWithSnatcher:self];
}

- (_CTTSnatcher *(^)(NSTimeInterval))delay
{
    return ^(NSTimeInterval delay_) {

        self.delayer = delay_;
        return self;
    };
}

- (void)hit
{
    ++_hitCount;
}

- (BOOL)shouldSnatch:(NSURLRequest*)req
{
    BOOL hit = self.matcher(req);
    if(hit) { ++_hitCount; }
    return hit;
}

- (void)respond:(NSURLProtocol*)protocol_
{
    [self hit];
    if(self.delayer>0) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, self.delayer, false);
    }
    self.responder(protocol_);
}

@end



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
