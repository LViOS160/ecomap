//
//  Statistics.h
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblem.h"

@interface Statistics : NSObject
+(instancetype)sharedInstanceStatistics;
-(NSMutableArray*)countAllProblemsCategory;
@property (nonatomic) NSMutableArray* allProblemsPieChart;
@property (nonatomic, strong) NSArray* allProblems;
@property (nonatomic, weak)   EcomapProblem* currentProblem;
@end
