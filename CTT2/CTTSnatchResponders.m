#import "CTTSnatchResponders.h"

@implementation _CTTSnatchResponders

- (_CTTSnatcher *(^)(void))nothing
{
    return ^(void){
        self.snatcher.responder = ^(NSURLRequest * request_, _CTTSnatchResponseClient * client_) {
            [client_ sendResponse:[[NSURLResponse alloc] initWithURL:request_.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil]];
            [client_ finish];
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSError *))error
{
    return ^(NSError * error_){
        self.snatcher.responder = ^(NSURLRequest * request_, _CTTSnatchResponseClient * client_) {
            [client_ failWithError:error_];
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSInteger, NSDictionary *, NSData *, BOOL))http
{
    return ^(NSInteger statusCode_, NSDictionary * headers_, NSData * data_, BOOL saveCookies_){
        self.snatcher.responder = ^(NSURLRequest * request_, _CTTSnatchResponseClient * client_) {
            NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc] initWithURL:request_.URL statusCode:statusCode_ HTTPVersion:@"HTTP/1.1" headerFields:headers_];
            
            if(saveCookies_) {
                NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:request_.URL];
                [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookies:cookies forURL:request_.URL mainDocumentURL:request_.URL];
            }
            
            [client_ sendResponse:response];
            [client_ sendData:data_];
            [client_ finish];
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(id))json
{
    return ^(id jsonObject_) {
        NSData * data = [NSJSONSerialization dataWithJSONObject:jsonObject_ options:NSJSONWritingPrettyPrinted error:NULL];
        NSDictionary * headers = @{ @"Content-Type": @"application/json; charset=utf-8" };
        self.snatcher.respond.http(200, headers, data, NO);
        return self.snatcher;
    };
}

@end
