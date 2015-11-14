#import "CTTSnatchDelayers.h"
#import "CTTRunLoopRunUntil.h"

@implementation _CTTSnatchDelayers

- (_CTTSnatcher *(^)(void))none
{
    return ^(void) {
        self.snatcher.delayer = ^(void(^action)()){
            action();
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSTimeInterval))seconds
{
    return ^(NSTimeInterval delay_) {
        self.snatcher.delayer = ^(void(^action)(void)){
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, delay_, false);
            action();
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(BOOL (^)(void)))until
{
    return ^(BOOL (^fulfilled_)(void)){
        self.snatcher.delayer = ^(void(^action)(void)) {
            if(CTTRunLoopRunUntil(fulfilled_)) {
                action();
            }
        };
        return self.snatcher;
    };
}

@end
