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

#pragma mark - Parsing problem
-(void)parseProblem:(NSDictionary *)problem
{
    if (problem) {
        [super parseProblem:problem];
        self.content = [self contentOfProblem:problem];
        self.proposal = [self proposalOfProblem:problem];
        self.severity = [self severityOfProblem:problem];
        self.moderation = [self moderationOfProblem:problem];
        self.votes = [self votesOfProblem:problem];
    }
}


//Returns problem content
- (NSString *)contentOfProblem:(NSDictionary *)problem{
    NSString *content = (NSString *)[problem valueForKey:ECOMAP_PROBLEM_CONTENT];
    if (content) {
        return content;
    }
    return nil;
}

//Returns problem proposal
- (NSString *)proposalOfProblem:(NSDictionary *)problem{
    NSString *proposal = (NSString *)[problem valueForKey:ECOMAP_PROBLEM_PROPOSAL];
    if (proposal) {
        return proposal;
    }
    return nil;
}

//Returns problem severity
- (NSUInteger)severityOfProblem:(NSDictionary *)problem
{
    NSUInteger problemSeverity = [[problem valueForKey:ECOMAP_PROBLEM_SEVERITY] integerValue];
    return problemSeverity;
}

//Returns problem moderation
- (NSUInteger)moderationOfProblem:(NSDictionary *)problem
{
    NSUInteger problemModeration = [[problem valueForKey:ECOMAP_PROBLEM_MODERATION] integerValue];
    return problemModeration;
}

//Returns problem votes
- (NSUInteger)votesOfProblem:(NSDictionary *)problem
{
    NSUInteger problemVotes = [[problem valueForKey:ECOMAP_PROBLEM_VOTES] integerValue];
    return problemVotes;
}

@end
