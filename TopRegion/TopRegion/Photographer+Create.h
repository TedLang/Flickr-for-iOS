//
//  Photographer+Create.h
//  TopRegion
//
//  Created by Yu Lang on 12/17/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;
@end
