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

- (void) addResourceIntoCD:(NSArray *)resources
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error = nil;
    
    for( id object in resources )
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

- (void) addCommentsIntoCoreData:(NSUInteger)problemID comments:(NSArray*)comments
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error = nil;
    
    NSArray *commentsFormCD = [self commentsFromCoreData];
    
    for (NSDictionary* commentDictionary in comments)
    {
        NSNumber *commentID = @([[commentDictionary valueForKey:@"id"] integerValue]);
        NSString *commentModified = nil;
        
        if ([[commentDictionary valueForKey:@"modified_date"] isKindOfClass:[NSString class]])
        {
            commentModified = [commentDictionary valueForKey:@"modified_date"];
        }

        BOOL needsToAdd = YES;
        
        for (Comment *commentFromCD in commentsFormCD)
        {
            if ([commentID integerValue] == [commentFromCD.comment_id integerValue])
            {
                needsToAdd = NO;
                
                if (commentFromCD.modified_date && commentModified && ![commentFromCD.modified_date isEqualToString:commentModified])
                {
                    [self updateComment:commentFromCD withDictionary:commentDictionary];
                }
                
                break;
            }
        }
        
        if (needsToAdd)
        {
            Comment *currentComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
            [currentComment setComment_id:commentID];
            [currentComment setId_of_problem:@(problemID)];

            [self updateComment:currentComment withDictionary:commentDictionary];
        }
    }
    
    [context save:&error];
}

- (void)updateComment:(Comment*)currentComment withDictionary:(NSDictionary*)commentDictionary
{
    [currentComment setCreated_by:(NSString*)[commentDictionary valueForKey:@"created_by"]];
    [currentComment setContent:(NSString*)[commentDictionary valueForKey:@"content"]];
    [currentComment setUser_id:@([[commentDictionary valueForKey:@"user_id"] integerValue])];
    [currentComment setCreated_date:(NSString*)[commentDictionary valueForKey:@"created_date"]];
    
    id modifiedDate = [commentDictionary valueForKey:@"modified_date"];
    if (modifiedDate && [modifiedDate isKindOfClass:[NSString class]])
    {
        [currentComment setModified_date:[commentDictionary valueForKey:@"modified_date"]];
    }
}

- (NSArray*)commentsFromCoreData
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    NSArray *requestArray = [context executeFetchRequest:request error:&requestError];
    
    return !requestError && requestArray ? requestArray : nil;
}


- (void)logCommentsFromCoreData
{
    NSLog(@"%@", [self commentsFromCoreData]);
}

@end
