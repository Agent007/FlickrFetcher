//
//  VacationViewControllerDataSource.h
//  FlickrFetcher
//
//  Created by Jeffrey Lam on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VacationViewControllerDataSource <NSObject>

@property (nonatomic, strong) UIManagedDocument *vacationDatabase;

- (void)synchronize;

@end
