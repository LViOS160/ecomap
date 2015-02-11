//
//  EcomapPhoto.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapPhoto.h"
#import "EcomapPathDefine.h"

@interface EcomapPhoto()

@property (nonatomic, readwrite) NSUInteger photoID;
@property (nonatomic, strong, readwrite) NSString *link;
@property (nonatomic, readwrite) BOOL isSolved;
@property (nonatomic, strong, readwrite) NSString *description;
@property (nonatomic, readwrite) NSUInteger problemsID;
@property (nonatomic, readwrite) NSUInteger usersID;
@end

@implementation EcomapPhoto

-(instancetype)initWithInfo:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        self.photoID = [[problem valueForKey:ECOMAP_PHOTO_ID] integerValue];
        self.link = [problem valueForKey:ECOMAP_PHOTO_LINK];
        self.isSolved = [[problem valueForKey:ECOMAP_PHOTO_STATUS] integerValue] == 0 ? NO : YES;
        self.description = [problem valueForKey:ECOMAP_PHOTO_DESCRIPTION];
        self.problemsID = [[problem valueForKey:ECOMAP_PHOTO_PROBLEMS_ID] integerValue];
        self.usersID = [[problem valueForKey:ECOMAP_PHOTO_USERS_ID] integerValue];
        }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Use designated initializer -initWithProblem:" userInfo:nil];
    return nil;
}

@end
