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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"isUserLogged"] isEqualToString:@"YES"] ? currentLoggedUser : nil;
}

#pragma mark - User initializer
-(instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    self = [super init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self) {
        // Add Observer
        [defaults addObserver:self
                   forKeyPath:@"isUserLogged"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        if (userInfo){
            [self parseUser:userInfo];
            [defaults setObject:@"YES" forKey:@"isUserLogged"];
            currentLoggedUser = self;
            
        } else {
            [defaults setObject:@"NO" forKey:@"isUserLogged"];
            currentLoggedUser = nil;
            return nil;
        }
    }
    
    return self;
}

//Disable init method
-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Error" reason:@"Can't create instanse of this class. To login to server use EcomapFetcher class" userInfo:nil];
    return nil;
}

-(void)parseUser:(NSDictionary *)userInfo
{
    if (userInfo) {
        self.userID = ![[userInfo valueForKey:ECOMAP_USER_ID] isKindOfClass:[NSNull class]] ? [[userInfo valueForKey:ECOMAP_USER_ID] integerValue] : 0;
        self.name = ![[userInfo valueForKey:ECOMAP_USER_NAME] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_NAME] : nil;
        self.surname = ![[userInfo valueForKey:ECOMAP_USER_SURNAME] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_SURNAME] : nil;
        self.role = ![[userInfo valueForKey:ECOMAP_USER_ROLE] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_ROLE] : nil;
        self.iat = ![[userInfo valueForKey:ECOMAP_USER_ITA] isKindOfClass:[NSNull class]] ? [[userInfo valueForKey:ECOMAP_USER_ITA] integerValue] : 0;
        self.token = ![[userInfo valueForKey:ECOMAP_USER_TOKEN] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_TOKEN] : 0;
        self.email = ![[userInfo valueForKey:ECOMAP_USER_EMAIL] isKindOfClass:[NSNull class]] ? [userInfo valueForKey:ECOMAP_USER_EMAIL] : nil;
    }
}

//Override
-(NSString *)description
{
    return [NSString stringWithFormat:@"Logged user: %@ %@ (id = %d)", self.name, self.surname, self.userID];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isUserLogged"]) {
        if ([[object valueForKey:@"isUserLogged"] isEqualToString:@"NO"]) {
            currentLoggedUser = nil;
        }
    }
}

//RemoveObserver
- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"isUserLogged"];
}

@end
