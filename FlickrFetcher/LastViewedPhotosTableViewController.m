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
    [super prepareForSegue:segue identifier:@"View Recently Viewed Photo" sender:sender];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_PHOTOS"]];
    self.photos = [[lastPhotos reversedOrderedSet] array];
    [super makeMapViewRegionShowEntireWorld];
    [super showViewAfterDownload];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [super mapView:mapView annotationView:view calloutAccessoryControlTapped:control segueIdentifier:@"View Recently Viewed Photo"];
}

@end
