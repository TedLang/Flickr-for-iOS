//
//  Region+Make.h
//  TopRegion
//
//  Created by Yu Lang on 12/24/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "Region.h"

@interface Region (Make)

+ (Region *)regionWithName:(NSString *)regionName
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
