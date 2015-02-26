//
//  EcomapStatsParser.m
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"

@implementation EcomapStatsParser

+ (id)valueForKey:(NSString *)key inGeneralStatsArray:(NSArray *)generalStats
{
    for(id stats in generalStats) {
        if([stats isKindOfClass:[NSArray class]]) {
            if([[(NSArray *)stats firstObject] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *stat = (NSDictionary *)[(NSArray *)stats firstObject];
                if([stat valueForKey:key]) {
                    return [stat valueForKey:key];
                } else {
                    continue;
                }
            }
        }
    }
    
    return nil;
}

+ (NSUInteger)integerForNumberLabelForInstanceNumber:(NSUInteger)num inStatsArray:(NSArray *)generalStats
{
    NSUInteger number = 0;
    
    switch(num) {
        case 0: number = [[self valueForKey:ECOMAP_GENERAL_STATS_PROBLEMS inGeneralStatsArray:generalStats] integerValue]; break;
        case 1: number = [[self valueForKey:ECOMAP_GENERAL_STATS_VOTES inGeneralStatsArray:generalStats] integerValue]; break;
        case 2: number = [[self valueForKey:ECOMAP_GENERAL_STATS_COMMENTS inGeneralStatsArray:generalStats] integerValue]; break;
        case 3: number = [[self valueForKey:ECOMAP_GENERAL_STATS_PHOTOS inGeneralStatsArray:generalStats] integerValue]; break;
    }
    
    return number;
}

+ (NSString *)stringForNameLabelForInstanceNumber:(NSUInteger)number
{
    NSString *name = @"";
    
    switch(number) {
        case 0: name = @"Проблем"; break;
        case 1: name = @"Голосів"; break;
        case 2: name = @"Коментарів"; break;
        case 3: name = @"Фотографій"; break;
    }
    
    return name;
    
}

+ (NSArray *)getPaticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topCharts
{
    NSArray *topChart = nil;
    
    if(kindOfChart <= [topCharts count]) {
        topChart = topCharts[kindOfChart];
    }
    
    return topChart;
}

+ (NSString *)scoreOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart
{
    switch(kindOfChart) {
        case EcomapMostCommentedProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_VALUE]];
        case EcomapMostSevereProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_SEVERITY]];
        case EcomapMostVotedProblemsTopList: return [NSString stringWithFormat:@"%@", [problem valueForKey:ECOMAP_PROBLEM_VOTES]];
    }
    
    return @"";
}

+ (UIImage *)scoreImageOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart
{
    switch(kindOfChart) {
        case EcomapMostCommentedProblemsTopList: return [UIImage imageNamed:@"12"];
        case EcomapMostSevereProblemsTopList: return [UIImage imageNamed:@"16"];
        case EcomapMostVotedProblemsTopList: return [UIImage imageNamed:@"13"];
    }
    
    return [[UIImage alloc] init];
}

+ (EcomapStatsTimePeriod)getPeriodForStatsByIndex:(NSInteger)index
{
    switch(index) {
        case 0: return EcomapStatsForLastDay;
        case 1: return EcomapStatsForLastWeek;
        case 2: return EcomapStatsForLastMonth;
        case 3: return EcomapStatsForLastYear;
        case 4: return EcomapStatsForAllTheTime;
        default: return EcomapStatsForAllTheTime;
    }
}

@end
