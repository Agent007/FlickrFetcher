//
//  RecentPhotosTableViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapTableViewController.h"

@interface RecentPhotosTableViewController : MapTableViewController

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *place;

- (void)prepareForSegue:(UIStoryboardSegue *)segue identifier:(NSString *)identifier sender:(id)sender;
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control segueIdentifier:(NSString *)identifier;
@end
