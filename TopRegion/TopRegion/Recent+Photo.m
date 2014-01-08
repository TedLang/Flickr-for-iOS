//
//  Recent+Photo.m
//  TopRegion
//
//  Created by Yu Lang on 1/4/14.
//  Copyright (c) 2014 Yu Lang. All rights reserved.
//

#import "Recent+Photo.h"

@implementation Recent (Photo)

#define RECENT_FLICKR_PHOTOS_NUMBER 20
+ (Recent *)recentPhoto:(Photo *)photo
{
    Recent *recent = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    
    NSError *error;
    NSArray *matches = [photo.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1) {
        // handle error
    } else if (![matches count]){
        // no fetch result, so create new entity
        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:photo.managedObjectContext];
        recent.lastReview = [NSDate date];
        recent.photo = photo;
        request.predicate = nil;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastReview" ascending:NO]];
        matches = [photo.managedObjectContext executeFetchRequest:request error:&error];
        if ([matches count] > RECENT_FLICKR_PHOTOS_NUMBER) {
            [photo.managedObjectContext deleteObject:[matches lastObject]];
        }
    } else {
        // entity already eixt, just get it
        recent = [matches lastObject];
        recent.lastReview = [NSDate date];
    }
    
    return recent;
}
@end
