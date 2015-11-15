@import Foundation;

#import "CTTRunLoopRunUntil.h"
#import "CTTSnatch.h"

@interface _CTT : NSObject
@property (readonly) _CTTSnatcher* snatch;
@end

extern const _CTT * CTT;
