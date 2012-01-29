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
#import "BackgroundLoader.h"

@interface RecentPhotosTableViewController()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation RecentPhotosTableViewController
@synthesize activityIndicatorView = _activityIndicatorView;

@synthesize photos = _photos;
@synthesize place = _place;

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

- (void)setPlace:(NSDictionary *)place
{
    if (_place != place) {
        _place = place;
        [BackgroundLoader viewDidLoad:nil withBlock:^{
            NSArray *photos = [FlickrFetcher photosInPlace:place maxResults:50];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photos = photos;
                [self.activityIndicatorView stopAnimating];
            });
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View Recent Photo From Place"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        id viewController = segue.destinationViewController;
        [viewController setTitle:((UITableViewCell *)sender).textLabel.text];
        ((ImageViewController *)viewController).photo = photo;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    ImageViewController *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
    detailViewController.photo = photo;
}

- (void)viewDidUnload {
    self.activityIndicatorView = nil;
    [super viewDidUnload];
}
@end
