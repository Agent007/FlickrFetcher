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

@interface TopPlacesTableViewController()
@property (nonatomic, strong) NSArray *topPlaces; // TODO may be changed to "atomic" later when mult-threading is implemented in next assignment
@property (nonatomic, strong) NSDictionary *countries;
@end

@implementation TopPlacesTableViewController

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
        [segue.destinationViewController setPhotos:[FlickrFetcher photosInPlace:place maxResults:50]];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *unorderedPlaces = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO stop progress bar
            NSArray *topPlaces = self.topPlaces = [unorderedPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];
            NSMutableDictionary *countries = [NSMutableDictionary dictionary];
            for (NSDictionary *place in topPlaces) {
                NSString *country = [[[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","] lastObject];
                NSMutableArray *cities = [countries valueForKey:country];
                if (cities) {
                    [cities addObject:place];
                } else {
                    cities = [NSMutableArray arrayWithObject:place];
                    [countries setValue:cities forKey:country];
                }
            }
            self.countries = countries;
        });
    });
    dispatch_release(downloadQueue);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self tableView:tableView titleForHeaderInSection:section];
    return [[self.countries valueForKey:country] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self.countries allKeys] mutableCopy] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *country = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSDictionary *place = [[self.countries valueForKey:country] objectAtIndex:indexPath.row];
    NSMutableString *placeString = [[place valueForKeyPath:FLICKR_PLACE_NAME] mutableCopy];
    NSMutableArray *placeComponents = [[placeString componentsSeparatedByString:@","] mutableCopy];
    NSString *city = [placeComponents objectAtIndex:0];
    cell.textLabel.text = city;
    [placeComponents removeObjectAtIndex:0];
    NSString *details;
    for (NSString *element in placeComponents) {
        if (!details) {
            details = element;
        } else {
            details = [details stringByAppendingString:[@"," stringByAppendingString:element]];
        }
    }
    if (details) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", details];
    }
    return cell;
}

@end
