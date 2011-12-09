//
//  ImageViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize image = _image;

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
    self.imageView.image = self.image;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    CGSize imageSize = self.image.size;
    self.scrollView.contentSize = imageSize;//bounds.size;
    //self.scrollView.bounds; // TODO hint tells us to use this
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
