#import "CTTSnatchProtocol.h"

@implementation _CTTSnatchProtocol

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
        [NSURLProtocol unregisterClass:self];
    }
}

+ (_CTTSnatcher*)snatcherForRequest:(NSURLRequest*)request_
{
    for (_CTTSnatcher * snatcher in CTTSnatchers) {
        if(snatcher.matcher(request_)) {
            return snatcher;
        }
    }
    return nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [self snatcherForRequest:request]!=nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    // mandatory implementation for NSURLProtocol
    return request;
}

- (void) startLoading
{
    _CTTSnatcher * snatcher = [self.class snatcherForRequest:self.request];
    [snatcher respond:self];
}

- (void)stopLoading
{
    // mandatory implementation for NSURLProtocol
}

@end

