#import "CTTSnatcher.h"

#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchStoppers.h"
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

@implementation _CTTSnatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.match.regexp(@".*");
        self.delay.none();
        self.respond.nothing();
        self.stop.never();
        [_CTTSnatchProtocol addSnatcher:self];
    }
    return self;
}

- (void)stopNow
{
    [_CTTSnatchProtocol removeSnatcher:self];
}

- (_CTTSnatchMatchers*)match
{
    return [[_CTTSnatchMatchers alloc] initWithSnatcher:self];
}

- (_CTTSnatchResponders *)respond
{
    return [[_CTTSnatchResponders alloc] initWithSnatcher:self];
}

- (_CTTSnatchDelayers *)delay
{
    return [[_CTTSnatchDelayers alloc] initWithSnatcher:self];
}

- (_CTTSnatchStoppers *)stop
{
    return [[_CTTSnatchStoppers alloc] initWithSnatcher:self];
}

- (void)hit
{
    ++_hitCount;
}

- (void)respond:(NSURLProtocol*)protocol_
{
    [self hit];
    self.delayer(^{
        self.responder(protocol_);
    });
    if(self.stopper()) {
        [self stopNow];
    }
}

@end
