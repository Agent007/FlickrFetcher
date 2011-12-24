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
@end

@implementation TopPlacesTableViewController

@synthesize topPlaces = _topPlaces;

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos From City"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *place = [self.topPlaces objectAtIndex:indexPath.row];
        [segue.destinationViewController setPhotos:[FlickrFetcher photosInPlace:place maxResults:50]];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *unorderedPlaces = [FlickrFetcher topPlaces];
    self.topPlaces = [unorderedPlaces sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.topPlaces objectAtIndex:indexPath.row];
    NSMutableString *place = [[photo valueForKeyPath:FLICKR_PLACE_NAME] mutableCopy];
    NSMutableArray *placeComponents = [[place componentsSeparatedByString:@","] mutableCopy];
    NSString *city = [placeComponents objectAtIndex:0];
    cell.textLabel.text = city;
    [placeComponents removeObjectAtIndex:1];
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
