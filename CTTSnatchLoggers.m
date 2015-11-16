#import "CTTSnatchLoggers.h"

@implementation _CTTSnatchLoggers

- (_CTTSnatcher *(^)(void))none
{
    return ^(void){
        self.snatcher.requestLogger = ^(NSURLRequest* request_, NSUInteger tag_) { };
        self.snatcher.responseLogger = ^(NSURLResponse* response_, NSUInteger tag_) { };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(void))urls
{
    return ^(void){
        self.snatcher.requestLogger = ^(NSURLRequest* request_, NSUInteger tag_) {
            NSLog(@"Sending request to: %@",request_.URL);
        };
        self.snatcher.responseLogger = ^(NSURLResponse* response_, NSUInteger tag_) {
            NSLog(@"Sending response for: %@",response_.URL);
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSString*))headers
{
    return ^(NSString* path){
        self.snatcher.requestLogger = ^(NSURLRequest* request_, NSUInteger tag_) {
            NSLog(@"Sending request to: %@",request_.URL);
        };
        self.snatcher.responseLogger = ^(NSURLResponse* response_, NSUInteger tag_) {
            NSLog(@"Sending response for: %@",response_.URL);
        };
        return self.snatcher;
    };
}

- (_CTTSnatcher *(^)(NSString*))archive
{
    return ^(NSString* directory){
        self.snatcher.requestLogger = ^(NSURLRequest* request_, NSUInteger tag_) {
            NSLog(@"Sending request to: %@",request_.URL);
        };
        self.snatcher.responseLogger = ^(NSURLResponse* response_, NSUInteger tag_) {
            NSLog(@"Sending response for: %@",response_.URL);
        };
        return self.snatcher;
    };
}

@end
