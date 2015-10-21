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
    
    
;
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
    EcomapCoreDataControlPanel *coreObject = [EcomapCoreDataControlPanel sharedInstance];

    NSPredicate *predicate;
    NSArray *array;
    NSMutableArray *arrayOne = [NSMutableArray array];
    NSMutableArray *arrayTwo = [NSMutableArray array];
    
     for(int i = 0; i< [self.allRevisions count];i++)
     {
         EcomapProblemDetails *differentPartOfProblemsDetails = [[EcomapProblemDetails alloc]
                                                                 initWithProblem:self.allRevisions[i]];
         [arrayOne addObject:differentPartOfProblemsDetails];
         EcomapProblem *differentPartOfProblemsGeneral = [[EcomapProblem alloc]
                                                          initWithProblem:self.allRevisions[i]];
         [arrayTwo addObject:differentPartOfProblemsGeneral];
     }
    
    
    

    for(int i = 0; i< [self.allRevisions count];i++)
    {
    
        NSNumber *problemId =  [self.allRevisions[i] valueForKey:@"id"];
        int num = [problemId intValue];
        predicate = [NSPredicate predicateWithFormat:@"idProblem == %i", num];
        [request setPredicate:predicate];
        array = [context executeFetchRequest:request error:nil];
        
        if([array count] == 0)
        {
                Problem *ob = [NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:context];
                EcomapProblem *problem = arrayTwo[i];
                EcomapProblemDetails *problemDetail =  arrayOne[i];
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
                [context save:nil];
                [coreObject.map loadProblems];
        }
        else
        {
            [context deleteObject:array[0]];
            [context save:nil];
            Problem *ob = [NSEntityDescription insertNewObjectForEntityForName:@"Problem" inManagedObjectContext:context];
            EcomapProblem *problem = arrayTwo[i];
            EcomapProblemDetails *problemDetail =  arrayOne[i];
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
            [context save:nil];
            [coreObject.map loadProblems];
            
        }
    }
   
   
    
    
    
}


@end
