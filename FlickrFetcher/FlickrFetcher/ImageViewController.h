//
//  ImageViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface ImageViewController : UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) NSDictionary *photo;
@end
