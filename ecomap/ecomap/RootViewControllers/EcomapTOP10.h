//
//  TOP10.h
//  ecomap
//
//  Created by admin on 10/12/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblem.h"

@interface EcomapTOP10 : NSObject
+(instancetype)sharedInstanceTOP10;
-(void)sortAllProblems;
@property (nonatomic) NSMutableArray* allProblemsPieChart;
@property (nonatomic, strong) NSArray* allProblems;
@property (nonatomic, weak)   EcomapProblem* currentProblem;
@property (nonatomic) NSMutableArray* problemVote;
@property (nonatomic) NSMutableArray* problemComment;
@property (nonatomic) NSMutableArray* problemSeverity;
@end
