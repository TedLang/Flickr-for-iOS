//
//  TopPlacesTVC.m
//  TopPlaces
//
//  Created by Yu Lang on 1/7/14.
//  Copyright (c) 2014 Yu Lang. All rights reserved.
//

#import "TopPlacesCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailabilityContext.h"
#import "TopRegionAppDelegate.h"

@interface TopPlacesCDTVC ()

@end

@implementation TopPlacesCDTVC

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *regions;
                                                    if (!error) {
                                                        regions = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                   options:0
                                                                                                     error:&error]
                                                                   valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                                            if (!error) {
                                                                for (NSDictionary *photo in regions) {
                                                                    [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
                                                                }
                                                                [self.refreshControl endRefreshing];
                                                            } else {
                                                                NSLog(@"Error loading TopPlaces: %@", error);
                                                            }
                                                    });
                                                }];
    [task resume];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}

@end
