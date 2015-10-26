//
//  ProblemFetchResController.m
//  ecomap
//
//  Created by admin on 10/21/15.
//  Copyright © 2015 SoftServe. All rights reserved.
//

#import "EcomapFetchedResultController.h"
#import "AppDelegate.h"

@implementation EcomapFetchedResultController

+ (NSFetchRequest*)requestWithEntityName:(NSString*)entityName sortBy:(NSString*)sortDescriptor
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:sortDescriptor ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    return fetchRequest;
}

@end
