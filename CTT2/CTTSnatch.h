//
//  CTTSnatch.h
//  CTT2
//
//  Created by Nicolas Bouilleaud on 04/12/2014.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

@import Foundation;
@import XCTest;


/*
 Use cases
 - mock individual network requests in unit tests
 CTTSnatchNextRequest()
 CTTSnatchAllRequests()

 .matching(block)
 .withHost()
 .withPath()

 .delay()

 .andRespond()
   .withError()
   .withStatus()
   .withData()
   .withHeaders()
   .withJSONObject()
   .andSaveCookies()
 
 .andLetPass() // default if respond isn't called
 
 CTTSnatchVerifyRequest(block) // when using snatchall

 CTTSnatchVerify() // when using snatchnext
 
 - mock all requests in fake sessions for offline/quick debugging (replay real responses? what about autorecord?)
 
 
 
 - mock specific requests but let others pass?
 - mock network failures
 */

@interface CTTSnatch : NSObject

// Init
- (instancetype) init;

- (instancetype) initWithTestCase:(XCTestCase*)testcase_ file:(const char*)file_ line:(int)line_;
#define CTTUnitTestSnatch		([CTTSnatch alloc] initWithTestCase:self file:__FILE__ line:__LINE__])

// Filter
//- (instancetype) matchRequest:(BOOL(^)(NSURLRequest*))match_;

@property (nonatomic, readonly) CTTSnatch* (^ matchRequest) (BOOL(^)(NSURLRequest*));
@property (nonatomic, readonly) CTTSnatch* (^ matchURLString) (NSString*);

//- (instancetype) matchURL:(NSString*)urlString_;
//- (instancetype) matchHost:(NSString*)host_;
//- (instancetype) matchPath:(NSString*)path_;
//- (instancetype) matchPredicate:(NSString*)predicate_;
//- (instancetype) matchRegexp:(NSString*)predicate_;


//- (instancetype) times:(NSUInteger)count;
//- (instancetype) once;
//- (instancetype) forever;


// Response
//- (instancetype) passthrough;

@property NSError * error;			// nil
@property NSTimeInterval delay;		// 0
@property NSInteger statusCode; 	// 200
@property NSDictionary * headers; 	// @{}
@property NSData * data;			// nil
@property BOOL saveCookies;			// YES

- (instancetype) respondWithJSON:(id)jsonObject;



// Verification

- (BOOL) verify; // throws if testcase

@end


@interface NSObject (CTTSnatch)
@property (nonatomic, readonly) CTTSnatch * ctt_snatch; // automatically created and deregistered at the end of the test.
- (void) ctt_verify;
@end

