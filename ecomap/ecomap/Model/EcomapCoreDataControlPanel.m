//
//  EcomapCoreDataControlPanel.m
//  ecomap
//
//  Created by Admin on 19.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"
#import "EcomapProblem.h"
#import "EcomapFetcher.h"

@implementation EcomapCoreDataControlPanel

+ (instancetype)sharedInstance
{
    static EcomapCoreDataControlPanel *object;
    static dispatch_once_t predicat;
    dispatch_once(&predicat,
                  ^{
                      object = [[EcomapCoreDataControlPanel alloc] init];
                  });
    return object;
}



- (void)loadData
{
  

    
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error)
     {
         self.allProblems = [NSArray arrayWithArray:problems];
         if (!error)
         {
             self.allProblems = [NSArray arrayWithArray:problems];
         }
     }];
    
    [EcomapFetcher loadAllProblemsDescription:^(NSArray *problems, NSError *error)
     {
         self.allProblems = [NSArray arrayWithArray:problems];
         if (!error)
         {
             self.descr = [NSArray arrayWithArray:problems];
             [self addProblemIntoCoreData];
         }
     }];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"complete" forKey:@"firstdownload"];
}


- (Problem*)returnDetail:(NSInteger)identifier
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idProblem == %i", identifier];
    [request setPredicate:predicate];
    NSArray *array = [context executeFetchRequest:request error:nil];
    return array[0];
}


- (void)addProblemIntoCoreData
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error;
    NSInteger i = 0;
    
    for(NSManagedObject *object in self.allProblems )
    {
        Problem *ob = [NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:context];
        if([object isKindOfClass:[EcomapProblem class]])
        {
            EcomapProblem *problem = (EcomapProblem*) object;
            EcomapProblemDetails *problemDetail = self.descr[i];
            [ob setTitle:(NSString*)problem.title];
            [ob setLatitude:[NSNumber numberWithFloat: problem.latitude]];
            [ob setLongitude:[NSNumber numberWithFloat:problem.longitude]];
            [ob setDate:problem.dateCreated];
            [ob setNumberOfComments:[NSNumber numberWithInteger: problemDetail.numberOfComments]];
            [ob setNumberOfVotes:[NSNumber numberWithInteger: problemDetail.votes]];
            [ob setContent:problemDetail.content];
            [ob setSeverity:[NSNumber numberWithInteger: problemDetail.severity]];
            [ob setIdProblem:[NSNumber numberWithInteger: problem.problemID]];
            [ob setProposal:problemDetail.proposal];
            [ob setProblemTypeId:[NSNumber numberWithInteger: problemDetail.problemTypesID]];
            [ob setUserID:[NSNumber numberWithInteger: problem.userCreator]];
            i++;
        }
    }
    [context save:&error];
    
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Problem" inManagedObjectContext:context];
    [request setEntity:descr];
    
    NSArray *arr = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    
    for(NSManagedObject *object in arr)
    {
        
        if([object isKindOfClass:[Problem class]])
        {
            Problem* ob = (Problem*)object;
            
        }
    }
    
    [context save:&error];
    
   
 
    
}

- (void) addResourceIntoCD
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error = nil;
    
    for( id object in self.resourcesFromWeb )
    {
        Resource *currentResource = [NSEntityDescription insertNewObjectForEntityForName:@"Resource" inManagedObjectContext:context];
        if([object isKindOfClass:[EcomapResources class]])
        {
            EcomapResources *resource = (EcomapResources*) object;
            
            [currentResource setTitle:(NSString*)resource.titleRes];
            [currentResource setAlias:(NSString *)resource.alias];
            [currentResource setResourceID:[NSNumber numberWithInteger:resource.resId]];
        }
    }
 
    [context save:&error];
}

- (void)logResourcesOnDemand
{
    NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Resource" inManagedObjectContext:context];
    
    [request setEntity:description];
    [request setResultType:NSDictionaryResultType];
    
    NSError *requestError = nil;
    NSArray *requestArray = [context executeFetchRequest:request error:&requestError];
    
    NSLog(@"%@", requestArray);
}

- (void) addContentToResource: (NSNumber*) currentID
{
    NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Resource" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(resourceID = %@)", currentID];
    [fetchRequest setPredicate:predicate];
    
    NSArray *requestArray = [context executeFetchRequest:fetchRequest error:nil];
    Resource *res = [requestArray firstObject];
    res.content = self.resourceContent;
    [context save:nil];
}

// added Iuliia Korniichuk

- (void) addCommentsIntoCoreData:(NSUInteger)problemID
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error = nil;
    
    NSNumber *problemId = [NSNumber numberWithInteger:problemID];
    
    
    for(id object in self.commentsFromWeb)
    {
        Comment *currentComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
        NSDictionary *commentDictionary = (NSDictionary*) object;
        
        [currentComment setCreated_by:(NSString*)[commentDictionary valueForKey:@"created_by"]];
        [currentComment setContent:(NSString*)[commentDictionary valueForKey:@"content"]];
        [currentComment setComment_id:(NSNumber*)[commentDictionary valueForKey:@"id"]];
        [currentComment setUser_id:(NSNumber*)[commentDictionary valueForKey:@"user_id"]];
        [currentComment setCreated_date:(NSString*)[commentDictionary valueForKey:@"created_date"]];
        [currentComment setId_of_problem:(NSNumber*)problemId];
        
        if (![[commentDictionary valueForKey:@"modified_date"] isKindOfClass:[NSNull class]])
        {
            [ currentComment setModified_date:(NSString*)[commentDictionary valueForKey:@"modified_date"]];
        }

    
    

//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem"
//                                                  inManagedObjectContext:context];
//        [request setEntity:entity];
//        request.predicate = [NSPredicate predicateWithFormat:@"idProblem == %@", (NSNumber*)currentComment.problem_id];
//       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idProblem == %@", currentComment.problem_id];
//       [request setPredicate:predicate];
//        
//        NSArray *array = [context executeFetchRequest:request error:nil];
//        if (array[0])
//        {
//            if ([array[0] isKindOfClass:[Problem class]])
//            {
//                Problem *currentProblem = (Problem *) array[0];
//                NSLog (@"%@", currentProblem.idProblem);
//                currentComment.problem = currentProblem;
//                NSLog (@"\\\\\%@", currentComment.problem);
//            }
//
    
    
    
    }
    [context save:&error];

}

-(void)requestForAllComments
{
   
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context];
    
    [request setEntity:description];
    [request setResultType:NSDictionaryResultType];
    
    NSError *requestError = nil;
    NSArray *requestArray = [context executeFetchRequest:request error:&requestError];
    
    NSLog(@"%@", requestArray);
}

@end
