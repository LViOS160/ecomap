//
//  EcomapComments.h
//  ecomap
//
//  Created by Inna Labuskaya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapComments : NSObject

@property (nonatomic, readonly) NSUInteger commentID;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, readonly) NSUInteger activityTypes_Id;
@property (nonatomic, readonly) NSUInteger usersID;
@property (nonatomic, readonly) NSUInteger problemsID;

//Designated initializer
-(instancetype)initWithInfo:(NSDictionary *)problem;

@end
