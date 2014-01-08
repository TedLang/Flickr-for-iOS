//
//  RecentPhotosTVC.m
//  TopPlace
//
//  Created by Yu Lang on 12/14/13.
//  Copyright (c) 2013 Yu Lang. All rights reserved.
//

#import "RecentPhotosCDTVC.h"
#import "Recent.h"
#import "Photo.h"
#import "SharedDocumentHandler.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"


@interface RecentPhotosCDTVC ()

@property (strong, nonatomic) SharedDocumentHandler *sh;

@end

@implementation RecentPhotosCDTVC

- (SharedDocumentHandler *)sh
{
    if (!_sh) {
        _sh = [SharedDocumentHandler sharedDocumentHandler];
    }
    return _sh;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.sh useDocumentWithOperation:^(BOOL success) {
        [self setupFetchedResultController];
    }];
}

- (void)setupFetchedResultController
{
    if (self.sh.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.lastReview" ascending:NO]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.sh.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];;
    
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
    NSDictionary *photoDictionary = [self PhotoDictionaryTranfer:photo];
    pvc.imageURL = [FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge];
    pvc.title = photo.title;    
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
