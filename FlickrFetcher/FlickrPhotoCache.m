//
//  FlickrPhotoCache.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoCache.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoCache() <NSCacheDelegate>

@property (readonly, strong, nonatomic) NSCache *memoryCache;
@property (readonly) NSUInteger CACHE_LIMIT;
@property (readonly, strong, nonatomic) NSString *photosCacheDirectory;
@property (readonly, strong, nonatomic) NSCache *photoIDCache;

@end

@implementation FlickrPhotoCache

@synthesize memoryCache = _memoryCache, photosCacheDirectory = _photosCacheDirectory, photoIDCache = _photoIDCache;

- (NSUInteger)CACHE_LIMIT
{
    return 10000000; // 10MB
}

- (void)setObject:(NSData *)imageData forKey:(NSString *)photoID cost:(NSUInteger)cost
{
    [_memoryCache setObject:[NSPurgeableData dataWithData:imageData] forKey:photoID cost:cost];
    [_photoIDCache setObject:photoID forKey:photoID cost:cost];   
}

- (id)init
{
    if (self = [super init]) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.totalCostLimit = self.CACHE_LIMIT;
        
        _photoIDCache = [[NSCache alloc] init];
        _photoIDCache.totalCostLimit = self.CACHE_LIMIT;
        _photoIDCache.delegate = self;
        
        // load files into memory from storage
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *cacheDirectory = (NSURL *) [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *cacheDirectoryPathString = [cacheDirectory path];
        _photosCacheDirectory = [cacheDirectoryPathString stringByAppendingPathComponent:@"photos"];
        if ([fileManager createDirectoryAtPath:_photosCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSArray *cachedPhotoFilepaths = [fileManager contentsOfDirectoryAtPath:_photosCacheDirectory error:nil];
            for (NSString *cachedPhotoFilepath in cachedPhotoFilepaths) {
                NSString *absoluteFilePath = [_photosCacheDirectory stringByAppendingPathComponent:cachedPhotoFilepath];
                NSString *photoID = [absoluteFilePath lastPathComponent];
                NSData *imageData = [fileManager contentsAtPath:absoluteFilePath];
                [self setObject:imageData forKey:photoID cost:[imageData length]];
            }
        }
    }
    return self;
}

- (NSData *)imageDataForPhoto:(NSDictionary *)photo
{
    // check file-based cache
    NSString *photoID = (NSString *) [photo valueForKey:FLICKR_PHOTO_ID];
    __block NSData *imageData = (NSData *) [self.memoryCache objectForKey:photoID];
    if (!imageData) {
        NSString *filepathString = [self.photosCacheDirectory stringByAppendingPathComponent:photoID];
        
        NSLog(@"FlickrPhotoCache imageDataForPhoto:withFileManager [NSData dataWithContentsOfURL]");
        imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]]; // don't put this in a new thread because we need to return it
        
        dispatch_queue_t fileWritingQueue = dispatch_queue_create("file writer", NULL);
        dispatch_async(fileWritingQueue, ^{
            NSFileManager *blockFileManager = [[NSFileManager alloc] init];
            if (![blockFileManager createFileAtPath:filepathString contents:imageData attributes:nil]) {
                NSLog(@"Unable to write file to cache!");
            } else {
                [self setObject:imageData forKey:photoID cost:[imageData length]];
            }
        });
        dispatch_release(fileWritingQueue);
    }
    return imageData;
}

#pragma mark - NSCacheDelegate method

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *photoID = (NSString *) obj;
        dispatch_queue_t fileRemovalQueue = dispatch_queue_create("file removal queue", NULL);
        dispatch_async(fileRemovalQueue, ^{
            NSFileManager *blockFileManager = [[NSFileManager alloc] init];
            if (![blockFileManager removeItemAtPath:[self.photosCacheDirectory stringByAppendingPathComponent:photoID] error:nil]) {
                NSLog(@"Unable to delete file from cache folder!");
            }
        });
        dispatch_release(fileRemovalQueue);
    }
}

@end
