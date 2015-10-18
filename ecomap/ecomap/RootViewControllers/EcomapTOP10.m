//
//  TOP10.m
//  ecomap
//
//  Created by admin on 10/12/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapTOP10.h"
@interface EcomapTOP10()
//@property (nonatomic) NSMutableArray* problemVote;
//@property (nonatomic) NSMutableArray* problemComment;
//@property (nonatomic) NSMutableArray* problemSeverity;
@end

@implementation EcomapTOP10
+(instancetype)sharedInstanceTOP10
{
    static EcomapTOP10* singleton;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        singleton = [[EcomapTOP10 alloc] init];
    });
    return singleton;
}


-(void)sortAllProblems
{
    self.problemComment = [[NSMutableArray alloc]initWithCapacity:10];
    self.problemSeverity = [[NSMutableArray alloc]initWithCapacity:10];
    self.problemVote = [[NSMutableArray alloc]initWithCapacity:10];
    for (int i = 0; i < 10; i++)
    {
        self.problemVote[i] = self.allProblems[i];
        self.problemSeverity[i] = self.allProblems[i];
        self.problemComment[i] = self.allProblems[i];
    }
    EcomapProblem *problem;
    BOOL voted = NO, commented = NO, sevrity = NO;
    //for (problem in self.allProblems)
    for (int j = 10; j < self.allProblems.count; j++)
    {
        problem = self.allProblems[j];
        voted = NO;
        commented = NO;
        sevrity = NO;
        for (int i = 0; i < 10; i++)
        {
            EcomapProblem * contProblem = self.problemVote[i];
            if (problem.vote > contProblem.vote && voted == NO)
            {
                voted = YES;
                self.problemVote[i] = problem;
            }
            contProblem = self.problemSeverity[i];
            if (problem.severity > contProblem.severity && sevrity == NO)
            {
                sevrity = YES;
                self.problemSeverity[i] = problem;
            }
            contProblem = self.problemComment[i];
            if (problem.numberOfComments > contProblem.numberOfComments && commented == NO)
            {
                commented = YES;
                self.problemComment[i] = problem;
            }
            
        }
    }
    self.allProblemsPieChart = self.problemComment;
    //return self.allProblemsPieChart;
}

@end
