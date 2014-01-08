//
//  Region.h
//  TopRegion
//
//  Created by Yu Lang on 12/29/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *photographer;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPhotographerObject:(Photographer *)value;
- (void)removePhotographerObject:(Photographer *)value;
- (void)addPhotographer:(NSSet *)values;
- (void)removePhotographer:(NSSet *)values;

@end
