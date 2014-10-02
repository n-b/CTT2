//
//  CTTRunLoopRunUntil.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 02/10/14.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

#import "CTTRunLoopRunUntil.h"

Boolean CTTRunLoopRunUntil(Boolean(^fulfilled_)(), Boolean polling_, CFTimeInterval timeout_)
{
    // Loop Observer Callback
    __block Boolean fulfilled = NO;
    void (^beforeWaiting) (CFRunLoopObserverRef observer, CFRunLoopActivity activity) =
    ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        assert(!fulfilled); //RunLoop should be stopped after condition is fulfilled.
        // Check Condition
        fulfilled = fulfilled_();
        if(fulfilled) {
            // Condition fulfilled: stop RunLoop now.
            CFRunLoopStop(CFRunLoopGetCurrent());
        } else if(polling_) {
            // Condition not fulfilled, and we are polling: prevent RunLoop from waiting and continue looping.
            CFRunLoopWakeUp(CFRunLoopGetCurrent());
        }
    };
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, true, 0, beforeWaiting);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // Run!
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout_, false);

    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);

    return fulfilled;
}
