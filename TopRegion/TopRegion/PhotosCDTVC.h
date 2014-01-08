//
//  PhotosTVC.h
//  TopPlaces
//
//  Created by Yu Lang on 1/7/14.
//  Copyright (c) 2014 Yu Lang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface PhotosCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *predicate;

@end
