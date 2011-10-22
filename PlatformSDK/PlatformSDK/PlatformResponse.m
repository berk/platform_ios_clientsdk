/*
 * Copyright (c) 2011 Michael Berkovich
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "PlatformResponse.h"
#import "SBJson.h"

static const int kGeneralResponseErrorCode = 10000;

@implementation PlatformResponse

@synthesize rawData, httpURLResponse, jsonBody, xmlBody, stringBody;

/************************************************************************************
 ** Logging Methods (Debug)
 ************************************************************************************/

- (void) logResponse:(NSHTTPURLResponse *)response {
    NSLog(@"-------------------------------------------------------");
    NSLog(@"Response");
    NSLog(@"\tURL: %@", [[response URL] absoluteString]);
    NSLog(@"\tCode: %d", [response statusCode]);
    NSLog(@"\tMime Type: %@", [response MIMEType]);
    NSLog(@"\tExpected Content Length: %lld", [response expectedContentLength]);
    NSLog(@"\tText Encoding Name: %@", [response textEncodingName]);
    NSLog(@"\tSuggested File Name: %@", [response suggestedFilename]);
    for (NSString *key in [[response allHeaderFields] allKeys]) {
        NSLog(@"\t[Header]%@ = %@", key, [[response allHeaderFields] valueForKey:key]);
    }
}

- (void) logResponseBody:(NSData *)data {
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"\tBody: %@", stringData);
}

/************************************************************************************
 ** Public Methods
 ************************************************************************************/

- (id) initWithHTTPURLResponse:(NSHTTPURLResponse *) response {
    self = [super init];
    if (self) {
        self.httpURLResponse = response;
        [self logResponse: response];
    }
    return self;
}

- (void) appendRawData:(NSData *)data {
    if (self.rawData == nil) {
        self.rawData = [[NSMutableData alloc] init];
    }
    [self.rawData appendData:data];    
}

- (id) parse:(NSError **)error {
    [self logResponseBody: self.rawData];
    
    self.stringBody = [[NSString alloc] initWithData:self.rawData encoding:NSUTF8StringEncoding];
    SBJsonParser *jsonParser = [SBJsonParser new];
    id result = [jsonParser objectWithString:self.stringBody];
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        self.jsonBody = result;
        if ([result objectForKey:@"error"] != nil) {
            if (error != nil) {
                *error = [NSError errorWithDomain:@"PlatformErrorDomain" code:kGeneralResponseErrorCode userInfo:[result objectForKey:@"error"]];
            }
            return nil;
        }
    }
    return result;
}

- (BOOL) isHTML {
	NSRange range = [[self.httpURLResponse MIMEType] rangeOfString: @"html"];
	return (range.length != 0);
}

- (BOOL) isImage {
	NSRange range = [[self.httpURLResponse MIMEType] rangeOfString: @"image"];
	return (range.length != 0);
}

- (BOOL) isJSON {
	NSRange range = [[self.httpURLResponse MIMEType] rangeOfString: @"json"];
	return (range.length != 0);
}

- (NSString *) headerValueForKey:(NSString*) key {
    return [[self.httpURLResponse allHeaderFields] objectForKey:key];
}

- (UIImage *) image {
    if (![self isImage]) return nil;
    return [UIImage imageWithData:self.rawData];
}

- (id) objectForKey: (NSString *) key {
    return [self.jsonBody objectForKey:key];
}

- (NSString *) valueForKey: (NSString *) key {
    return (NSString *) [self objectForKey: key];
}

- (NSArray *) results {
    return [self objectForKey:@"results"];
}

- (NSString *) nextPageURL {
    return [self valueForKey:@"next_page"];
}

- (NSString *) previousPageURL {
    return [self valueForKey:@"previous_page"];
}


@end
