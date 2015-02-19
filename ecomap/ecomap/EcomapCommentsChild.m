//
//  EcomapCommentsChild.m
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapCommentsChild.h"
#import "EcomapPathDefine.h"

@interface EcomapComments ()

@property (nonatomic, readwrite) NSUInteger commentID;
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, readwrite) NSUInteger activityTypes_Id;
@property (nonatomic, readwrite) NSUInteger usersID;
@property (nonatomic, readwrite) NSUInteger problemsID;
@end

@implementation EcomapCommentsChild

-(instancetype)initWithInfo:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        self.commentID = [[problem valueForKey:ECOMAP_COMMENT_ID] integerValue];
        self.content = [problem valueForKey:ECOMAP_COMMENT_CONTENT];
        self.date = [self dateOfComment:problem];
        self.activityTypes_Id = 5;
        self.usersID = [[problem valueForKey:ECOMAP_COMMENT_USERS_ID] integerValue];
        self.problemsID = 89;//[[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] integerValue];
    }
    return self;

}



- (NSDate *)dateOfComment:(NSDictionary *)problem
{
    NSDate *date = nil;
    NSString *dateString = [problem valueForKey:ECOMAP_COMMENT_DATE];
    if (dateString) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
        date = [dateFormatter dateFromString:dateString];
        if (date) return date;
    }
    
    return nil;
}
@end
