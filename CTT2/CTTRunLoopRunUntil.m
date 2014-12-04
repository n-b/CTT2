//
//  CTTRunLoopRunUntil.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 02/10/14.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

#import "CTTRunLoopRunUntil.h"

BOOL __attribute__((overloadable)) CTTRunLoopRunUntil(NSTimeInterval timeout_, BOOL polling_, BOOL(^fulfilled_)(void))
{
    // Loop Observer Callback
    __block BOOL fulfilled = NO;
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
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, YES, 0, beforeWaiting);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // Run!
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout_, false);

    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);

    return fulfilled;
}

BOOL __attribute__((overloadable)) CTTRunLoopRunUntil(BOOL(^fulfilled_)(void))
{
    return CTTRunLoopRunUntil(1.0, NO, fulfilled_);
}

BOOL __attribute__((overloadable)) CTTRunLoopRunUntilNotification(NSTimeInterval timeout_, BOOL polling_, NSString * name_, id object_, BOOL(^validation_)(NSNotification*))
{
    __block BOOL validated = NO;
    __block id observation =
    [[NSNotificationCenter defaultCenter] addObserverForName:name_
                                                      object:object_
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         if (!validation_ || validation_(note)) { validated = YES; }
     }];
    
    BOOL result = CTTRunLoopRunUntil(timeout_, polling_, ^{ return validated; });
    [[NSNotificationCenter defaultCenter] removeObserver:observation];
    return result;
}


BOOL __attribute__((overloadable)) CTTRunLoopRunUntilNotification(NSString * name_, id object_)
{
    return CTTRunLoopRunUntilNotification(1.0, NO, name_, object_, nil);
}