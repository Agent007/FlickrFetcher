//
//  LastViewedPhotosTableViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LastViewedPhotosTableViewController.h"
#import "ImageViewController.h"

@implementation LastViewedPhotosTableViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Recently Viewed Photo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        id viewController = segue.destinationViewController;
        [viewController setTitle:((UITableViewCell *)sender).textLabel.text];
        ((ImageViewController *) viewController).photo = photo;
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_PHOTOS"]];
    self.photos = [[lastPhotos reversedOrderedSet] array];
}

@end
