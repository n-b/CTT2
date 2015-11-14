@import Foundation;

@class _CTTSnatchMatchers, _CTTSnatchResponders;

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



@interface _CTTSnatcher ()

typedef BOOL (^CTTSnatchMatcher)(NSURLRequest *);
@property (copy) CTTSnatchMatcher matcher;

typedef void (^CTTSnatchResponder)(NSURLProtocol*);
@property (copy) CTTSnatchResponder responder;

@property NSTimeInterval delayer;

- (void) respond:(NSURLProtocol*)protocol_;
@end


@interface _CTTSnatcherHelper : NSObject
@property (readonly) _CTTSnatcher * snatcher;
@end
