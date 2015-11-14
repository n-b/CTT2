#import "CTTSnatcher.h"

@interface _CTTSnatchProtocol : NSURLProtocol
+ (void)addSnatcher:(_CTTSnatcher*)snatcher_;
+ (void)removeSnatcher:(_CTTSnatcher*)snatcher_;
@end
