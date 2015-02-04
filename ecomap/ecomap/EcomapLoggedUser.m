//
//  EcomapLoggedUser.m
//  EcomapFetcher
//
//  Created by Vasya on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapLoggedUser.h"
#import "EcomapPathDefine.h"

EcomapLoggedUser *currentLoggedUser = nil;

@interface EcomapLoggedUser ()
@property (nonatomic, readwrite) NSUInteger userID;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *surname;
@property (nonatomic, strong, readwrite) NSString *role;
@property (nonatomic, readwrite) NSUInteger iat;
@property (nonatomic, strong, readwrite) NSString *token;
@property (nonatomic, strong, readwrite) NSString *email;

@end

@implementation EcomapLoggedUser
#pragma mark - Return current clas instanse
+(EcomapLoggedUser *)currentLoggedUser
{
    return currentLoggedUser;
}

#pragma mark - Logout
+(void)logout
{
    currentLoggedUser = nil;
}

#pragma mark - Private initializer
-(instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        if (userInfo){
            [self parseUser:userInfo];
            currentLoggedUser = self;
        } else {
            currentLoggedUser = nil;
            return nil;
        }
    }

    return self;
}

//Disable init method
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Can't create instanse of this class. To login use EcomapFetcher class" userInfo:nil];
    return nil;
}

#pragma mark - Parse userInfo
-(void)parseUser:(NSDictionary *)userInfo
{
    if (userInfo) {
        self.userID = [self IDOfUser:userInfo];
        self.name = [self nameOfUser:userInfo];
        self.surname = [self surnameOfUser:userInfo];
        self.role = [self roleOfUser:userInfo];
        self.iat = [self itaOfUser:userInfo];
        self.token = [self tokenOfUser:userInfo];
        self.email = [self emailOfUser:userInfo];
    }
}


//Returns user ID
- (NSUInteger)IDOfUser:(NSDictionary *)userInfo
{
    NSUInteger problemID = [[userInfo valueForKey:ECOMAP_USER_ID] integerValue];
    return problemID;
}

//Returns user name
- (NSString *)nameOfUser:(NSDictionary *)userInfo
{
    NSString *name = (NSString *)[userInfo valueForKey:ECOMAP_USER_NAME];
    if (name) {
        return name;
    }
    return nil;
}

//Returns user surname
- (NSString *)surnameOfUser:(NSDictionary *)userInfo
{
    NSString *surname = (NSString *)[userInfo valueForKey:ECOMAP_USER_SURNAME];
    if (surname) {
        return surname;
    }
    return nil;
}

//Returns user role
- (NSString *)roleOfUser:(NSDictionary *)userInfo
{
    NSString *role = (NSString *)[userInfo valueForKey:ECOMAP_USER_ROLE];
    if (role) {
        return role;
    }
    return nil;
}

//Returns user ITA
- (NSUInteger)itaOfUser:(NSDictionary *)userInfo
{
    NSUInteger ita = [[userInfo valueForKey:ECOMAP_USER_ITA] integerValue];
    return ita;
}

//Returns user token
- (NSString *)tokenOfUser:(NSDictionary *)userInfo
{
    NSString *token = (NSString *)[userInfo valueForKey:ECOMAP_USER_TOKEN];
    if (token) {
        return token;
    }
    return nil;
}

//Returns user email
- (NSString *)emailOfUser:(NSDictionary *)userInfo
{
    NSString *email = (NSString *)[userInfo valueForKey:ECOMAP_USER_EMAIL];
    if (email) {
        return email;
    }
    return nil;
}

#pragma mark - Override description
-(NSString *)description
{
    return [NSString stringWithFormat:@"Logged user: %@", self.name];
}

@end
