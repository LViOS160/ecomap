//
//  EcomapCommentsChild.m
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapCommentsChild.h"
#import "EcomapPathDefine.h"

@interface EcomapCommentsChild ()

@end

@implementation EcomapCommentsChild

-(instancetype)initWithInfo:(NSDictionary *)problem
{
    self = [super init];
    if (self) {
        if (!problem) return nil;
        self.commentID = [[problem valueForKey:ECOMAP_COMMENT_ID] isKindOfClass:[NSNumber class]] ? [[problem valueForKey:ECOMAP_COMMENT_ID] integerValue] : 0;
        
        self.content = [[problem valueForKey:ECOMAP_COMMENT_CONTENT] isKindOfClass:[NSString class]] ? [problem valueForKey:ECOMAP_COMMENT_CONTENT] : @"";
        NSData *data = [self.content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *commentDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        self.problemContent = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT] isKindOfClass:[NSString class]] ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT] : @"";
        
        self.userName = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERNAME] isKindOfClass:[NSString class]]
        ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERNAME] : @"";
        
        self.userSurname = [[commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERSURNAME] isKindOfClass:[NSString class]] ? [commentDictionary valueForKey:ECOMAP_COMMENT_CONTENT_USERSURNAME] :@"";
        
        self.date = [self dateOfComment:problem];
        self.activityTypes_Id = 5;
        self.usersID = [[problem valueForKey:ECOMAP_COMMENT_USERS_ID] isKindOfClass:[NSNumber class]] ? [[problem valueForKey:ECOMAP_COMMENT_USERS_ID] integerValue] : 0;
        self.problemsID = [[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] isKindOfClass:[NSNumber class]] ?[[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] integerValue] : 0;
      //  self.problemsID = 89;//[[problem valueForKey:ECOMAP_COMMENT_PROBLEMS_ID] integerValue];
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
