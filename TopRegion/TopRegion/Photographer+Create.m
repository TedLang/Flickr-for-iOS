//
//  Photographer+Create.m
//  TopRegion
//
//  Created by Yu Lang on 12/17/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || [matches count] > 1) {
            // handle error
        } else if (![matches count]) {
            // no fetch result, so create new entity
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                         inManagedObjectContext:context];
            photographer.name = name;
        } else {
            // entity already exist, just get it
            photographer = [matches lastObject];
        }
    }
    
    return photographer;
}
@end
