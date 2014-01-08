//
//  Region+Make.m
//  TopRegion
//
//  Created by Yu Lang on 12/24/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "Region+Make.h"

@implementation Region (Make)

+ (Region *)regionWithName:(NSString *)regionName
    inManagedObjectContext:(NSManagedObjectContext *)context
{    
    Region *region = nil;
    
    if ([regionName length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"region = %@", regionName];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || [matches count] > 1) {
            // handle error
        } else if (![matches count]) {
            // no fetch result, so create new entity
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
            region.region = regionName;
        } else {
            // entity already exit, just get it
            region = [matches lastObject];
        }
    }
    
    return region;
}

@end
