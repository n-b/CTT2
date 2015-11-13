@import Foundation;

#pragma mark - Request Matching

typedef BOOL (^RequestMatcher)(NSURLRequest *);
RequestMatcher __attribute__((overloadable)) URLMatcher(NSURL* url_);
RequestMatcher __attribute__((overloadable)) URLMatcher(NSString* urlString_);
RequestMatcher HostMatcher(NSString* host_);


#pragma mark - Response

@interface CTTSnatchResponse : NSObject
@property NSError * error;			// nil
@property NSTimeInterval delay;		// 0
@property NSInteger statusCode; 	// 200
@property NSDictionary * headers; 	// @{}
@property NSData * data;			// nil
@property BOOL saveCookies;			// YES

- (instancetype) initWithJSON:(id)jsonObject;
@end


#pragma mark - Snatcher

@class CTTSnatchResponse;

@interface CTTSnatch : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithMatcher:(RequestMatcher)matcher NS_DESIGNATED_INITIALIZER;

@property (readonly) RequestMatcher matcher;
- (void) stop;

// Counter

//- (instancetype) times:(NSUInteger)count;
//- (instancetype) once;
//- (instancetype) forever;

//- (instancetype) passthrough;

- (void) respondWith:(CTTSnatchResponse*)response_;

@end


#pragma mark - XCUnit integration

@class XCTestCase;

@interface UnitTestSnatch : CTTSnatch
- (instancetype) initWithMatcher:(RequestMatcher)matcher_ test:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_;
- (BOOL) verify;
@end

#define CTTUnitTestSnatch(matcher)  ([[UnitTestSnatch alloc] initWithMatcher:matcher test:self file:__FILE__ line:__LINE__])

