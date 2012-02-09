//
//  FlickrPhotoCache.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoCache.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoCache()

@property (readonly, strong, nonatomic) NSFileManager *fileManager;
@property (readonly) NSUInteger CACHE_LIMIT;

@end

@implementation FlickrPhotoCache

@synthesize fileManager = _fileManager;

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return _fileManager;
}

- (NSUInteger)CACHE_LIMIT
{
    return 10000000;
}

- (NSData *)imageDataForPhoto:(NSDictionary *)photo
{
    // check file-based cache
    NSFileManager *fileManager = self.fileManager;
    NSURL *cacheDirectory = (NSURL *) [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *cacheDirectoryPathString = [cacheDirectory path];
    NSString *filepathString = [cacheDirectoryPathString stringByAppendingString:(NSString *) [photo valueForKey:FLICKR_PHOTO_ID]];
    NSData *imageData;
    if ([fileManager fileExistsAtPath:filepathString]) {
        imageData = [fileManager contentsAtPath:filepathString];
    } else {
        NSLog(@"FlickrPhotoCache imageDataForPhoto: [NSData dataWithContentsOfURL]");
        imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]];
        NSUInteger imageSize = [imageData length];
        if (imageSize < self.CACHE_LIMIT) {
            NSDictionary *cacheDirectoryAttributes = [fileManager attributesOfItemAtPath:cacheDirectoryPathString error:nil];
            unsigned long long cacheDirectorySize = [cacheDirectoryAttributes fileSize];
            NSLog(@"cacheDirectorySize: %llu", cacheDirectorySize);
            if (![fileManager createFileAtPath:filepathString contents:imageData attributes:nil]) {
                NSLog(@"Unable to write file to cache!");
            }
        }
    }
    return imageData;
}

@end
