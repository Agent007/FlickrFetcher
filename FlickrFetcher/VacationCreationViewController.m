//
//  VacationCreationViewController.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationCreationViewController.h"
#import "Vacation+Create.h"

@interface VacationCreationViewController ()

@end

@implementation VacationCreationViewController

@synthesize titleTextField;
@synthesize datasource;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"save"]) {
        UIManagedDocument *managedDocument = datasource.vacationDatabase;
        [Vacation vacationWithTitle:titleTextField.text inManagedObjectContext:managedDocument.managedObjectContext];
        [datasource synchronize];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setTitleTextField:nil];
    [super viewDidUnload];
}
@end
