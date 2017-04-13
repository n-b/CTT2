#import "CTTSnatcher.h"

@interface _CTTSnatchMatchers : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher*(^url)(id urlOrString);
@property (readonly) _CTTSnatcher*(^regexp)(id regexpOrString);
@property (readonly) _CTTSnatcher*(^any)(void);
@end

