//
//  ImageViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "BackgroundLoader.h"

@interface ImageViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ImageViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize titleLabel = _titleLabel;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize activityIndicatorView = _activityIndicatorView;

- (NSDictionary *)photo
{
    if (!_photo) {
        _photo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_PHOTOS"] lastObject];
    }
    return _photo;
}

- (void)fetchPhoto:(NSDictionary *)photo
{
    NSLog(@"fetchPhotoAndSetTitle: [NSData dataWithContentsOfURL]");
    NSData *imageData = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = self.imageView.image = [UIImage imageWithData:imageData];
        self.scrollView.contentSize = image.size;
        self.imageView.hidden = NO;
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        // for good usability, immediately show photo title while waiting for photo download
        self.titleLabel.text = [photo valueForKey:FLICKR_PHOTO_TITLE];
        self.imageView.hidden = YES;
        [self.activityIndicatorView startAnimating];
        _photo = photo;
        self.scrollView.zoomScale = 1;
        // TODO ensure last photo selected is shown after multiple quick selections while downloading
        [BackgroundLoader viewDidLoad:nil withBlock:^{
            [self fetchPhoto:photo];
        }];
        // save this photo in recently-viewed photos list
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *LAST_PHOTOS = @"LAST_PHOTOS";
        NSMutableOrderedSet *lastPhotos = [NSMutableOrderedSet orderedSetWithArray:[defaults objectForKey:LAST_PHOTOS]];
        if (!lastPhotos) {
            lastPhotos = [NSMutableOrderedSet orderedSet];
        }
        [lastPhotos removeObject:photo]; // if we view a photo from recently viewed photos list, put it on top of list
        [lastPhotos addObject:photo];
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
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photos"; // TODO i18n
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    [BackgroundLoader viewDidLoad:self.activityIndicatorView withBlock:^{
        [self fetchPhoto:self.photo];
    }];
    self.splitViewController.delegate = self;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.scrollView = nil;
    self.toolbar = nil;
    self.activityIndicatorView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
