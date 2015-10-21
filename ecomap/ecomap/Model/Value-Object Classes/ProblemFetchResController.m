//
//  ProblemFetchResController.m
//  ecomap
//
//  Created by admin on 10/21/15.
//  Copyright © 2015 SoftServe. All rights reserved.
//

#import "ProblemFetchResController.h"
#import "AppDelegate.h"

@implementation ProblemFetchResController

@synthesize fetchedResultsController = _fetchedResultsController;

- (ProblemFetchResController *)fetchedResultsController {
    
    if (self.fetchedResultsController != nil) {
        return self.fetchedResultsController;
    }
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Problem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"idProblem" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    
    self.fetchedResultsController = (ProblemFetchResController *)theFetchedResultsController;
    
    return _fetchedResultsController;
    
}


@end
