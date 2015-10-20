//
//  EcomapRevisionCoreData.m
//  ecomap
//
//  Created by Pavlo Dumyak on 10/20/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapRevisionCoreData.h"
#import "EcomapFetcher.h"
#import "AppDelegate.h"
@implementation EcomapRevisionCoreData

+ (instancetype)sharedInstance
{
    static EcomapRevisionCoreData *object;
    static dispatch_once_t predicat;
    dispatch_once(&predicat, ^{object = [[EcomapRevisionCoreData alloc] init];});
    return object;
}


- (void)checkRevison
{
  
    [EcomapFetcher checkRevision:^(BOOL differance, NSError *error) {
    if (!error)
        {
            if(differance)
            {
                [EcomapFetcher loadProblemsDifferance:^(NSArray *problems, NSError *error)
                {
                    self.allRevisions = [NSArray arrayWithArray:problems];
                    if (!error)
                    {
                        [self loadDifferance];
                    }
                }];
            }
        }
    }];
}


- (void)loadDifferance
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem"
                                              inManagedObjectContext:context];
    
    [request setEntity:entity];
    NSPredicate *predicate;
    NSArray *array;
    Problem *ob = [NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:context];
  
    
    for(int i = 0; i< [self.allRevisions count];i++)
    {
    
        NSNumber *problemId =  [self.allRevisions[i] valueForKey:@"id"];
        int num = [problemId intValue];
        predicate = [NSPredicate predicateWithFormat:@"idProblem == %i", num];
        [request setPredicate:predicate];
        array = [context executeFetchRequest:request error:nil];
      
        if([array count]== 0)
        {
             [ob setTitle: [self.allRevisions[i] valueForKey:@"title"]];
            NSLog(@"%@",[self.allRevisions[i] valueForKey:@"title"]);
             [ob setLatitude: [self.allRevisions[i] valueForKey:@"latitude"]];
             NSLog(@"%@",[self.allRevisions[i] valueForKey:@"latitude"]);
             [ob setLongitude:[self.allRevisions[i] valueForKey:@"longitude"]];
              NSLog(@"%@",[self.allRevisions[i] valueForKey:@"longitude"]);
       // [ob setDate:[self.allRevisions[i] valueForKey:@"datetime"]];
       // [ob setNumberOfComments:[self.allRevisions[i] valueForKey:@"number_of_comments"]];
        //[ob setNumberOfVotes: [self.allRevisions[i] valueForKey:@"number_of_votes"]];
             [ob setContent:[self.allRevisions[i] valueForKey:@"content"]];
        //[ob setSeverity:[self.allRevisions[i] valueForKey:@"severity"]];
              NSNumber *number =  [self.allRevisions[i] valueForKey:@"id"];
             [ob setIdProblem:number];
             NSLog(@"%@",number);
             [ob setProposal:[self.allRevisions[i] valueForKey:@"proposal"]];
             [context save:nil];
    }
    else
       {
        [context deleteObject:array[0]];
        [context save:nil];
        [ob setTitle: [self.allRevisions[i] valueForKey:@"title"]];
        [ob setLatitude: [self.allRevisions[i] valueForKey:@"latitude"]];
        [ob setLongitude:[self.allRevisions[i] valueForKey:@"longitude"]];
       // [ob setDate:[self.allRevisions[i] valueForKey:@"longitude"]];
        //[ob setNumberOfComments:[self.allRevisions[i] valueForKey:@"datetime"]];
        //[ob setNumberOfVotes: [self.allRevisions[i] valueForKey:@"number_of_votes"]];
        [ob setContent:[self.allRevisions[i] valueForKey:@"content"]];
        //[ob setSeverity:[self.allRevisions[i] valueForKey:@"severity"]];
        //[ob setIdProblem:[self.allRevisions[i] valueForKey:@"id"]];
        NSNumber *number =  [self.allRevisions[i] valueForKey:@"id"];
        [ob setIdProblem:number];
        [ob setProposal:[self.allRevisions[i] valueForKey:@"proposal"]];
        [context save:nil];
       }
        
    }
}


@end
