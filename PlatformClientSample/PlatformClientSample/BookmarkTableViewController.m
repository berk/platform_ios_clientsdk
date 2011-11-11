//
//  BookmarkTableViewController.m
//  PlatformClientSample
//
//  Created by Michael Berkovich on 10/21/11.
//  Copyright (c) 2011 Geni.com. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "AppDelegate.h"

@implementation BookmarkTableViewController
@synthesize tableView=_tableView, bookmarks, loadingView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bookmarks = [NSArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadBookmarks:self];
}

- (IBAction) reloadBookmarks: (id) sender {
    [loadingView setHidden:false];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];    
    [appDelegate.platform requestWithPath:@"user/bookmarks" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys: @"true", @"only_list", nil] andDelegate:self];
}

- (void) request: (PlatformRequest *)request didFailWithError: (NSError *)error {
    [loadingView setHidden:true];
    NSLog(@"Failed to get data");
}

- (void) request: (PlatformRequest *)request didLoadResponse: (PlatformResponse *)response {
    NSLog(@"Got data");
    [loadingView setHidden:true];
    self.bookmarks = [response results];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    NSDictionary *b = [self.bookmarks objectAtIndex:indexPath.row]; 
    cell.textLabel.text = [b objectForKey:@"title"];
    
    return cell;
}

@end
