//
//  RecentPhotosTableViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotosTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *place;
@end
