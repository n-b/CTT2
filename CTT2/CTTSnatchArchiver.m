#import "CTTSnatchArchiver.h"

@implementation _CTTSnatchLoggers (CTTSnatchArchiver)

- (_CTTSnatcher *(^)(NSString*))archive
{
    return ^(NSString* directory){
        self.snatcher.logger = ^(NSURL* url, NSUInteger counter){ return [[CTTSnatchArchiver alloc] initWithDirectory:directory URL:url counter:counter]; };
        return self.snatcher;
    };
}

@end
#pragma mark - Helpers

@implementation NSDictionary (CATHTTPClientAPILogging)
- (NSString *)ctt_httpLoggingHeadersDescription
{
    NSMutableString *result = [NSMutableString new];
    for (id key in self) {
        [result appendFormat:@"%@: %@\n", key, self[key]];
    }
    return result;
}
@end

@implementation NSData (CATHTTPClientAPILogging)
- (NSData *)ctt_prettyfiedDataForType:(NSString*)type_
{
    if ([type_ isEqualToString:@"json"]) {
        id object;
        @try {
            object = [NSJSONSerialization JSONObjectWithData:self options:0 error:NULL];
        } @catch (NSException *exception) {};
        
        if (object) {
            return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:NULL];
        } else {
            return self;
        }
    } else {
        return self;
    }
}
@end

@implementation CTTSnatchArchiver
{
    NSMutableData * _data;
    NSString * _dataType;
}

- (instancetype)initWithDirectory:(NSString*)path_ URL:(NSURL*)url_ counter:(NSUInteger)counter_
{
    if(self = [super initWithURL:url_ counter:counter_]) {
        self.directory = path_;
        [NSFileManager.defaultManager createDirectoryAtPath:self.directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return self;
}

typedef NS_ENUM(NSUInteger, CTTSnatchArchiveDirection) {
    CTTSnatchArchiveDirectionUp,
    CTTSnatchArchiveDirectionDown
};

- (NSString*)baseFilePathFor:(CTTSnatchArchiveDirection)direction_ tag:(NSString*)tag_
{
    NSString * arrow = direction_==CTTSnatchArchiveDirectionUp?@"↑":@"↓";
    NSString * summary = [self.url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    NSString *name = [NSString stringWithFormat:@"%04lu-%@-%@-%@", (unsigned long)self.counter, arrow, tag_, summary];
    return [self.directory stringByAppendingPathComponent:name];
}

- (NSString*)dataTypeForHeaders:(NSDictionary*)headers
{
    NSString *type = headers[@"Content-Type"];
    if (type.length > 0) {
        NSArray * types = [type componentsSeparatedByString:@";"];
        return [types.firstObject componentsSeparatedByString:@"/"].lastObject;
    } else if(self.url.pathExtension.length){
        return self.url.pathExtension;
    } else {
        return @"bin";
    }
}

-(void)logRequest:(NSURLRequest *)request_
{
    NSString *baseFilePath = [self baseFilePathFor:CTTSnatchArchiveDirectionUp tag:request_.HTTPMethod];
    [request_.allHTTPHeaderFields.ctt_httpLoggingHeadersDescription writeToFile:[baseFilePath stringByAppendingPathExtension:@"headers.txt"]
                                                                     atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    [self logRequestBody:request_];
}

- (void)logRequestBody:(NSURLRequest *)request_
{
    if ([request_.HTTPBody length] > 0) {
        NSString *baseFilePath = [self baseFilePathFor:CTTSnatchArchiveDirectionUp tag:@"DATA"];
        NSString *pathExtension = [self dataTypeForHeaders:request_.allHTTPHeaderFields];
        [[request_.HTTPBody ctt_prettyfiedDataForType:pathExtension] writeToFile:[baseFilePath stringByAppendingPathExtension:pathExtension]
                                                                      atomically:NO];
    }
}

- (void)logError:(NSError *)error_
{
    NSString *baseFilePath = [self baseFilePathFor:CTTSnatchArchiveDirectionDown tag:@"ERROR"];
    [error_.description writeToFile:[baseFilePath stringByAppendingPathExtension:@"error.txt"]
                         atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

- (void)logResponse:(NSHTTPURLResponse *)response_
{
    if([response_ isKindOfClass:[NSHTTPURLResponse class]]) {
        NSString *baseFilePath = [self baseFilePathFor:CTTSnatchArchiveDirectionDown tag:@(response_.statusCode).description];
        [response_.allHeaderFields.ctt_httpLoggingHeadersDescription writeToFile:[baseFilePath stringByAppendingPathExtension:@"headers.txt"]
                                                                      atomically:NO encoding:NSUTF8StringEncoding error:NULL];
        _dataType = [self dataTypeForHeaders:response_.allHeaderFields];
    } else {
        _dataType = nil;
    }
}

- (void)logData:(NSData *)data_
{
    if(!_data) {
        _data = [NSMutableData new];
    }
    [_data appendData:data_];
}

- (void)finish
{
    NSString *baseFilePath = [self baseFilePathFor:CTTSnatchArchiveDirectionDown tag:@"DATA"];
    [[_data ctt_prettyfiedDataForType:_dataType] writeToFile:[baseFilePath stringByAppendingPathExtension:_dataType]
            atomically:NO];
}

@end
