#import "CTTSnatchLoggers.h"

@interface CTTURLLogger : CTTSnatchLogger
@end

@interface CTTHeadersLogger : CTTSnatchLogger
@end

@implementation _CTTSnatchLoggers

- (_CTTSnatcher *(^)(void))none
{
    return ^(void){
        self.snatcher.logger = ^(NSURL* url, NSUInteger counter){ return [[CTTSnatchLogger alloc] initWithURL:url counter:counter]; };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(void))urls
{
    return ^(void){
        self.snatcher.logger = ^(NSURL* url, NSUInteger counter){ return [[CTTURLLogger alloc] initWithURL:url counter:counter]; };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSString*))headers
{
    return ^(NSString* path){
        self.snatcher.logger = ^(NSURL* url, NSUInteger counter){ return [[CTTHeadersLogger alloc] initWithURL:url counter:counter]; };
        return self.snatcher;
    };
}

@end


@implementation CTTSnatchLogger
- (instancetype)initWithURL:(NSURL*)url counter:(NSUInteger)counter
{
    self = [super init];
    if (self) {
        self.url = url;
        self.counter = counter;
    }
    return self;
}
- (void)logRequest:(NSURLRequest*)request {}
- (void)logError:(NSError*)error {}
- (void)logResponse:(NSURLResponse*)response {}
- (void)logData:(NSData*)data {}
- (void)finish {}
@end

@implementation CTTURLLogger
- (void)logRequest:(NSURLRequest *)request
{
    NSLog(@"starting %@",request);
}
@end

@implementation CTTHeadersLogger
@end

