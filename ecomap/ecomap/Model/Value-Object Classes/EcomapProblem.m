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
@property (nonatomic, strong, readwrite) NSDate *dateCreated;
@end

@implementation EcomapProblem

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:_problemID forKey:@"problemID"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeDouble:_latitude forKey:@"latitude"];
    [coder encodeDouble:_longtitude forKey:@"longtitude"];
    [coder encodeInteger:_problemTypesID forKey:@"problemTypesID"];
    [coder encodeObject:_problemTypeTitle forKey:@"problemTypeTitle"];
    [coder encodeBool:_isSolved forKey:@"isSolved"];
    [coder encodeObject:_dateCreated forKey:@"dateCreated"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self.problemID =[coder decodeIntegerForKey:@"problemID"];
    self.title = [coder decodeObjectForKey:@"title"];
    self.latitude = [coder decodeDoubleForKey:@"latitude"];
    self.longtitude = [coder decodeDoubleForKey:@"longtitude"];
    self.problemTypesID = [coder decodeIntegerForKey:@"problemTypesID"];
    self.problemTypeTitle = [coder decodeObjectForKey:@"problemTypeTitle"];
    self.isSolved = [coder decodeBoolForKey:@"isSolved"];
    self.dateCreated = [coder decodeObjectForKey:@"dateCreated"];
    return self;
}


#pragma mark - Designated initializer
-(instancetype)initWithProblem:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        self.problemID = ![[problem valueForKey:ECOMAP_PROBLEM_ID] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue] : 0;
        self.title = ![[problem valueForKey:ECOMAP_PROBLEM_TITLE] isKindOfClass:[NSNull class]] ? [problem valueForKey:ECOMAP_PROBLEM_TITLE] : nil;
        self.latitude = ![[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_LATITUDE] doubleValue] : 0;
        self.longtitude = ![[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_LONGITUDE] doubleValue] : 0;
        self.problemTypesID = ![[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_TYPE_ID] integerValue] : 0;
        self.problemTypeTitle = [ECOMAP_PROBLEM_TYPES_ARRAY objectAtIndex:(self.problemTypesID - 1)];
        int isSolvedInt = ![[problem valueForKey:ECOMAP_PROBLEM_STATUS] isKindOfClass:[NSNull class]] ? [[problem valueForKey:ECOMAP_PROBLEM_STATUS] integerValue] : 0;
        self.isSolved = isSolvedInt == 0 ? NO : YES;
        self.dateCreated = [self dateCreatedOfProblem:problem];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Use designated initializer -initWithProblem:" userInfo:nil];
    return nil;
}

//Returns problem's date added
- (NSDate *)dateCreatedOfProblem:(NSDictionary *)problem
{
    NSDate *date = nil;
    NSString *dateString = [problem valueForKey:ECOMAP_PROBLEM_DATE];
    if (dateString) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
        date = [dateFormatter dateFromString:dateString];
        if (date) return date;
    }
    
    return nil;
}



@end
