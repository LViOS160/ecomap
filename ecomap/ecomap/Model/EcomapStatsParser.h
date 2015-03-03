//
//  EcomapStatsParser.h
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EcomapURLFetcher.h"

// Titles for top charts

#define ECOMAP_MOST_VOTED_PROBLEMS_CHART_TITLE @"ТОП 10 популярних проблем"
#define ECOMAP_MOST_SEVERE_PROBLEMS_CHART_TITLE @"ТОП 10 важливих проблем"
#define ECOMAP_MOST_COMMENTED_PROBLEMS_CHART_TITLE @"ТОП 10 обговорюваних проблем"

typedef enum {
    EcomapMostVotedProblemsTopList = 0,     // most voted
    EcomapMostSevereProblemsTopList,        // most severe
    EcomapMostCommentedProblemsTopList      // most commented
} EcomapKindfOfTheProblemsTopList;

@interface EcomapStatsParser : NSObject

+ (NSUInteger)integerForNumberLabelForInstanceNumber:(NSUInteger)num inStatsArray:(NSArray *)generalStats;
+ (NSString *)stringForNameLabelForInstanceNumber:(NSUInteger)number;
+ (NSArray *)getPaticularTopChart:(EcomapKindfOfTheProblemsTopList)kindOfChart from:(NSArray *)topChart;
+ (NSString *)scoreOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart;
+ (UIImage *)scoreImageOfProblem:(NSDictionary *)problem forChartType:(EcomapKindfOfTheProblemsTopList)kindOfChart;
+ (EcomapStatsTimePeriod)getPeriodForStatsByIndex:(NSInteger)index;

@end
