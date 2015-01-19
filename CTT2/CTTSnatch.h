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

/*
 Components
 
 Matcher
 Responder
 Verifier
 */
@interface CTTSnatch : NSObject

- (instancetype) snatchRequestMatching:(BOOL(^)(NSURLRequest*))snatchBlock_;
- (id) respondWithJSON:(id)jsonObject;

// Response parameters				defaults
@property NSError * error;			// nil
@property NSTimeInterval delay;		// 0
@property NSInteger statusCode; 	// 200
@property NSDictionary * headers; 	// @{}
@property NSData * data;			// nil
@property BOOL saveCookies;			// YES

- (instancetype) snatchURL:(NSString*)urlString_;
- (instancetype) snatchHost:(NSString*)host_;
@end




@interface XCTestCase (CTTSnatch)
@property (nonatomic, readonly) CTTSnatch * ctt_snatch; // automatically created and deregistered at the end of the test.
- (CTTSnatch*) ctt_snatch;
- (void) ctt_verify;
@end
