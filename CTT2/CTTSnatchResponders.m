#import "CTTSnatchResponders.h"

@implementation _CTTSnatchResponders

- (_CTTSnatcher *(^)(void))nothing
{
    return ^(void){
        self.snatcher.responder = ^(NSURLProtocol * protocol) {
            [protocol.client URLProtocolDidFinishLoading:protocol];
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSError *))error
{
    return ^(NSError * error_){
        self.snatcher.responder = ^(NSURLProtocol * protocol) {
            [protocol.client URLProtocol:protocol didFailWithError:error_];
        };
        return self.snatcher;
    };
}

static CTTSnatchResponder CTTSnatchResponderHTTP(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_)
{
    return ^(NSURLProtocol * protocol) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:protocol.request.URL
                                                                  statusCode:statusCode_
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:headers_];
        [protocol.client URLProtocol:protocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [protocol.client URLProtocol:protocol didLoadData:data_];
        
        if(saveCookies_) {
            NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:protocol.request.URL];
            [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies
                                                             forURL:protocol.request.URL
                                                    mainDocumentURL:protocol.request.URL];
        }
        [protocol.client URLProtocolDidFinishLoading:protocol];
    };
}

- (_CTTSnatcher *(^)(NSInteger, NSDictionary *, NSData *, BOOL))http
{
    return ^(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_){
        self.snatcher.responder = CTTSnatchResponderHTTP(statusCode_, headers_, data_,saveCookies_);
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(id))json
{
    return ^(id jsonObject_) {
        NSData * data = [NSJSONSerialization dataWithJSONObject:jsonObject_ options:NSJSONWritingPrettyPrinted error:NULL];
        NSDictionary * headers = @{ @"Content-Type": @"application/json; charset=utf-8" };
        self.snatcher.responder = CTTSnatchResponderHTTP(200, headers, data, NO);
        return self.snatcher;
    };
}

@end
