//
//  EcomapLoggedUser.h
//  EcomapFetcher
//
//  Created by Vasya on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapLoggedUser : NSObject
@property (nonatomic, readonly) NSUInteger userID;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *surname;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, readonly) NSUInteger iat;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) NSString *email;

//Get current logged user object
//Return nil if no user is currently logged in
+(EcomapLoggedUser *)currentLoggedUser;

//This method don't perform logout from ecomap server. It just clear current logged user instanse pointer.
//To log out from server use appropriative class method from EcomapFetcher. Then this method will be called automatically
+(void)logout;

//Designated initializer
-(instancetype)initWithUserInfo:(NSDictionary *)userInfo;
@end
