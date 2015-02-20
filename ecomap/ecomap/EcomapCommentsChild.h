//
//  EcomapCommentsChild.h
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapComments.h"

@interface EcomapCommentsChild : EcomapComments

@property (nonatomic, readonly) NSUInteger commentID;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, readonly) NSUInteger activityTypes_Id;
@property (nonatomic, readonly) NSUInteger usersID;
@property (nonatomic, readonly) NSUInteger problemsID;

@property (nonatomic, readonly) NSString *problemContent;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *userSurname;

@end
