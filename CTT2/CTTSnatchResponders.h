#import "CTTSnatcher.h"

@interface _CTTSnatchResponders : _CTTSnatcherHelper
@property (readonly) _CTTSnatcher*(^nothing)(void);
@property (readonly) _CTTSnatcher*(^error)(NSError* error_);
@property (readonly) _CTTSnatcher*(^http)(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_);
@property (readonly) _CTTSnatcher*(^json)(id jsonObject_);
@property (readonly) _CTTSnatcher*(^file)(id fileName_);
@end
