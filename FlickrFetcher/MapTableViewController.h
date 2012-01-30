//
//  MapTableViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(UIViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface MapTableViewController : UITableViewController

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *annotations;//NSArray *annotations;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView; // TODO extract all activityIndicatorViews and put into BackgroundLoader by programatically creating the activity indicator view and its parent plain UIView; or, use a 3rd party component like https://github.com/mattmmatt/MBProgressHUD when coding professionally instead of doing this as a homework
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapToggleButton;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

- (void)showView:(UIView *)view;
- (void)showViewAfterDownload;
- (void)makeMapViewRegionShowEntireWorld;

@end
