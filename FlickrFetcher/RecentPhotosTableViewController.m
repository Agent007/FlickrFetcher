//
//  RecentPhotosTableViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@implementation RecentPhotosTableViewController

@synthesize photos = _photos;

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Recent Photo From Place"]) {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            //UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            //[self.popoverController dismissPopoverAnimated:YES];
            //self.popoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?
        }
        //[segue.destinationViewController setDelegate:self];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        id viewController = segue.destinationViewController;
        [viewController setTitle:((UITableViewCell *)sender).textLabel.text];
        ((ImageViewController *) viewController).photo = photo;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if (!title) { // TODO what if title is whitespace, but not null?
        title = description;
        if (!description) {
            title = @"Unknown";
        }
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    
    return cell;
}

@end
