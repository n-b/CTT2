@import Foundation;

@class _CTTSnatchMatchers, _CTTSnatchDelayers, _CTTSnatchResponders, _CTTSnatchStoppers, _CTTSnatchLoggers;

@class _CTTSnatchResponseClient, CTTSnatchLogger;

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
typedef void (^_CTTSnatchDelayer)(void(^)(void));
typedef void (^_CTTSnatchResponder)(NSURLRequest *, _CTTSnatchResponseClient*);
typedef BOOL (^_CTTSnatchStopper)(void);
typedef CTTSnatchLogger* (^_CTTSnatchLogger)(NSURL*, NSUInteger);

@property (copy) _CTTSnatchMatcher matcher;
@property (copy) _CTTSnatchDelayer delayer;
@property (copy) _CTTSnatchResponder responder;
@property (copy) _CTTSnatchStopper stopper;
@property (copy) _CTTSnatchLogger logger;

- (void) respond:(NSURLProtocol*)protocol_;
@end


@interface _CTTSnatcherHelper : NSObject
@property (readonly) _CTTSnatcher * snatcher;
@end

@interface _CTTSnatchResponseClient : NSObject
- (void) failWithError:(NSError*)error_;
- (void) sendResponse:(NSURLResponse*)response_;
- (void) sendData:(NSData*)data_;
- (void) finish;
@end
