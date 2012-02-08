//
//  i5CustomFlipOverStoryboardSegue.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "i5CustomFlipOverStoryboardSegue.h"

@implementation i5CustomFlipOverStoryboardSegue

- (void)perform
{
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    [UIView commitAnimations];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:appDelegate.window.rootViewController.view.superview cache:YES];
    [srcViewController.view removeFromSuperview];
    [UIView commitAnimations];
    [appDelegate.window addSubview:destViewController.view];
    appDelegate.window.rootViewController=destViewController;
}

@end
