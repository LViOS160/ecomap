//
//  EcomapStatsFetcher.m
//  EcomapStatistics
//
//  Created by ohuratc on 05.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "EcomapStatsFetcher.h"
#import "EcomapPathDefine.h"

@implementation EcomapStatsFetcher

+ (NSArray *)getPaticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topCharts
{
    NSArray *topChart = nil;
    
    if(kindOfChart <= [topCharts count]) {
        topChart = topCharts[kindOfChart];
    }
    
    return topChart;
}

+ (NSString *)getTitleForParticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart fromProblem:(NSDictionary *)problem
{
    switch (kindOfChart) {
        case EcomapMostCommentedProblemsTopList: return [NSString stringWithFormat:@"✒️%@", [problem valueForKey:ECOMAP_PROBLEM_VALUE]];
        case EcomapMostSevereProblemsTopList: return [NSString stringWithFormat:@"⭐️%@", [problem valueForKey:ECOMAP_PROBLEM_SEVERITY]];
        case EcomapMostVotedProblemsTopList: return [NSString stringWithFormat:@"❤️%@", [problem valueForKey:ECOMAP_PROBLEM_VOTES]];
    }
    
    return @"";
}

@end
