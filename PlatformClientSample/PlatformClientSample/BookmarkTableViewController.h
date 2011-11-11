//
//  BookmarkTableViewController.h
//  PlatformClientSample
//
//  Created by Michael Berkovich on 10/21/11.
//  Copyright (c) 2011 Geni.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlatformSDK.h"

@interface BookmarkTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PlatformRequestDelegate>

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) NSArray *bookmarks;

@property(nonatomic, retain) IBOutlet UIView *loadingView;


- (IBAction) reloadBookmarks: (id) sender;

@end
