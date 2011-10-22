//
//  ViewController.h
//  PlatformClientSample
//
//  Created by Michael Berkovich on 10/21/11.
//  Copyright (c) 2011 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@property(nonatomic, retain) IBOutlet UIButton *loginButton;
@property(nonatomic, retain) IBOutlet UIButton *logoutButton;

- (IBAction)loginClicked:(id)sender;
- (IBAction)logoutClicked:(id)sender;

@end
