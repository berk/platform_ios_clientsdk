//
//  AppDelegate.h
//  PlatformClientSample
//
//  Created by Michael Berkovich on 10/21/11.
//  Copyright (c) 2011 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlatformSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PlatformSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) Platform *platform;

- (void) login;
- (void) logout;

@end
