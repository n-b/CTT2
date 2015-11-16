@import Foundation;

@class _CTTSnatchMatchers, _CTTSnatchDelayers, _CTTSnatchResponders, _CTTSnatchStoppers, _CTTSnatchLoggers;

@interface _CTTSnatcher : NSObject

@property (readonly) _CTTSnatchMatchers* match;
@property (readonly) _CTTSnatchDelayers* delay;
@property (readonly) _CTTSnatchResponders* respond;
@property (readonly) _CTTSnatchStoppers* stop;
@property (readonly) _CTTSnatchLoggers* log;

@property (readonly) NSUInteger hitCount;

- (void) stopNow;

@end


@interface _CTTSnatcher ()

typedef BOOL (^_CTTSnatchMatcher)(NSURLRequest *);
@property (copy) _CTTSnatchMatcher matcher;

typedef void (^_CTTSnatchDelayer)(void(^)(void));
@property (copy) _CTTSnatchDelayer delayer;

typedef void (^_CTTSnatchResponder)(NSURLProtocol*);
@property (copy) _CTTSnatchResponder responder;

typedef BOOL (^_CTTSnatchStopper)(void);
@property (copy) _CTTSnatchStopper stopper;

typedef void (^_CTTSnatchRequestLogger)(NSURLRequest*, NSUInteger tag);
@property (copy) _CTTSnatchRequestLogger requestLogger;
typedef void (^_CTTSnatchResponseLogger)(NSURLResponse*, NSUInteger tag);
@property (copy) _CTTSnatchResponseLogger responseLogger;

- (void) respond:(NSURLProtocol*)protocol_;
@end


@interface _CTTSnatcherHelper : NSObject
@property (readonly) _CTTSnatcher * snatcher;
@end
