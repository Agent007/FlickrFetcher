//
//  Vacation+Create.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacation.h"

@interface Vacation (Create)

+ (Vacation *)vacationWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;

@end
