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

#import "Platform.h"
#import "PlatformRequest.h"

/************************************************************************************
 ** Constants
 ************************************************************************************/

static NSString* kApiBaseURL = @"http://localhost:3000/api";
static NSString* kOauthBaseURL = @"http://localhost:3000/platform/oauth";

static NSString* kOauthAuthorizePath = @"/authorize";
static NSString* kOauthRequestTokenPath = @"/request_token";
static NSString* kOauthValidateTokenPath = @"/validate_token";
static NSString* kOauthInvalidateTokenPath = @"/invalidate_token";

/************************************************************************************
 ** Implementation
 ************************************************************************************/

@implementation Platform

@synthesize appId, accessToken, apiBaseURL, oauthBaseURL, sessionDelegate, request;

/************************************************************************************
 ** Initialization
 ************************************************************************************/

/**
 * Initialize Platform object with application id
 */
- (id) initWithAppId:(NSString *)newAppId {
    self = [super init];
    if (self) {
        self.appId = newAppId;
        self.oauthBaseURL = kOauthBaseURL;
        self.apiBaseURL = kApiBaseURL;
        self.accessToken = nil;
    }
    return self;
}

/************************************************************************************
 ** Private Methods
 ************************************************************************************/

- (NSString *) landingUrl {
    return [NSString stringWithFormat:@"app%@://authorize", self.appId];
}

/**
 * A private helper function for sending HTTP requests.
 *
 * @param url
 *            url to send http request
 * @param params
 *            parameters to append to the url
 * @param httpMethod
 *            http method @"GET" or @"POST"
 * @param authorized
 *            YES/NO - whether the access token should be added to the params
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
- (PlatformRequest*) openUrl: (NSString *) url
                      params: (NSMutableDictionary *) params
                  httpMethod: (NSString *) httpMethod
                  authorized: (BOOL) authorized  
                    delegate: (id<PlatformRequestDelegate>) delegate {
    
    if (authorized && [self isAccessTokenPresent]) {
        [params setValue:self.accessToken forKey:@"access_token"];
    }
    
    self.request = [PlatformRequest requestWithParams: params
                                           httpMethod: httpMethod
                                             delegate: delegate
                                           requestURL: url];
    [request connect];
    return request;
}

/**
 * A private function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}


/************************************************************************************
 ** Public Methods
 ************************************************************************************/

/**
 * Browser-based authorization flow. Works for all applications.
 */
- (void)authorize:(id<PlatformSessionDelegate>)delegate {
    self.sessionDelegate = delegate;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.appId,          @"client_id",
                                   @"token",            @"response_type",
                                   @"mobile",           @"display",
                                   nil];
    
    [params setValue:[self landingUrl] forKey:@"redirect_uri"];
    NSString *platformAppUrl = [PlatformRequest serializeURL:[self.oauthBaseURL stringByAppendingString:kOauthAuthorizePath] params:params];
    NSLog(@"%@", platformAppUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:platformAppUrl]];
}

/**
 * Trusted application authorization flow. Works only for trusted applications.
 */
- (void)authorizeWithUsername:(NSString *)username andPassword:(NSString *)password andDelegate:(id<PlatformSessionDelegate>)delegate {
    self.sessionDelegate = delegate;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.appId,              @"client_id",
                                   @"token",                @"response_type",
                                   @"password",             @"grant_type",
                                   username,                @"username",
                                   password,                @"password", 
                                   nil];
    
    [self requestWithPath:[self.oauthBaseURL stringByAppendingString:kOauthRequestTokenPath] andParams:params andDelegate:self];
}

/**
 * This function processes the URL the Safari used to
 * open your application during a single sign-on flow.
 *
 * You MUST call this function in your UIApplicationDelegate's handleOpenURL
 * method (see
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html
 * for more info).
 *
 * This will ensure that the authorization process will proceed smoothly once the
 * Platform application or Safari redirects back to your application.
 *
 * @param URL the URL that was passed to the application delegate's handleOpenURL method.
 *
 * @return YES if the URL starts with 'app_key://authorize and hence was handled
 *   by SDK, NO otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    // If the URL's structure doesn't match the structure used for Platform authorization, abort.
    if (![[url absoluteString] hasPrefix:[self landingUrl]]) {
        return NO;
    }
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }
    
    NSDictionary *params = [self parseURLParams:query];
    NSString *newAccessToken = [params valueForKey:@"access_token"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!newAccessToken) {
        NSString *status = [params valueForKey:@"status"];
        
        BOOL userDidCancel = status && [status isEqualToString:@"unauthorized"];
        if ([self.sessionDelegate respondsToSelector:@selector(platformUserDidNotLogin:)]) {
            [self.sessionDelegate platformUserDidNotLogin:userDidCancel];
        }
        return YES;
    }
    
    self.accessToken = newAccessToken;
    if ([self.sessionDelegate respondsToSelector:@selector(platformUserDidLogin)]) {
        [self.sessionDelegate platformUserDidLogin];
    }
    return YES;
}

/**
 * Validates current access token. 
 **/
