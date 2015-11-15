@import Foundation;

#import "CTTSnatcher.h"
#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchStoppers.h"
#import "CTTSnatchProtocol.h"
#import "CTTUnitTestSnatcher.h"

#define CTTSnatcher          ([[_CTTSnatcher alloc] init])
#define CTTUnitTestSnatcher  ([[_CTTUnitTestSnatcher alloc] initWithTest:self file:__FILE__ line:__LINE__])


// CTT.snatch

// done

//           .match.url    ( NSString*/NSURL* )
//                 .regexp ( NSRegularExpression*/NSString* )

//           .respond.nothing ( void )
//                   .error   ( NSError* )
//                   .http    ( NSInteger statusCode, NSDictionary * headers, NSData * data, BOOL saveCookies )
//                   .json    ( id jsonObject )

//           .delay.none    ( void )
//                 .seconds ( NSTimeInterval delay )
//                 .until   ( BOOL(^fulfilled_)() )

// feasible

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

