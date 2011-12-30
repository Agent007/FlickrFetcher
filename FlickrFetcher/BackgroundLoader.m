//
//  BackgroundLoader.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundLoader.h"

@implementation BackgroundLoader
+ (void)viewDidLoad:(UIActivityIndicatorView *)activityIndicatorView withBlock:(void (^)())block
{
    //[activityIndicatorView startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL); // TODO parameterize queue name if this will be used in other apps
    dispatch_async(downloadQueue, block);
    dispatch_release(downloadQueue);
}
@end
