//
//  EcomapProblem.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapProblem.h"
#import "EcomapPathDefine.h"

@interface EcomapProblem ()
@property (nonatomic, readwrite) NSUInteger problemID;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longtitude;
@property (nonatomic, readwrite) NSUInteger problemTypesID;
@property (nonatomic, strong, readwrite) NSString *problemTypeTitle;
@property (nonatomic, readwrite) BOOL isSolved;
@property (nonatomic, strong, readwrite) NSString *dateCreated;
@end

@implementation EcomapProblem

#pragma mark - Designated initializer
-(instancetype)initWithProblem:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        [self parseProblem:problem];
    }
    return self;
}

- (instancetype)init
{
    return nil;
}

#pragma mark - Parsing problem
-(void)parseProblem:(NSDictionary *)problem
{
    if (problem) {
        self.problemID = [self IDOfProblem:problem];
        self.title = [self titleOfProblem:problem];
        self.latitude = [self latitudeOfProblem:problem];
        self.longtitude = [self longtitudeOfProblem:problem];
        self.problemTypesID = [self typeIDOfProblem:problem];
        self.problemTypeTitle = [self typeTitleOfProblem:problem];
        self.isSolved = [self isSolvedProblem:problem];
        self.dateCreated = [self dateCreatedOfProblem:problem];
    }
}


//Returns problem ID
- (NSUInteger)IDOfProblem:(NSDictionary *)problem
{
    NSUInteger problemID = [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue];
    if (problemID != 0) {
        return problemID;
    }
    return NSNotFound;
}

//Returns problem title
- (NSString *)titleOfProblem:(NSDictionary *)problem{
    NSString *title = (NSString *)[problem valueForKey:ECOMAP_PROBLEM_TITLE];
    if (title) {
        return title;
    }
    return nil;
}

//Returns problem latitude
- (double)latitudeOfProblem:(NSDictionary *)problem
{
    double latitude = [[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] doubleValue];
    if (latitude != 0) {
        return latitude;
    }
    return NSNotFound;
}

//Returns problem longtitude
- (double)longtitudeOfProblem:(NSDictionary *)problem
{
    double longtitude = [[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] doubleValue];
    if (longtitude != 0) {
        return longtitude;
    }
    return NSNotFound;
}

//Returns problem type ID
- (NSUInteger)typeIDOfProblem:(NSDictionary *)problem
{
    NSUInteger problemTypeID = [[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] integerValue];
    if (problemTypeID != 0) {
        return problemTypeID;
    }
    return NSNotFound;
}

//Returns problem type title
- (NSString *)typeTitleOfProblem:(NSDictionary *)problem
{
    NSUInteger problemTypeID = [[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] integerValue];
    if (problemTypeID != 0) {
        return [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:(problemTypeID - 1)];
    }
    return nil;
}

//Returns problem's status
- (BOOL)isSolvedProblem:(NSDictionary *)problem
{
    NSUInteger problemStatus = [[problem valueForKey:ECOMAP_PROBLEM_STATUS] integerValue];
    return problemStatus == 0 ? NO : YES;
    
}

//Returns problem's date added
- (NSString *)dateCreatedOfProblem:(NSDictionary *)problem
{
    NSString *date = (NSString *)[problem valueForKey:ECOMAP_PROBLEM_DATE];
    if (date) {
        return date;
    }
    return nil;
}

@end
