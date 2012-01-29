//
//  FlickrPlaceAnnotation.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    
    /* parse place string */
    NSMutableString *placeString = [[place valueForKeyPath:FLICKR_PLACE_NAME] mutableCopy];
    NSMutableArray *placeComponents = [[placeString componentsSeparatedByString:@","] mutableCopy];
    NSString *city = [placeComponents objectAtIndex:0];
    annotation.city = city;
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
        annotation.provinceAndCountry = [NSString stringWithFormat:@"%@", details];
    }
    return annotation;
}

@synthesize place = _place;
@synthesize city = _city;
@synthesize provinceAndCountry = _provinceAndCountry;

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.city;//[self.place objectForKey:FLICKR_PLACE_NAME];
}

- (NSString *)subtitle
{
    return self.provinceAndCountry;//[self.place valueForKeyPath:FLICKR_PLACE_NAME];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}


@end
