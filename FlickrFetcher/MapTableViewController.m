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

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    }
    return _mapView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
	
	self.mapView.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)toggleView:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Map"]) {
        self.mapView.hidden = NO;
        self.view = self.mapView;
        sender.title = @"List";
        self.tableView.hidden = YES;
    } else if ([sender.title isEqualToString:@"List"]) {
        self.tableView.hidden = NO;
        self.view = self.tableView;
        sender.title = @"Map";
        self.mapView.hidden = YES;
    }
}

@end
