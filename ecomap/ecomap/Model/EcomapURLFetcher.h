//
//  EcomapURLFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>

// Time periods to get stats url
typedef enum {
    EcomapStatsForAllTheTime,
    EcomapStatsForLastYear,
    EcomapStatsForLastMonth,
    EcomapStatsForLastWeek,
    EcomapStatsForLastDay
} EcomapStatsTimePeriod;

@interface EcomapURLFetcher : NSObject

//Return API URL to get all problems
+ (NSURL *)URLforAllProblems;

//Return API URL to get problem with ID
+ (NSURL *)URLforProblemWithID:(NSUInteger)problemID;

//Return API URL to logIn
+ (NSURL *)URLforLogin;

//Return URL for top charts of problems
+ (NSURL *)URLforTopChartsOfProblems;

//Return URL for stats for particular period
+ (NSURL *)URLforStatsForParticularPeriod:(EcomapStatsTimePeriod)period;

//Return URL for general stats
+ (NSURL *)URLforGeneralStats;
//Return API URL to Register
+(NSURL*)URLforRegister;
@end
