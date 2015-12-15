#import "CTTSnatcher.h"

#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchStoppers.h"
#import "CTTSnatchLoggers.h"

#import "CTTSnatchProtocol.h"

@interface _CTTSnatcherHelper ()
@property _CTTSnatcher * snatcher;
@end
@implementation _CTTSnatcherHelper
- (instancetype) initWithSnatcher:(_CTTSnatcher*)snatcher_
{
    self = [super init];
    if(self) {
        self.snatcher = snatcher_;
    }
    return self;
}
@end


@interface _CTTSnatchResponseClient ()
@property NSURLProtocol * protocol;
@property CTTSnatchLogger * logger;
@end


@implementation _CTTSnatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.match.regexp(@".*");
        self.delay.none();
        self.respond.nothing();
        self.stop.never();
        self.log.none();
        [_CTTSnatchProtocol addSnatcher:self];
    }
    return self;
}

- (void)stopNow
{
    [_CTTSnatchProtocol removeSnatcher:self];
}

- (_CTTSnatchMatchers*)   match   { return [[_CTTSnatchMatchers   alloc] initWithSnatcher:self]; }
- (_CTTSnatchResponders*) respond { return [[_CTTSnatchResponders alloc] initWithSnatcher:self]; }
- (_CTTSnatchDelayers*)   delay   { return [[_CTTSnatchDelayers   alloc] initWithSnatcher:self]; }
- (_CTTSnatchStoppers*)   stop    { return [[_CTTSnatchStoppers   alloc] initWithSnatcher:self]; }
- (_CTTSnatchLoggers*)    log     { return [[_CTTSnatchLoggers    alloc] initWithSnatcher:self]; }

- (void)respond:(NSURLProtocol*)protocol_
{
    ++_hitCount;

    _CTTSnatchResponseClient * client = [_CTTSnatchResponseClient new];
    client.protocol = protocol_;
    client.logger = self.logger(protocol_.request.URL,self.hitCount);
    [client.logger logRequest:protocol_.request];
    
    self.delayer(^{
        self.responder(protocol_.request, client);
    });
    if(self.stopper()) {
        [self stopNow];
    }
}

@end

@implementation _CTTSnatchResponseClient

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) failWithError:(NSError*)error_
{
    [self.protocol.client URLProtocol:self.protocol didFailWithError:error_];
    [self.logger logError:error_];
}

- (void) sendResponse:(NSURLResponse*)response_
{
    [self.protocol.client URLProtocol:self.protocol didReceiveResponse:response_ cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.logger logResponse:response_];
}

- (void) sendData:(NSData*)data_
{
    [self.protocol.client URLProtocol:self.protocol didLoadData:data_];
    [self.logger logData:data_];
}

- (void) finish
{
    [self.protocol.client URLProtocolDidFinishLoading:self.protocol];
    [self.logger finish];
}

@end