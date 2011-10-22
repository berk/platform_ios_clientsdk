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
#import "PlatformResponse.h"

@protocol PlatformRequestDelegate;

/**
 * Do not use this interface directly, instead, use method in Platform.h
 */
@interface PlatformRequest : NSObject {
}

@property(nonatomic,assign) id<PlatformRequestDelegate> delegate;

/**
 * The URL which will be contacted to execute the request.
 */
@property(nonatomic,copy) NSString* url;

/**
 * The API method which will be called.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The dictionary of parameters to pass to the method.
 *
 * These values in the dictionary will be converted to strings using the
 * standard Objective-C object-to-string conversion facilities.
 */
@property(nonatomic,retain) NSMutableDictionary* params;
@property(nonatomic,retain) NSURLConnection*  connection;
@property(nonatomic,retain) PlatformResponse*  response;


+ (NSString*) serializeURL: (NSString *)baseUrl params: (NSDictionary *)params;
+ (NSString*) serializeURL: (NSString *)baseUrl params: (NSDictionary *)params httpMethod: (NSString *)httpMethod;

+ (PlatformRequest*) requestWithParams: (NSMutableDictionary *) params
                            httpMethod: (NSString *) httpMethod
                              delegate: (id<PlatformRequestDelegate>)delegate
                            requestURL: (NSString *) url;
- (void) connect;

- (void) cancel;

- (BOOL) lsLoading;

@end

/************************************************************************************
 ** Platform Request Delegate
 ************************************************************************************/

/*
 *Your application should implement this delegate
 */
@protocol PlatformRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void) requestLoading: (PlatformRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void) request: (PlatformRequest *)request didReceiveResponse: (PlatformResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void) request: (PlatformRequest *)request didFailWithError: (NSError *)error;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void) request: (PlatformRequest *)request didLoadRawResponse: (NSData *)data;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void) request: (PlatformRequest *)request didLoadResponse: (PlatformResponse *)response;

@end

