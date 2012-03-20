//
//  VacationViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "VacationViewControllerDataSource.h"

@interface VacationsTableViewController : CoreDataTableViewController <VacationViewControllerDataSource>

@end
