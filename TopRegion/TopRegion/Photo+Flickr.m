//
//  Photo+Flickr.m
//  TopRegion
//
//  Created by Yu Lang on 12/14/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Photographer+Create.h"
#import "FlickrFetcher.h"
#import "Region+Make.h"

@implementation Photo (Flickr)

// put data into Photo
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_PLACE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] >1)) {
       // handle error
        NSLog(@"Error Happen");
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        if ([photoDictionary[FLICKR_PHOTO_TITLE] length]) {
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.unique = unique;
            photo.photoid = [photoDictionary valueForKey:FLICKR_PHOTO_ID];
            photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
            photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
            photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
            photo.latitude = @([photoDictionary[FLICKR_LATITUDE] doubleValue]);
            photo.longitude = @([photoDictionary[FLICKR_LONGITUDE] doubleValue]);
            photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
            photo.farm = [photoDictionary valueForKey:@"farm"];
            photo.server = [photoDictionary valueForKey:@"server"];
            photo.secret = [photoDictionary valueForKey:@"secret"];
            photo.originalsecret = [photoDictionary valueForKey:@"originalsecret"];
            photo.originalformat = [photoDictionary valueForKey:@"originalformat"];
            
            //set related photographer entity
            NSString *photographerName = [photoDictionary valueForKey:FLICKR_PHOTO_OWNER];
            Photographer *photographer = [Photographer photographerWithName:photographerName
                                                     inManagedObjectContext:context];
            photo.whoTook = photographer;
            
            //set related region entity
            NSURL *RegionURL = [FlickrFetcher URLforInformationAboutPlace:unique];// get the photo's id's url
            NSURLRequest *request = [NSURLRequest requestWithURL:RegionURL];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                                if (!error) {
                                                                    NSDictionary *regionPhoto;
                                                                    NSString *regionTitle;
                                                                    regionPhoto = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:localfile]
                                                                                                                  options:0
                                                                                                                    error:&error];
                                                                    regionTitle = [FlickrFetcher extractRegionNameFromPlaceInformation:regionPhoto];
                                                                    
                                                                    // get the region name
                                                                    photo.region = [Region regionWithName:regionTitle inManagedObjectContext:context];
                                                                    photo.regionname = photo.region.region;
                                                                    if (![photo.region.photographer containsObject:photographer]) {
                                                                        [photo.region addPhotographerObject:photographer];
                                                                        photo.region.popularity = [NSNumber numberWithInt: [photo.region.photographer count]];
                                                                        [photo.whoTook addRegionsObject:photo.region];
                                                                    }
                                                                }
                                                            }];
            [task resume];
            
        }
    }
    
    return photo;
}

//put array of photos into database
+ (void)loadPhotosFromFlickrArray:(NSArray *)photos
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo  inManagedObjectContext:context];
    }
}

@end
