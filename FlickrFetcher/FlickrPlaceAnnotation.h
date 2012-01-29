//
//  FlickrPlaceAnnotation.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place;

@property (nonatomic, strong) NSDictionary *place;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *provinceAndCountry;

@end
