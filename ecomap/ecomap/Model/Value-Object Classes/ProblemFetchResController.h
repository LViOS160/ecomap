//
//  ProblemFetchResController.h
//  ecomap
//
//  Created by admin on 10/21/15.
//  Copyright © 2015 SoftServe. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ProblemFetchResController : NSFetchedResultsController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) ProblemFetchResController *fetchedResultsController;

@end
