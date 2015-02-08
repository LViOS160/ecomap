//
//  EcomapStatsFetcher.h
//  EcomapStatistics
//
//  Created by ohuratc on 05.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import <Foundation/Foundation.h>

// Titles for top charts

#define ECOMAP_MOST_VOTED_PROBLEMS_CHART_TITLE @"ТОП 10 популярних проблем"
#define ECOMAP_MOST_SEVERE_PROBLEMS_CHART_TITLE @"ТОП 10 важливих проблем"
#define ECOMAP_MOST_COMMENTED_PROBLEMS_CHART_TITLE @"ТОП 10 обговорюваних проблем"

typedef enum {
    EcomapMostVotedProblemsTopList = 0,    // most voted
    EcomapMostSevereProblemsTopList = 1,     // most severe
    EcomapMostCommentedProblemsTopList = 2  // most commented
} EcomapKindfOfTheProblemsTopList;

@interface EcomapStatsFetcher : NSObject

+ (NSArray *)getPaticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topChart;
+ (NSString *)getTitleForParticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart fromProblem:(NSDictionary *)problem;

@end
