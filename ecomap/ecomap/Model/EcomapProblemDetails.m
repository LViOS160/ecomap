//
//  EcomapProblemDetails.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapProblemDetails.h"
#import "EcomapPathDefine.h"

@interface EcomapProblemDetails ()
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSString *proposal;
@property (nonatomic, readwrite) NSUInteger severity;
@property (nonatomic, readwrite) NSUInteger moderation;
@property (nonatomic, readwrite) NSUInteger votes;

@end

@implementation EcomapProblemDetails

#pragma mark - Overriding problem init
//Override
-(instancetype)initWithProblem:(NSDictionary *)problem
{
    self = [super initWithProblem:problem];
    if (self) {
        if (!problem) return nil;
        [self parseProblem:problem];
    }
    return self;
}

-(void)parseProblem:(NSDictionary *)problem
{
    if (problem) {
        self.content = [problem valueForKey:ECOMAP_PROBLEM_CONTENT];
        self.proposal = [problem valueForKey:ECOMAP_PROBLEM_PROPOSAL];
        self.severity = [[problem valueForKey:ECOMAP_PROBLEM_SEVERITY] integerValue];
        self.moderation = [[problem valueForKey:ECOMAP_PROBLEM_MODERATION] integerValue];
        self.votes = [[problem valueForKey:ECOMAP_PROBLEM_VOTES] integerValue];
    }
}

@end
