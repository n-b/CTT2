//
//  CTTRunLoopRunUntil.h
//  CapitaineTrain
//
//  Created by Nicolas Bouilleaud - Capitaine Train on 02/10/14.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

@import CoreFoundation;

// CTTRunLoopRunUntil - Run the current RunLoop until `fulfilled_` returns true, at most for `timeout_` seconds.
//
// `fulfilled_` will be called at intervals, and the RunLoop will be stopped as soon as it returns true.
// Depending on the value of `polling_`, CTTRunLoopRunUntil will either:
//  * let the RunLoop wait for events, or
//  * prevent it from sleeping and actively poll `fulfilled_`.
//
// returns `true` if we exited because `fulfilled_` returned true, `false` because `timeout_` expired.
Boolean CTTRunLoopRunUntil(CFTimeInterval timeout_, Boolean polling_, Boolean(^fulfilled_)());
