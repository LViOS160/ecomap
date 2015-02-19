//
//  EcomapFilter.m
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFilter.h"
#import "EcomapProblem.h"

@implementation EcomapFilter

+ (NSArray *)filterProblemsArray:(NSArray *)problems usingFilteringMask:(EcomapProblemFilteringMask *)mask
{
    NSMutableArray *filteredProblems = [[NSMutableArray alloc] init];

    for(EcomapProblem *problem in problems) {
        if([problem isKindOfClass:[EcomapProblem class]]) {
            EcomapProblem *ecoProblem = (EcomapProblem *)problem;
            if([self checkProblem:ecoProblem usingFilteringMask:mask]) {
                [filteredProblems addObject:ecoProblem];
            }
        }
    }
    
    return filteredProblems;
}


+ (BOOL)checkProblem:(EcomapProblem *)problem usingFilteringMask:(EcomapProblemFilteringMask *)mask
{
    if([mask.problemTypes containsObject:[NSNumber numberWithInteger:problem.problemTypesID]]) {
        if([self isDate:problem.dateCreated inRangeFromDate:mask.fromDate toDate:mask.toDate]) {
            if([self checkStatusOfProblem:problem usingFilteringMask:mask]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)checkStatusOfProblem:(EcomapProblem *)problem usingFilteringMask:(EcomapProblemFilteringMask *)mask
{
    if(mask.showSolved && mask.showUnsolved) {
        return YES;
    } else if(mask.showSolved && !mask.showUnsolved) {
        if(problem.isSolved) {
            return YES;
        }
    } else if(!mask.showSolved && mask.showUnsolved) {
        if(!problem.isSolved) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isDate:(NSDate *)date inRangeFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSTimeInterval intervalFromBeginOfTheRangeToDate = [date timeIntervalSinceDate:fromDate];
    NSTimeInterval intervalFromDateToEndOfTheRange = [toDate timeIntervalSinceDate:date];
    
    if((intervalFromBeginOfTheRangeToDate > 0) && (intervalFromDateToEndOfTheRange) > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
