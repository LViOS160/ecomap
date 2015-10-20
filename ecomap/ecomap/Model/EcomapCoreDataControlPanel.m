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
+(instancetype)sharedInstance
{
    static EcomapCoreDataControlPanel *object;
    static dispatch_once_t predicat;
    dispatch_once(&predicat, ^{object = [[EcomapCoreDataControlPanel alloc] init];});
    return object;
}



-(void)loadData
{
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error)
    {
        self.allProblems = [NSArray arrayWithArray:problems];
        if (!error)
            {
              self.allProblems = [NSArray arrayWithArray:problems];
            }
    }];
    
    
    [EcomapFetcher loadAllProblemsDescription:^(NSArray *problems, NSError *error) {
        self.allProblems = [NSArray arrayWithArray:problems];
        if (!error)
        {
            self.descr = [NSArray arrayWithArray:problems];
            [self addProblemIntoCoreData];
        }
    }];
    
     [[NSUserDefaults standardUserDefaults] setObject:@"complete" forKey:@"firstdownload"];
}





-(Problem*)returnDetail:(NSInteger)id1
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Problem"
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idProblem == %i", id1];
    [request setPredicate:predicate];
    NSArray *array = [context executeFetchRequest:request error:nil];

    return array[0];
}


-(void)addProblemIntoCoreData
{
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSError *error;
    NSInteger i = 0;
    
    for(id object in self.allProblems )
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
            i++;
        }
    }
    
    [context save:&error];
    
   
   
    /*
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Problem" inManagedObjectContext:context];
    [request setEntity:descr];
    //[request setResultType:NSDictionaryResultType];
    NSArray *arr = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    for(id object in arr)
    {
        
        if([object isKindOfClass:[Problem class]])
        {
          Problem* ob = (Problem*)object;
        
          //  [context deleteObject:ob];
         //   NSLog(@"Title:  %@ Content: %@  \nDate: %@ ", ob.title, ob.content , ob.date);
         //[context deleteObject:ob];
            
        }
      // [context save:nil];
    }*/
    
 
    
}



@end
