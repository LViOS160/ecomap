//
//  Statistics.h
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblem.h"
#define URL_PROBLEMS @"http://176.36.11.25:8000/api/problems"
@interface Statistics : NSObject
+(instancetype)sharedInstanceStatistics;
-(NSMutableArray*)countAllProblemsCategory;

-(NSInteger)dataParserVoteCommentsPhotos:(NSString*)text :(NSString*) start : (NSString*) end;

-(void)statisticsForMonth;
-(void)statisticsForDay;
-(void)statisticsForWeek;

@property (nonatomic) NSMutableArray* allProblemsPieChart;
@property (nonatomic, strong) NSArray* allProblems;
@property (nonatomic, assign) NSInteger countProblems;
@property (nonatomic, assign) NSInteger countVote;
@property (nonatomic, assign) NSInteger countComment;
@property (nonatomic, assign) NSInteger countPhotos;
@property (nonatomic, weak)   EcomapProblem* currentProblem;
@property (nonatomic) NSMutableArray *test;
@property (nonatomic) NSMutableArray *forDay;
@property (nonatomic) NSMutableArray *forWeek;
@property (nonatomic) NSMutableArray *forMonth;
@end
