//
//  LastViewedPhotosTableViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastViewedPhotosTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos; // TODO may be changed to "atomic" later when mult-threading is implemented in next assignment

@end
