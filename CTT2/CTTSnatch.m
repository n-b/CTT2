//
//  CTTSnatch.m
//  CTT2
//
//  Created by Nicolas Bouilleaud on 04/12/2014.
//  Copyright (c) 2014 Capitaine Train. All rights reserved.
//

#import "CTTSnatch.h"
#import <objc/runtime.h>


@interface CTTSnatch ()
{
    Class _snatchProtocolClass;
}
@property (copy) BOOL (^snatchBlock)(NSURLRequest*);
@end

@interface CTTSnatchProtocol : NSURLProtocol
+ (void) setSnatch:(CTTSnatch*)snatch_;
+ (CTTSnatch*) snatch;
- (CTTSnatch*) snatch;
@end

/****************************************************/

@implementation CTTSnatchProtocol

+ (instancetype)alloc
{
    NSAssert([self isSubclassOfClass:[CTTSnatchProtocol class]], @"Should only instantiate subclasses of CTTSnatchProtocol");
    NSAssert(self != [CTTSnatchProtocol class], @"Should only instantiate subclasses of CTTSnatchProtocol");
    return [super alloc];
}

+ (void) setSnatch:(CTTSnatch*)snatch_
{
    objc_setAssociatedObject(self, @selector(snatch), snatch_, OBJC_ASSOCIATION_ASSIGN);
}

+ (CTTSnatch*) snatch
{
    return objc_getAssociatedObject(self, @selector(snatch));
}

- (CTTSnatch*) snatch
{
    return [[self class] snatch];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ( YES
            && [@[@"http", @"https"] containsObject:request.URL.scheme]
            && (self.snatch.snatchBlock == nil || self.snatch.snatchBlock(request))
            );
}

- (void) startLoading
{
    if(self.snatch.error) {
        [self.client URLProtocol:self didFailWithError:self.snatch.error];
        return;
    }

    if(self.snatch.delay) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, self.snatch.delay, false);
    }

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:self.snatch.statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:self.snatch.headers];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:self.snatch.data];
    
    if(self.snatch.saveCookies) {
        NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:self.request.URL];
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies
                                                         forURL:self.request.URL
                                                mainDocumentURL:self.request.URL];
    }
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    // mandatory implementation for NSURLProtocol
}

@end

/**************************************/

@implementation CTTSnatch
{
    BOOL _hit;
    
    XCTestCase * _testcase;
    const char * _file;
    int _line;
}

- (instancetype)init
{
    return [self initWithTestCase:nil file:NULL line:0];
}

- (instancetype) initWithTestCase:(XCTestCase*)testcase_ file:(const char*)file_ line:(int)line_;
{
    self = [super init];
    if (self) {
        // Create a one-instance subclass of NSURLProtocol just for me.
        const char * name = [NSString stringWithFormat:@"%@-%p",NSStringFromClass([CTTSnatchProtocol class]),self].UTF8String;
        _snatchProtocolClass = objc_allocateClassPair([CTTSnatchProtocol class], name, 0);
        [_snatchProtocolClass setSnatch:self];
        [NSURLProtocol registerClass:_snatchProtocolClass];
        self.statusCode = 200;
        self.headers = @{};
        self.saveCookies = YES;
        
        // Keep testscase info around
        if(testcase_ && file_) {
            _testcase = testcase_;
            _file = file_;
            _line = line_;
        }
    }
    return self;
}

- (void)dealloc
{
    [_snatchProtocolClass setSnatch:nil]; // probably unnecessary
    [NSURLProtocol unregisterClass:_snatchProtocolClass];
}

// Match

typedef BOOL (^CTTSnatchBlock)(NSURLRequest *);
typedef CTTSnatchBlock (^CTTMatchAlgorithm)(id);
typedef CTTSnatch* (^CTTMatcher)(id);

- (CTTSnatch *(^)(CTTSnatchBlock))matchRequest
{
    return ^(CTTSnatchBlock block){ self.snatchBlock = block; return self; };
}

- (CTTMatcher) makematcher:(CTTMatchAlgorithm)v_
{
    return ^(id obj){
        return self.matchRequest(v_(obj));
    };
}

- (CTTSnatch *(^)(NSString *))matchURLString
{
    CTTMatchAlgorithm MatchURLString = ^(NSString* str_) {
        return ^(NSURLRequest* req) {
            return [req.URL.absoluteString isEqualToString:str_];
        };
    };
    return [self makematcher:MatchURLString];
}

- (instancetype) snatchRequestMatching:(BOOL(^)(NSURLRequest*))snatchBlock_
{
    __weak typeof(self) wself = self;
    self.snatchBlock = ^(NSURLRequest* r){
        __strong typeof(self) sself = wself;
        sself->_hit = snatchBlock_(r);
        return (BOOL)(sself->_hit && sself->_data);
    };

    return self;
}

- (instancetype) snatchURL:(NSString*)urlString_
{
    [self snatchRequestMatching:^(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:urlString_];
    }];
    return self;
}

- (instancetype) snatchHost:(NSString*)host_
{
    [self snatchRequestMatching:^(NSURLRequest *request) {
        return [request.URL.host isEqualToString:host_];
    }];
    return self;
}

// Respond

- (id) respondWithJSON:(id)jsonObject
{
    self.data = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL];
    NSMutableDictionary * headers = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [headers addEntriesFromDictionary:@{ @"Content-Type": @"application/json; charset=utf-8" }];
    self.headers = headers;
    return self;
}

// Verify

- (BOOL) verify
{
    if (!_hit) {
        NSString *reason = [NSString stringWithFormat:@"%s:%lu %@", _file, (unsigned long)_line, @"CTTSnatch failed"];
        [[NSException exceptionWithName:@"CTTSnatchFailure" reason:reason userInfo:nil] raise];
    }
    return _hit;
}

@end



@implementation XCTestCase (CTTRequestSnatcher)

- (CTTSnatch *)ctt_snatch
{
    @synchronized(self) {
        NSMutableArray * snatchers = objc_getAssociatedObject(self, @selector(ctt_snatch));
        if (nil==snatchers) {
            snatchers = [NSMutableArray new];
            objc_setAssociatedObject(self, @selector(ctt_snatch), snatchers, OBJC_ASSOCIATION_RETAIN);
        }
        CTTSnatch * snatch = [CTTSnatch new];
        [snatchers addObject:snatch];
        return snatch;
    }
}

- (void) ctt_verifyAll
{
    for (CTTSnatch * snatch in objc_getAssociatedObject(self, @selector(ctt_snatch))) {
        [snatch verify];
    }
}

@end
