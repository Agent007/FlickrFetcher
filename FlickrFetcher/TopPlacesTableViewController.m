//
//  TopPlacesTableViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotosTableViewController.h"
#import "BackgroundLoader.h"
#import <MapKit/MapKit.h>
#import "FlickrPlaceAnnotation.h"

@interface TopPlacesTableViewController()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic, strong) NSDictionary *countries;
@end

@implementation TopPlacesTableViewController
@synthesize mapToggleButton = _mapToggleButton;

@synthesize topPlaces = _topPlaces;
@synthesize countries = _countries;

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
    }
}

- (void)setCountries:(NSDictionary *)countries
{
    if (_countries != countries) {
        _countries = countries;
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos From City"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *country = [self tableView:self.tableView titleForHeaderInSection:indexPath.section];
        NSDictionary *place = [[self.countries valueForKey:country] objectAtIndex:indexPath.row];
        RecentPhotosTableViewController *destinationViewController = (RecentPhotosTableViewController *)segue.destinationViewController;
        destinationViewController.place = place;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BackgroundLoader viewDidLoad:nil withBlock:^{
        NSArray *unorderedPlaces = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *topPlaces = self.topPlaces = [unorderedPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];
            NSMutableDictionary *countries = [NSMutableDictionary dictionary];
            //NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[topPlaces count]];
            NSMutableDictionary *annotations = [NSMutableDictionary dictionaryWithCapacity:[topPlaces count]];
            for (NSDictionary *place in topPlaces) {
                NSString *placeName = [place valueForKeyPath:FLICKR_PLACE_NAME];
                NSString *country = [[placeName componentsSeparatedByString:@","] lastObject];
                NSMutableArray *cities = [countries valueForKey:country];
                if (cities) {
                    [cities addObject:place];
                } else {
                    cities = [NSMutableArray arrayWithObject:place];
                    [countries setValue:cities forKey:country];
                }
                FlickrPlaceAnnotation *annotation = [FlickrPlaceAnnotation annotationForPlace:place];
                [self.mapView addAnnotation:annotation];
                //[annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
                [annotations setValue:annotation forKey:placeName];
            }
            self.countries = countries;
            self.annotations = annotations;
            [super showViewAfterDownload];
        });
    }];
    [super makeMapViewRegionShowEntireWorld];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self tableView:table titleForHeaderInSection:section];
    return [[self.countries valueForKey:country] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self.countries allKeys] mutableCopy] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *country = [self tableView:table titleForHeaderInSection:indexPath.section];
    NSDictionary *place = [[self.countries valueForKey:country] objectAtIndex:indexPath.row];
    FlickrPlaceAnnotation *annotation = [FlickrPlaceAnnotation annotationForPlace:place];
    cell.textLabel.text = annotation.city;
    cell.detailTextLabel.text = annotation.provinceAndCountry;
    return cell;
}

@end
