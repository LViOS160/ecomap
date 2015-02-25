//
//  EcomapCommentsChild.h
//  ecomap
//
//  Created by Mikhail on 2/16/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapComments.h"

@interface EcomapCommentsChild : NSObject

@property (nonatomic) NSUInteger commentID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSUInteger activityTypes_Id;
@property (nonatomic) NSUInteger usersID;
@property (nonatomic) NSUInteger problemsID;

@property (nonatomic, strong) NSString *problemContent;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userSurname;
-(instancetype)initWithInfo:(NSDictionary *)problem;
@end
