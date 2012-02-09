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

@property (readonly, strong, nonatomic) NSCache *memoryCache;
@property (readonly) NSUInteger CACHE_LIMIT;

@end

@implementation FlickrPhotoCache

@synthesize memoryCache = _memoryCache;

- (NSUInteger)CACHE_LIMIT
{
    return 10000000; // 10MB
}

- (id)init
{
    if (self = [super init]) {
        _memoryCache = [[NSCache alloc] init];
        [self.memoryCache setTotalCostLimit:self.CACHE_LIMIT];
        
        // load files into memory from storage
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *cacheDirectory = (NSURL *) [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *cacheDirectoryPathString = [cacheDirectory path];
        NSString *photosCacheDirectory = [cacheDirectoryPathString stringByAppendingPathComponent:@"photos"];
        if ([fileManager createDirectoryAtPath:photosCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSArray *cachedPhotoFilepaths = [fileManager contentsOfDirectoryAtPath:photosCacheDirectory error:nil];
            for (NSString *cachedPhotoFilepath in cachedPhotoFilepaths) {
                NSString *absoluteFilePath = [photosCacheDirectory stringByAppendingPathComponent:cachedPhotoFilepath];
                NSString *photoID = [absoluteFilePath lastPathComponent];
                NSData *imageData = [fileManager contentsAtPath:absoluteFilePath];
                [self.memoryCache setObject:[NSPurgeableData dataWithData:imageData] forKey:photoID cost:[imageData length]];
            }
        }
    }
    return self;
}

- (NSData *)imageDataForPhoto:(NSDictionary *)photo withFileManager:(NSFileManager *)fileManager
{
    // check file-based cache
    NSURL *cacheDirectory = (NSURL *) [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *cacheDirectoryPathString = [cacheDirectory path];
    NSString *photoID = (NSString *) [photo valueForKey:FLICKR_PHOTO_ID];
    __block NSData *imageData = (NSData *) [self.memoryCache objectForKey:photoID];
    if (!imageData) {
        NSString *photosCacheDirectory = [cacheDirectoryPathString stringByAppendingPathComponent:@"photos"];
        NSString *filepathString = [photosCacheDirectory stringByAppendingPathComponent:photoID];
        
        NSLog(@"FlickrPhotoCache imageDataForPhoto:withFileManager [NSData dataWithContentsOfURL]");
        imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]]; // don't put this in a new thread because we need to return it
        
        dispatch_queue_t fileWritingQueue = dispatch_queue_create("file writer", NULL);
        dispatch_async(fileWritingQueue, ^{
            NSFileManager *blockFileManager = [[NSFileManager alloc] init];
            if (![blockFileManager createFileAtPath:filepathString contents:imageData attributes:nil]) {
                NSLog(@"Unable to write file to cache!");
            } else {
                [self.memoryCache setObject:[NSPurgeableData dataWithData:imageData] forKey:photoID cost:[imageData length]];
            }
        });
        dispatch_release(fileWritingQueue);
    }
    return imageData;
}

@end
