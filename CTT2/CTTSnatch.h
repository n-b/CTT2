@import Foundation;

@class _CTTSnatcher;

#pragma mark - Request Matching

@interface _CTTSnatchMatchers : NSObject
@property (readonly) _CTTSnatcher*(^url)(id urlOrString);
@property (readonly) _CTTSnatcher*(^regexp)(id regexpOrString);
@end

#pragma mark - Response

@interface _CTTSnatchResponders : NSObject
@property (readonly) _CTTSnatcher*(^nothing)(void);
@property (readonly) _CTTSnatcher*(^error)(NSError* error_);
@property (readonly) _CTTSnatcher*(^http)(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_);
@property (readonly) _CTTSnatcher*(^json)(id jsonObject_);
@end


#pragma mark - Snatcher

@interface _CTTSnatcher : NSObject

// CTTSnatch.new.match.URL(NSURL*).respond.JSON(id)

- (instancetype) init;

@property (readonly) _CTTSnatchMatchers* match;

@property (readonly) _CTTSnatchResponders* respond;

@property (readonly) _CTTSnatcher* (^delay)(NSTimeInterval delay_);

@property (readonly) NSUInteger hitCount;

- (void) stop;

// Counter

// - delay
//- (instancetype) times:(NSUInteger)count;
//- (instancetype) once;
//- (instancetype) forever;

//- (instancetype) passthrough;

@end

#define CTTSnatcher  ([[_CTTSnatcher alloc] init])


#pragma mark - XCUnit integration

@class XCTestCase;

@interface _CTTUnitTestSnatcher : _CTTSnatcher
- (instancetype) initWithTest:(XCTestCase *)test_ file:(const char *)file_ line:(int)line_;
- (BOOL) verify;
@end

#define CTTUnitTestSnatcher  ([[_CTTUnitTestSnatcher alloc] initWithTest:self file:__FILE__ line:__LINE__])

