#import "CTTSnatchMatchers.h"

@implementation _CTTSnatchMatchers

- (_CTTSnatcher *(^)(id urlOrString))url
{
    return ^(id urlOrString_){
        self.snatcher.matcher = ^(NSURLRequest * req) {
            id url = urlOrString_;
            if([url isKindOfClass:NSString.class]) {
                url = [NSURL URLWithString:url];
            }
            if(![url isKindOfClass:NSURL.class]) {
                return NO;
            }
            return [req.URL isEqual:url];
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(id regexpOrString))regexp
{
    return ^(id regexpOrString_){
        self.snatcher.matcher = ^(NSURLRequest * req) {
            id regexp = regexpOrString_;
            if([regexp isKindOfClass:NSString.class]) {
                regexp = [NSRegularExpression regularExpressionWithPattern:regexp options:0 error:NULL];
            }
            if(![regexp isKindOfClass:NSRegularExpression.class]) {
                return NO;
            }
            NSString * url = req.URL.absoluteString;
            NSUInteger count = [regexp numberOfMatchesInString:url options:0 range:NSMakeRange(0, url.length)];
            return (BOOL)(count>0);
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(void))any
{
    return ^(void){
        self.snatcher.matcher = ^(NSURLRequest * req) {
            return YES;
        };
        return self.snatcher;
    };
}

@end
