#import "CTT.h"


const _CTT * CTT;

static __attribute__((constructor)) void _CTTInitialize(void)
{
    CTT = [_CTT new];
};


@implementation _CTT

- (_CTTSnatcher*) snatch
{
    return [[_CTTSnatcher alloc] init];
}

@end