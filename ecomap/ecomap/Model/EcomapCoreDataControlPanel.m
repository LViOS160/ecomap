//
//  EcomapCoreDataControlPanel.m
//  ecomap
//
//  Created by Admin on 19.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"
#import "Test.h"
#import "EcomapProblem.h"
@implementation EcomapCoreDataControlPanel
+(instancetype)sharedInstance
{
    static EcomapCoreDataControlPanel *object;
    static dispatch_once_t predicat;
    dispatch_once(&predicat, ^{object = [[EcomapCoreDataControlPanel alloc] init];});
    return object;
}


-(void)addProblemIntoCoreData
{

    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
 
    NSError *error;
    
    for(id object in self.allProblems )
    {
        Test *ob = [NSEntityDescription insertNewObjectForEntityForName:@"Test" inManagedObjectContext:context];
        if([object isKindOfClass:[EcomapProblem class]])
        {
            EcomapProblem *problem = (EcomapProblem*) object;
            [ob setName:(NSString*)problem.title];
       
            
            [context save:&error];
           
        }
    }
    
    
  /*  NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"Test" inManagedObjectContext:context];
    [request setEntity:descr];
    //[request setResultType:NSDictionaryResultType];
    NSArray *arr = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    for(id object in arr)
    {
        
        if([object isKindOfClass:[Test class]])
        {
           Test* ob = (Test*)object;
            [context deleteObject:ob];
            NSLog(@"Title:  %@", ob.name);
        }
       
    }*/
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"Test"
     
                inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    
    NSString *targetUsername =@"Pavlo";
    
    NSPredicate *predicate =
    
    [NSPredicate predicateWithFormat:@"name == %@", targetUsername];
    
    [request setPredicate:predicate];
    
    
    
    NSError *error1;
    
    NSArray *array = [context executeFetchRequest:request error:&error1];
    
    if (array != nil)
    {
        NSLog(@"%@", [array firstObject]);
        
    }
    
    else
    {
        
     
        
    }

    
    
    
}



@end
