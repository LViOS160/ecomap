//
//  Problem.h
//  ecomap
//
//  Created by Pavlo Dumyak on 10/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Problem : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * id;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDecimalNumber * userID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * problemTypeId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * numberOfVotes;
@property (nonatomic, retain) NSNumber * severity;
@property (nonatomic, retain) NSNumber * numberOfComments;
@property (nonatomic, retain) NSString * proposal;
@property (nonatomic, retain) NSNumber * longitude;

@end
