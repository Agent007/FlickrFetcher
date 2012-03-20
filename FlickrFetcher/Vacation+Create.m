//
//  Vacation+Create.m
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacation+Create.h"

@implementation Vacation (Create)

+ (Vacation *)vacationWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context
{
    Vacation *vacation = [NSEntityDescription insertNewObjectForEntityForName:@"Vacation"
                                               inManagedObjectContext:context];
    vacation.title = title;
    
    return vacation;
}

@end
