//
//  CTTRunLoopRunUntil.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 02/10/14.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

@import Foundation;

// CTTRunLoopRunUntil - Run the current RunLoop until `fulfilled_` returns true, at most for `timeout_` seconds.
//
// `fulfilled_` will be called at intervals, and the RunLoop will be stopped as soon as it returns true.
// Depending on the value of `polling_`, CTTRunLoopRunUntil will either:
//  * let the RunLoop wait for events, or
//  * prevent it from sleeping and actively poll `fulfilled_`.
//
// returns `true` if we exited because `fulfilled_` returned true, `false` because `timeout_` expired.
BOOL __attribute__((overloadable)) CTTRunLoopRunUntil(NSTimeInterval timeout_, BOOL polling_, BOOL(^fulfilled_)(void));
BOOL __attribute__((overloadable)) CTTRunLoopRunUntil(BOOL(^fulfilled_)(void)); // timeout_ set to 1.0 and polling to False


// CTTRunLoopRunUntilNotification - Run the current RunLoop until a notification is received
//
// Wait for a notification with name `name_` and object `object_`.
// When a matching notification is received `validation_` will be called for additional validation.
// See `CTTRunLoopRunUntil` for the `timeout_` and `polling_` parameters.
BOOL __attribute__((overloadable)) CTTRunLoopRunUntilNotification(NSTimeInterval timeout_, BOOL polling_, NSString * name_, id object_, BOOL(^validation_)(NSNotification*));
BOOL __attribute__((overloadable)) CTTRunLoopRunUntilNotification(NSString * name_, id object_); // no additional validation, timeout_ set to 1.0 and polling to False
