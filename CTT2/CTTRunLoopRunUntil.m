//
//  CTTRunLoopRunUntil.m
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 02/10/14.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

#import "CTTRunLoopRunUntil.h"

Boolean __attribute__((overloadable)) CTTRunLoopRunUntil(CFTimeInterval timeout_, Boolean polling_, Boolean(^fulfilled_)(void))
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

Boolean __attribute__((overloadable)) CTTRunLoopRunUntil(Boolean(^fulfilled_)(void))
{
    return CTTRunLoopRunUntil(1.0, false, fulfilled_);
}

Boolean __attribute__((overloadable)) CTTRunLoopRunUntilNotification(CFTimeInterval timeout_, Boolean polling_, NSString * name_, id object_, BOOL(^validation_)(NSNotification*))
{
    __block Boolean validated = false;
    __block id observation =
    [[NSNotificationCenter defaultCenter] addObserverForName:name_
                                                      object:object_
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         if (!validation_ || validation_(note)) { validated = true; }
     }];
    
    Boolean result = CTTRunLoopRunUntil(timeout_, polling_, ^{ return validated; });
    [[NSNotificationCenter defaultCenter] removeObserver:observation];
    return result;
}


Boolean __attribute__((overloadable)) CTTRunLoopRunUntilNotification(NSString * name_, id object_)
{
    return CTTRunLoopRunUntilNotification(1.0, false, name_, object_, nil);
}