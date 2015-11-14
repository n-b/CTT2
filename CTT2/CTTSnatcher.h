@import Foundation;

@class _CTTSnatchMatchers, _CTTSnatchDelayers, _CTTSnatchResponders;

@interface _CTTSnatcher : NSObject

// CTTSnatch.new.match.URL(NSURL*).respond.JSON(id)

- (instancetype) init;
@property (readonly) _CTTSnatchMatchers* match;
@property (readonly) _CTTSnatchDelayers* delay;
@property (readonly) _CTTSnatchResponders* respond;
@property (readonly) NSUInteger hitCount;

- (void) stop;

// Counter

//- (instancetype) times:(NSUInteger)count;
//- (instancetype) once;
//- (instancetype) forever;

//- (instancetype) passthrough;

@end


@interface _CTTSnatcher ()

typedef BOOL (^_CTTSnatchMatcher)(NSURLRequest *);
@property (copy) _CTTSnatchMatcher matcher;

typedef void (^_CTTSnatchDelayer)(void(^)(void));
@property (copy) _CTTSnatchDelayer delayer;

typedef void (^_CTTSnatchResponder)(NSURLProtocol*);
@property (copy) _CTTSnatchResponder responder;

- (void) respond:(NSURLProtocol*)protocol_;
@end


@interface _CTTSnatcherHelper : NSObject
@property (readonly) _CTTSnatcher * snatcher;
@end
