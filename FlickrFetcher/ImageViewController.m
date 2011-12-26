//
//  ImageViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"

@interface ImageViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ImageViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize photo = _photo;
@synthesize titleLabel;

- (NSDictionary *)photo
{
    if (!_photo) {
        _photo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_PHOTOS"] lastObject];
    }
    return _photo;
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]]];
    self.titleLabel.text = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGSize imageSize = self.imageView.image.size;
    self.scrollView.contentSize = imageSize;//bounds.size;
    //self.scrollView.bounds; // TODO hint 11 of assignment 4 tells us to use this
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    self.imageView.frame = CGRectMake(0, 0, width, height);
    CGRect zoomRect;
    if (width < height) {
        zoomRect = CGRectMake(0, 0, width, width);
    } else {
        zoomRect = CGRectMake(0, 0, height, height);
    }
    [self.scrollView zoomToRect:zoomRect animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // save this photo in recently-viewed photos list
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *LAST_PHOTOS = @"LAST_PHOTOS";
    NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[defaults objectForKey:LAST_PHOTOS]];
    if (!lastPhotos) {
        lastPhotos = [NSMutableOrderedSet orderedSet];
    }
    [lastPhotos removeObject:self.photo]; // if we view a photo from recently viewed photos list, put it on top of list
    [lastPhotos addObject:self.photo];
    if ([lastPhotos count] > 20) { // cap the number of recently-viewed photos list to 20
        NSMutableOrderedSet *reverseSet = [[lastPhotos reversedOrderedSet] mutableCopy];
        NSRange range;
        range.location = 0;
        range.length = 20;
        reverseSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:reverseSet range:range copyItems:YES];
        lastPhotos = [[reverseSet reversedOrderedSet] mutableCopy];
    }
    [defaults setObject:[lastPhotos array] forKey:LAST_PHOTOS];
    [defaults synchronize];

}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.scrollView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
