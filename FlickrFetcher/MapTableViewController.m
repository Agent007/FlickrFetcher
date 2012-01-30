//
//  MapTableViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapTableViewController.h"


@implementation MapTableViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize tableView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize mapToggleButton = _mapToggleButton;

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    }
    return _mapView;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    }
    return _activityIndicatorView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* next several lines from http://www.stanford.edu/class/cs193p/cgi-bin/drupal/system/files/sample_code/Shutterbug%20Map.zip -- placing MapView onto TableView in InterfaceBuilder doesn't work as intended */
    if (!tableView && [self.view isKindOfClass:[UITableView class]]) {
		tableView = (UITableView *)self.view;
	}
	
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	
	self.tableView.frame = self.view.bounds;
	[self.view addSubview:self.tableView];
	
	self.mapView.frame = self.view.bounds;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
	[self.view addSubview:self.mapView];
    [self.view addSubview:self.activityIndicatorView];
	
	self.mapView.hidden = YES;
    self.tableView.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self showView:self.activityIndicatorView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)showView:(UIView *)view
{
    view.hidden = NO;
    self.view = view;
}

- (IBAction)toggleView:(UIBarButtonItem *)sender {
    // TODO display text "Loading Table/Map..." for better usability
    if ([sender.title isEqualToString:@"Map"]) {
        if (!self.activityIndicatorView.isAnimating) {
            [self showView:self.mapView];
        }
        sender.title = @"List";
        self.tableView.hidden = YES;
    } else if ([sender.title isEqualToString:@"List"]) {
        if (!self.activityIndicatorView.isAnimating) {
            [self showView:self.tableView];
        }
        sender.title = @"Map";
        self.mapView.hidden = YES;
    }
}

- (void)showViewAfterDownload
{
    [self.activityIndicatorView stopAnimating];
    NSString *buttonTitle = self.mapToggleButton.title;
    if ([buttonTitle isEqualToString:@"Map"]) {
        [self showView:self.tableView];
    } else if ([buttonTitle isEqualToString:@"List"]) {
        [self showView:self.mapView];
    }
}

- (void)makeMapViewRegionShowEntireWorld
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(180, 180));

}

@end
