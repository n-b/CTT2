#import "CTTSnatcher.h"

@interface _CTTSnatchLoggers : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher* (^none)(void);
@property (readonly) _CTTSnatcher* (^urls)(void);
@property (readonly) _CTTSnatcher* (^headers)(NSString* path);
@end

@interface CTTSnatchLogger : NSObject
- (instancetype)initWithURL:(NSURL*)url counter:(NSUInteger)counter;
@property NSURL * url;
@property NSUInteger counter;
- (void)logRequest:(NSURLRequest*)request;
- (void)logError:(NSError*)error;
- (void)logResponse:(NSURLResponse*)response;
- (void)logData:(NSData*)data;
- (void)finish;
@end
