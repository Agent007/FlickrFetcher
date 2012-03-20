//
//  VacationCreationViewController.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VacationViewControllerDataSource.h"

@interface VacationCreationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) id <VacationViewControllerDataSource> datasource;

@end
