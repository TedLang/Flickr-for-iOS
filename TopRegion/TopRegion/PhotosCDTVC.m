//
//  PhotosTVC.m
//  TopPlaces
//
//  Created by Yu Lang on 1/7/14.
//  Copyright (c) 2014 Yu Lang. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "PhotoViewController.h"
#import "Recent+Photo.h"
#import "Photo.h"
#import "FlickrFetcher.h"

@interface PhotosCDTVC ()

@end

@implementation PhotosCDTVC


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"region.region = %@",self.predicate];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    
    if (!cell.imageView.image) {
        dispatch_queue_t q = dispatch_queue_create("Thumbnail Flickr Photo", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [photo.managedObjectContext performBlock:^{
                photo.thumbnail = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsDisplay];
                });
            }];
        });
    }
    
    return cell;
}

#pragma pass the value to the next view

// prepare scroll view for next window
- (void)preparePhotoViewController:(PhotoViewController *)pvc
                          forPhoto:(Photo *)photo
{
    //pvc.imageURL = [NSURL URLWithString:photo.imageURL];
    NSDictionary *photoDictionary = [self PhotoDictionaryTranfer:photo];
    //NSLog(@"Dictionary is %@", photoDictionary);
    pvc.imageURL = [FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge];
    pvc.title = photo.title;
    [Recent recentPhoto:photo];
    photo.recent = [Recent recentPhoto:photo];
    
    //[RecentPhotos addPhoto:photo];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"Show Photo"] && indexPath) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self preparePhotoViewController:segue.destinationViewController forPhoto:photo];
    }
}

- (NSDictionary *)PhotoDictionaryTranfer:(Photo *)photo
{
    NSDictionary *photoDictinary = [NSDictionary dictionaryWithObjectsAndKeys:photo.farm, @"farm",
                                                                              photo.server, @"server",
                                                                              photo.photoid, @"id",
                                                                              photo.secret, @"secret",
                                                                              photo.originalsecret, @"originalsecret",
                                                                              photo.originalformat, @"originalformat", nil];
    
    
    return photoDictinary;
}
@end
