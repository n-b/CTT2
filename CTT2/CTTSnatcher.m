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

- (_CTTSnatchLoggers *)log
{
    return [[_CTTSnatchLoggers alloc] initWithSnatcher:self];
}

- (void)hit
{
    ++_hitCount;
}

- (NSUInteger) counter
{
    static NSUInteger counter = 0;
    return counter++;
}

- (void)respond:(NSURLProtocol*)protocol_
{
    [self hit];
    NSUInteger counter = [self counter];
    self.requestLogger(protocol_.request, counter);
    self.delayer(^{
        self.responder(protocol_);
        self.responseLogger(protocol_.response, counter);
    });
    if(self.stopper()) {
        [self stopNow];
    }
}

@end
