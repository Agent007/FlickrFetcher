//
//  MapTableViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapTableViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"
#import "BackgroundLoader.h"

@interface MapTableViewController() <MKMapViewDelegate>
@end

@implementation MapTableViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize tableView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize mapToggleButton = _mapToggleButton;
@synthesize viewMode = _viewMode;

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil]]; // TODO i18n
        [segmentedControl setFrame:CGRectMake(32, 4, 256, 32)];
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
        [_mapView addSubview:segmentedControl];
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

- (NSString *)viewMode
{
    if (!_viewMode) {
        _viewMode = @"List";
    }
    return _viewMode;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.viewMode isEqualToString:@"Map"]) {
        self.mapToggleButton.title = @"List";
    } else if ([self.viewMode isEqualToString:@"List"]) {
        self.mapToggleButton.title = @"Map";
    }
    
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
    
    self.mapView.delegate = self;
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
    self.viewMode = sender.title;
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

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *) aView.annotation;
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
        NSLog(@"mapViewController:imageForAnnotation, [NSData dataWithContentsOfURL]");
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = data ? [UIImage imageWithData:data] : nil;
            ((UIImageView *) aView.leftCalloutAccessoryView).image = image;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
}

- (IBAction)changeMapType:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            self.mapView.mapType = MKMapTypeStandard;
            break;
    }
}

@end
