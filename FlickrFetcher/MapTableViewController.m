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

@interface MapTableViewController() <MKMapViewDelegate, MapViewControllerDelegate>
@end

@implementation MapTableViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize tableView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize mapToggleButton = _mapToggleButton;
@synthesize delegate = _delegate;
@synthesize viewMode = _viewMode;

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
    self.delegate = self;
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
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    ((UIImageView *) aView.leftCalloutAccessoryView).image = image;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(UIViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *) annotation;
    // TODO download asynchronously
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSLog(@"mapViewController:imageForAnnotation, [NSData dataWithContentsOfURL]");
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

@end
