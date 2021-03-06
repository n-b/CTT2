//
//  CTTRunLoopRunUntil_Tests.m
//  CTT2_Tests
//
//  Created by Nicolas Bouilleaud on 31/08/2014.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

@import XCTest;

#import "CTTRunLoopRunUntil.h"

@interface CTTRunLoopRunUntil_Tests : XCTestCase
@end

@implementation CTTRunLoopRunUntil_Tests
{
    void (^_work)(void);
    __block BOOL _workComplete;

    BOOL(^_fulfilled)(void);
    __block int _fulfilled_callCount;
    __block int _fulfilled_postWorkCallCount;
}

- (void)setUp
{
    [super setUp];
    
    // Setup a simple “worker task” block
    __weak typeof(self) wself = self;
    _workComplete = NO;
    _work = ^{
        __strong typeof(self) sself = wself;
        sself->_workComplete = YES;
    };
    
    // And a “until condition” block
    _fulfilled_callCount = 0;
    _fulfilled_postWorkCallCount = 0;
    _fulfilled = ^{
        __strong typeof(self) sself = wself;
        sself->_fulfilled_callCount++;
        if(sself->_workComplete) {
            sself->_fulfilled_postWorkCallCount++;
        }
        return sself->_workComplete;
    };
}

- (void)test_CTTRunLoopRunUntil_timeout
{
    // Given no work task
    
    // When running the runloop regularly (i.e. by waiting for input sources)
    BOOL ran = CTTRunLoopRunUntil(0.5, NO, _fulfilled);
    
    // Then
    XCTAssertFalse(ran, @"The operation shouldn't be reported as ran.");
    XCTAssertEqual(_fulfilled_callCount, 1, @"_fulfilled() should only be called once before running the runloop.");
    XCTAssertEqual(_fulfilled_postWorkCallCount, 0, @"_fulfilled() should only be called once before running the runloop.");
}


- (void)test_CTTRunLoopRunUntil_dispatchAsyncMainQueue
{
    // Given an asynchronous operation on the current queue
    dispatch_async(dispatch_get_main_queue(), _work);
    
    // When running the runloop regularly (i.e. by waiting for input sources)
    BOOL ran = CTTRunLoopRunUntil(0.5, NO, _fulfilled);
    
    // Then
    XCTAssertTrue(ran, @"_fulfilled() should be called after _work set the flag.");
    XCTAssertEqual(_fulfilled_callCount, 2, @"_fulfilled() should be called exactly twice: once before running the runloop, once just after _work.");
    XCTAssertEqual(_fulfilled_postWorkCallCount, 1, @"_fulfilled() should be called once after _work.");
}

- (void)test_CTTRunLoopRunUntil_dispatchOtherThread
{
    // Given an asynchronous operation on a background queue
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   _work);

    // When running the runloop regularly (i.e. by waiting for input sources)
    BOOL ran = CTTRunLoopRunUntil(0.5, NO, _fulfilled);
    
    // Then
    XCTAssertFalse(ran, @"_fulfilled() shouldn't be called after _work.");
    XCTAssertEqual(_fulfilled_callCount, 1, @"_fulfilled() should only be called once, before running the runloop.");
    XCTAssertEqual(_fulfilled_postWorkCallCount, 0, @"_fulfilled() shouldn’t be called after _work.");
}

- (void)test_CTTRunLoopRunUntil_dispatchOtherThread_polling
{
    // Given an asynchronous operation on a background queue
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   _work);
    
    
    // When running the runloop actively (i.e. by polling)
    BOOL ran = CTTRunLoopRunUntil(0.5, YES, _fulfilled);

    // Then
    XCTAssertTrue(ran, @"_fulfilled() should be called after _work set the flag.");
    XCTAssertGreaterThan(_fulfilled_callCount, 100, @"_fulfilled() should be called many times.");
    XCTAssertEqual(_fulfilled_postWorkCallCount, 1, @"_fulfilled() should be called once after _work.");
}

- (void)test_CTTRunLoopRunUntil_dispatchOtherThread_signaling
{
    // Given an asynchronous operation on a background queue, that signals its completion.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       _work();
                       CFRunLoopWakeUp(CFRunLoopGetMain());
                   }
                   );
    
    
    // When running the runloop regularly (i.e. by waiting for input sources)
    BOOL ran = CTTRunLoopRunUntil(0.5, NO, _fulfilled);
    
    // Then
    XCTAssertTrue(ran, @"_fulfilled() should be called after _work set the flag.");
    XCTAssertEqual(_fulfilled_callCount, 2, @"_fulfilled() should be called exactly twice: once before running the runloop, once just after _work ran.");
    XCTAssertEqual(_fulfilled_postWorkCallCount, 1, @"_fulfilled() should be called once after _work.");
}

@end

@interface CTTRunLoopRunUntilNotification_Tests : XCTestCase
@end
@implementation CTTRunLoopRunUntilNotification_Tests
{
    void (^_notify)(void);
}

- (void)setUp
{
    [super setUp];
    __weak typeof(self) wself = self;
    _notify = ^{
        __strong typeof(self) sself = wself;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotif" object:sself];
    };
}

- (void) test_CTTRunLoopRunUntilNotification
{
    // When
    BOOL ran = CTTRunLoopRunUntilNotification(0.5, NO, @"TestNotif", self, nil);
    
    // Then
    XCTAssertFalse(ran);

    // Given an asynchronous notification on the current queue
    dispatch_async(dispatch_get_main_queue(), _notify);

    // When
    ran = CTTRunLoopRunUntilNotification(0.5, NO, @"TestNotif", self, nil);

    // Then
    XCTAssertTrue(ran);
}

- (void) test_CTTRunLoopRunUntilNotification_validation
{
    // Given
    __block int validation_callCount;
    __block BOOL validation_result;
    BOOL (^validation)(NSNotification*) = ^(NSNotification* note) {
        ++validation_callCount; return validation_result;
    };

    validation_callCount = 0;
    validation_result = NO;

    // When
    dispatch_async(dispatch_get_main_queue(), _notify);
    BOOL ran = CTTRunLoopRunUntilNotification(0.5, NO, @"TestNotif", self, validation);
    
    // Then
    XCTAssertFalse(ran);
    XCTAssertEqual(validation_callCount, 1);

    // Given
    validation_callCount = 0;
    validation_result = YES;

    // When
    dispatch_async(dispatch_get_main_queue(), _notify);
    ran = CTTRunLoopRunUntilNotification(50, NO, @"TestNotif", self, validation);
    
    // Then
    XCTAssertTrue(ran);
    XCTAssertEqual(validation_callCount, 1);
}

@end
