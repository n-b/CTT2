@import Foundation;

#pragma mark - Request Matching
#define SNATCH_OVERLOADABLE __attribute__((overloadable))

typedef BOOL (^RequestMatcher)(NSURLRequest *);
RequestMatcher SNATCH_OVERLOADABLE Matcher(NSURL* url_);
RequestMatcher SNATCH_OVERLOADABLE Matcher(NSString* urlString_);
RequestMatcher SNATCH_OVERLOADABLE Matcher(NSRegularExpression* regexp_);


#pragma mark - Response

typedef void (^RequestResponder)(NSURLProtocol*);
RequestResponder SNATCH_OVERLOADABLE Responder(void);
RequestResponder SNATCH_OVERLOADABLE Responder(NSError* error_);
RequestResponder SNATCH_OVERLOADABLE Responder(NSTimeInterval delay_, RequestResponder responder_);
RequestResponder SNATCH_OVERLOADABLE Responder(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_);
RequestResponder SNATCH_OVERLOADABLE Responder(id jsonObject);



#pragma mark - Snatcher

@class CTTSnatchResponse;

@interface CTTSnatch : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithMatcher:(RequestMatcher)matcher_ NS_DESIGNATED_INITIALIZER;

@property (readonly) RequestMatcher matcher;
@property (readonly) NSUInteger hitCount;
- (void) stop;

- (instancetype(^)(RequestResponder))respondWith;

// Counter

//- (instancetype) times:(NSUInteger)count;
//- (instancetype) once;
//- (instancetype) forever;

//- (instancetype) passthrough;

@end


#pragma mark - XCUnit integration

@class XCTestCase;

@interface UnitTestSnatch : CTTSnatch
- (instancetype) initWithMatcher:(RequestMatcher)matcher_ test:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_;
- (BOOL) verify;
@end

#define CTTUnitTestSnatch(matcher)  ([[UnitTestSnatch alloc] initWithMatcher:matcher test:self file:__FILE__ line:__LINE__])

