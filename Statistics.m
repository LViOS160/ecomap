//
//  Statistics.m
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "Statistics.h"

@implementation Statistics

+(instancetype)sharedInstanceStatistics
{
    static Statistics* singleton;
    static dispatch_once_t token;
    dispatch_once(&token, ^{singleton = [[Statistics alloc] init];});
    return singleton;
}


-(NSMutableArray*)countAllProblemsCategory
{
    self.allProblemsPieChart = [[NSMutableArray alloc] initWithCapacity:10];

    
    NSInteger arr[6];
 
    for (NSInteger i = 0; i < 6; i++) {
        arr[i] = 0;
    }
    for (NSInteger i = 0; i < [self.allProblems count]; i++)
    {
        self.currentProblem =  self.allProblems[i];
       switch (self.currentProblem.problemTypesID) {
            case 1:
               arr[0]++;
                break;
           case 2:
             arr[1]++;
               break;
           case 3:
             arr[2]++;
               break;
           case 4:
            arr[3]++;
               break;
           case 5:
            arr[4]++;
               break;
           case 6:
              arr[5]++;
               break;
     
       }
    
    }
    
    for( NSInteger i = 0; i<6; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.allProblemsPieChart addObject:tmp];
    }
    
    return self.allProblemsPieChart;
}


@end
