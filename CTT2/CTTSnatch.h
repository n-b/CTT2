@import Foundation;

#import "CTTSnatcher.h"
#import "CTTSnatchMatchers.h"
#import "CTTSnatchDelayers.h"
#import "CTTSnatchResponders.h"
#import "CTTSnatchProtocol.h"
#import "CTTUnitTestSnatcher.h"

#define CTTSnatcher          ([[_CTTSnatcher alloc] init])
#define CTTUnitTestSnatcher  ([[_CTTUnitTestSnatcher alloc] initWithTest:self file:__FILE__ line:__LINE__])
