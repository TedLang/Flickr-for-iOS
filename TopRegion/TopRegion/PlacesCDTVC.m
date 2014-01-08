//
//  PlacesTVC.m
//  TopPlaces
//
//  Created by Yu Lang on 1/7/14.
//  Copyright (c) 2014 Yu Lang. All rights reserved.
//

#import "PlacesCDTVC.h"
#import "PlacePhotosCDTVC.h"
#import "PhotoDatabaseAvailabilityContext.h"
#import "Photo.h"
#import "Region.h"

@implementation PlacesCDTVC

#pragma mark set the NSNotification Observer to get the data

// get user-info frome NSNotification
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    NSSortDescriptor *popularitySort = [[NSSortDescriptor alloc] initWithKey:@"popularity" ascending:NO];
    NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"region" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObjects:popularitySort, titleSort, nil];
    [request setSortDescriptors:sortArray];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Place Cell"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.region;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Popularity of the region is %@",region.popularity];
    return cell;
}

#pragma mark segue to t
- (void)preparePhotosTVC:(PlacePhotosCDTVC *)tvc
                 forRegion:(Region *)region
{
    tvc.predicate = region.region;
    tvc.managedObjectContext = self.managedObjectContext;
    tvc.title = region.region;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"Show Place"] && indexPath) {
        Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self preparePhotosTVC:segue.destinationViewController
                      forRegion:region];
    }
}

@end
