#import "CTTSnatcher.h"

#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchProtocol.h"

@interface _CTTSnatcherHelper ()
@property _CTTSnatcher * snatcher;
@end
@implementation _CTTSnatcherHelper
@end

@implementation _CTTSnatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.match.regexp(@".*");
        self.delay.none();
        self.respond.nothing();
        [_CTTSnatchProtocol addSnatcher:self];
    }
    return self;
}

- (void)stop
{
    [_CTTSnatchProtocol removeSnatcher:self];
}

- (_CTTSnatchMatchers*)match
{
    _CTTSnatchMatchers * m = [_CTTSnatchMatchers new]; m.snatcher = self;
    return m;
}

- (_CTTSnatchResponders *)respond
{
    _CTTSnatchResponders * r = [_CTTSnatchResponders new]; r.snatcher = self;
    return r;
}

- (_CTTSnatchDelayers *)delay
{
    _CTTSnatchDelayers * s = [_CTTSnatchDelayers new]; s.snatcher = self;
    return s;
}

- (void)hit
{
    ++_hitCount;
}

- (BOOL)shouldSnatch:(NSURLRequest*)req
{
    BOOL hit = self.matcher(req);
    if(hit) { ++_hitCount; }
    return hit;
}

- (void)respond:(NSURLProtocol*)protocol_
{
    [self hit];
    self.delayer(^{self.responder(protocol_);});
}

@end
