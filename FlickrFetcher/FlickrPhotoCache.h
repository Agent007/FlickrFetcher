//
//  FlickrPhotoCache.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoCache : NSObject

- (NSData *)imageDataForPhoto:(NSDictionary *)photo;

@end
