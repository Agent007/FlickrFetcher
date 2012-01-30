//
//  BackgroundLoader.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/* Decorator pattern was considered, but assignment hinted at using a helper class (see hint #2)*/

#import <Foundation/Foundation.h>

@interface BackgroundLoader : NSObject

// TODO maybe remove activityIndicatorView since the parameter isn't bein used and a more event-driven object-oriented design would be better anyway
+ (void)viewDidLoad:(UIView *)activityIndicatorView withBlock:(void (^)())block;

@end