- (void)validate:(id<PlatformSessionDelegate>)delegate {
    self.sessionDelegate = delegate;
    [self requestWithPath:[self.oauthBaseURL stringByAppendingString:kOauthValidateTokenPath] andDelegate:self];
}

/**
 * Logs user out. No confirmation is necessary.
 **/
- (void)logout:(id<PlatformSessionDelegate>)delegate {
    self.sessionDelegate = delegate;
    [self requestWithPath:[self.oauthBaseURL stringByAppendingString:kOauthInvalidateTokenPath] andDelegate:nil];
    self.accessToken = nil;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* platformCookies = [cookies cookiesForURL: [NSURL URLWithString:kOauthBaseURL]];
    for (NSHTTPCookie* cookie in platformCookies) {
        [cookies deleteCookie:cookie];
    }
    
    if ([self.sessionDelegate respondsToSelector:@selector(platformUserDidLogout)]) {
        [self.sessionDelegate platformUserDidLogout];
    }
}

- (PlatformRequest*)requestWithPath:(NSString *)path
                        andDelegate:(id <PlatformRequestDelegate>)delegate {
    
    return [self requestWithPath: path
                       andParams: [NSMutableDictionary dictionary]
                   andHttpMethod: @"GET"
                     andDelegate: delegate];
}

- (PlatformRequest*)requestWithPath:(NSString *)path
                          andParams:(NSMutableDictionary *)params
                        andDelegate:(id <PlatformRequestDelegate>)delegate {
    
    return [self requestWithPath: path
                       andParams: params
                   andHttpMethod: @"GET"
                     andDelegate: delegate];
}

- (PlatformRequest*)requestWithPath:(NSString *)path
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <PlatformRequestDelegate>)delegate {
    
    NSString *fullURL = path;
    BOOL authorized = YES;
    
    if (([path rangeOfString:@"http"]).length == 0) {
        if (([path rangeOfString:self.apiBaseURL]).length == 0) {
            fullURL = [self.apiBaseURL stringByAppendingFormat:@"/%@", path];
        } else {
            fullURL = [NSString stringWithFormat: @"http://%@", path];
        }
    }
    
    // URLs outside of the app domain should not be authorized with access token
    if (([fullURL rangeOfString:self.apiBaseURL]).length == 0) {
        authorized = NO;
    }
    
    return [self openUrl:fullURL params:params httpMethod:httpMethod authorized:authorized delegate:delegate];
}

/**
 * @return boolean - whether access token is present
 */
- (BOOL)isAccessTokenPresent {
    return (self.accessToken != nil);
}

/**
 * Validate the token.
 */
- (void)request:(PlatformRequest *)request didFailWithError:(NSError *)error {
    self.accessToken = nil;
    if ([self.sessionDelegate respondsToSelector:@selector(platformUserDidNotLogin:)]) {
        [self.sessionDelegate platformUserDidNotLogin:NO];
    }
}

- (void)request:(PlatformRequest *)oauthRequest didLoadResponse:(PlatformResponse *)oauthResponse {
    if (![oauthResponse isJSON]) {
        [self request:oauthRequest didFailWithError:[NSError errorWithDomain:@"PlatformErrorDomain" code:10000 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to authorize the user", @"error", nil]]];
        return;
    }
    
    if ([oauthResponse valueForKey:@"access_token"] != nil) {
        self.accessToken = [oauthResponse valueForKey:@"access_token"];
    }
    
    if ([self.sessionDelegate respondsToSelector:@selector(platformUserDidLogin)]) {
        [self.sessionDelegate platformUserDidLogin];
    }
}

@end
