@import Foundation;

#import "CTTSnatcher.h"
#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchStoppers.h"
#import "CTTSnatchLoggers.h"
#import "CTTSnatchProtocol.h"
#import "CTTSnatchForXCTest.h"


// CTT.snatch

// CTTSnatchForXCTest(test)

//           .match.url    ( NSString*/NSURL* )
//                 .regexp ( NSRegularExpression*/NSString* )

//           .respond.nothing ( void )
//                   .error   ( NSError* )
//                   .http    ( NSInteger statusCode, NSDictionary * headers, NSData * data, BOOL saveCookies )
//                   .json    ( id jsonObject )

//           .delay.none    ( void )
//                 .seconds ( NSTimeInterval delay )
//                 .until   ( BOOL(^fulfilled_)() )

//           .stop.never     ( void )
//                .afterHits ( NSUInteger )
//                .when      ( BOOL(^condition_)() )
//                .afterTest ( XCTestCase* )

// not sure how

//           .log.none     ( void )
//               .urls     ( void )
//               .data     ( void )
//               .archive  ( NSString*/NSULRL* path )

//           .respond.passthrough ( void )
//           .respond.archive ( NSString*/NSULRL* path )

