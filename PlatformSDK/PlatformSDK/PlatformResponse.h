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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlatformResponse : NSObject {
}

@property(nonatomic, retain) NSHTTPURLResponse *httpURLResponse;
@property(nonatomic, retain) NSMutableData *rawData;
@property(nonatomic, retain) NSString *stringBody;
@property(nonatomic, retain) NSDictionary *jsonBody;
@property(nonatomic, retain) NSDictionary *xmlBody;

- (id) initWithHTTPURLResponse:(NSHTTPURLResponse *) response;
- (void) appendRawData:(NSData *)data;
- (id) parse:(NSError **)error;

- (BOOL) isHTML;
- (BOOL) isImage;
- (BOOL) isJSON;

- (NSString *) headerValueForKey:(NSString*) key;

- (id) objectForKey: (NSString *) key;
- (NSString *) valueForKey: (NSString *) key;

- (UIImage *) image;
- (NSArray *) results;
- (NSString *) nextPageURL;
- (NSString *) previousPageURL;

@end
