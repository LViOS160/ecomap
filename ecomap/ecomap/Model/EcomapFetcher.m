//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapURLFetcher.h"
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "EcomapLoggedUser.h"
#import "EcomapPhoto.h"
#import "EcomapComments.h"
#import "EcomapResources.h"
#import "EcomapAlias.h"
#import "NetworkActivityIndicator.h"

@import MobileCoreServices;


@implementation EcomapFetcher

#pragma mark - Get all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problems = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [EcomapFetcher parseJSONtoArray:JSON];
                            
                            //Fill problems array
                            if (problemsFromJSON) {
                                problems = [NSMutableArray array];
                                //Fill array with EcomapProblem
                                for (NSDictionary *problem in problemsFromJSON) {
                                    EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                    [problems addObject:ecoProblem];
                                }
                            }
                            
                        }
                    }
                    //set up completionHandler
                    completionHandler(problems, error);
                }];
    
}
#pragma mark - Load All Problem Types
+ (void)loadAllPorblemTypes:(void (^)(NSArray *problemTypes, NSError *error))completionHandler {
   
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problemTypes = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [EcomapFetcher parseJSONtoArray:JSON];
                            
                            //Fill problems array
                            if (problemsFromJSON) {
                                problemTypes = [NSMutableArray array];
                                //Fill array with EcomapProblem
                                for (NSDictionary *problem in problemsFromJSON) {
                                    EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                    [problemTypes addObject:ecoProblem];
                                }
                            }
                            
                        }
                    }
                    //set up completionHandler
                    completionHandler(problemTypes, error);
                }];
    
}

#pragma mark - load all allias content

+(void)loadAliasOnCompletion:(void (^)(NSArray *alias, NSError *error))completionHandler String:(NSString *)str
{
    
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAlias:str]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSLog(@"%@",str);
                    NSMutableArray *alias = nil;
                    NSArray *aliasFromJSON = nil;
                    
                    if(!error)
                    {
                        //Parse JSON
                        aliasFromJSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        alias = [NSMutableArray array];
                        
                        //Fill array with ECOMAPRESOURCES
                        for(NSDictionary *aliases in aliasFromJSON)
                        {
                            EcomapAlias *ecoAl = [[EcomapAlias alloc] initWithAlias:aliases];
                            //  NSLog(@"%@",ecoAl.content);
                            [alias addObject:ecoAl];
                            
                        }
                    }
                    completionHandler(alias,error);
                    
                }];
    
    
}

#pragma mark - Load all Resources

+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforResources]]
             sessionConfiguration:[NSURLSessionConfiguration  ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    
                    NSMutableArray *resources = nil;
                    NSArray *resourcesFromJSON = nil;
                    if(!error)
                    {
                        //Parse JSON
                        resourcesFromJSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        resources = [NSMutableArray array];
                        
                        //Fill array with ECOMAPRESOURCES
                        for(NSDictionary *resource in resourcesFromJSON)
                        {
                            EcomapResources *ecoRes = [[EcomapResources alloc] initWithResource:resource];
                            [resources addObject:ecoRes];
                            
                            // NSLog(@"%@",resources);
                            
                        }
                    }
                    completionHandler(resources,error);
                    
                }];
    
    
}



#pragma mark - Get Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSDictionary *problem = nil;
                    NSArray *photos = nil;
                    NSArray *comments = nil;
                    
                    EcomapProblemDetails *problemDetails = nil;
                    NSMutableArray *problemPhotos = nil;
                    NSMutableArray *problemComments = nil;
                    
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Check if we have a problem with such problemID.
                            //If there is no one, server give us back Dictionary with "error" key
                            //Parse JSON
                            NSDictionary *answerFromServer = [EcomapFetcher parseJSONtoDictionary:JSON];
                            if (answerFromServer) {
                                //Return error. Form error to be passed to completionHandler
                                NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                                            code:404
                                                                        userInfo:answerFromServer];
                                completionHandler(problemDetails, error);
                                return;
                            }
                            
                            
                            //Extract problemDetails from JSON
                            //Parse JSON
                            NSArray *jsonArray = [EcomapFetcher parseJSONtoArray:JSON];
                            problem = [[jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:problem];
                            
                            photos = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_PHOTOS];
                            problemPhotos = [NSMutableArray array];
                            for(NSDictionary *photo in photos){
                                id ecoPhoto = [[EcomapPhoto alloc] initWithInfo:photo];
                                if(photo)
                                    [problemPhotos addObject:ecoPhoto];
                            }
                            
                            comments = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_COMMENTS];
                            problemComments = [NSMutableArray array];
                            for(NSDictionary *comment in comments){
                                id ecoComment = [[EcomapComments alloc] initWithInfo:comment];
                                if(ecoComment)
                                    [problemComments addObject:ecoComment];
                            }
                            problemDetails.photos = problemPhotos;
                            problemDetails.comments = problemComments;
                        }
                    }
                    
                    //Return problemDetails
                    completionHandler(problemDetails, error);
                }];
    
}



+ (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [EcomapFetcher mimeTypeForPath:path];
        NSLog(@"%@", [NSString stringWithFormat:@"--%@\r\n", boundary]);
        NSLog(@"%@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename]);
        NSLog(@"%@", [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype]);
        NSLog(@"%@", [NSString stringWithFormat:@"--%@--\r\n", boundary]);
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}


+ (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

+ (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    
    // if supporting iOS versions prior to 6.0, you do something like:
    //
    // // generate boundary string
    // //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    //
    // CFUUIDRef  uuid;
    // NSString  *uuidStr;
    //
    // uuid = CFUUIDCreate(NULL);
    // assert(uuid != NULL);
    //
    // uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    // assert(uuidStr != NULL);
    //
    // CFRelease(uuid);
    //
    // return uuidStr;
}

+ (void)problemPost:(void (^)())completionHandler {
    
    NSDictionary *params = @{@"type"     : @"1",
                             @"userEmail"    : @"rob@email.com",
                             @"userPassword" : @"password"};
    
    // Determine the path for the image
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"add" ofType:@"png"];
    
    // Create the request
    
    NSString *boundary = [EcomapFetcher generateBoundaryString];
    
    // configure the request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[EcomapURLFetcher URLforProblemPost]];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    
    NSData *httpBody = [EcomapFetcher createBodyWithBoundary:boundary parameters:params paths:@[path] fieldName:@"file[0]"];

    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error);
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result = %@", result);
    }];
    [task resume];
    
}

#pragma mark - Register

// added by Gregory Chereda
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforRegister]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"first_name": name, @"last_name":surname, @"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                     // EcomapLoggedUser *loggedUser = nil;
                      //NSDictionary *userInfo = nil;
                      if (!error) {
                          //Parse JSON
                          //userInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
//                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
//                          //Log success login
//                          if (loggedUser) {
                        NSLog(@"Register to ecomap success!");
//                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(error);
                  }];

    
}

#pragma mark - Login
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforLogin]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      EcomapLoggedUser *loggedUser = nil;
                      NSDictionary *userInfo = nil;
                      if (!error) {
                          //Parse JSON
                          userInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
                          //Create EcomapLoggedUser object
                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                          
                          if (loggedUser) {
                              NSLog(@"LogIN to ecomap success! %@", loggedUser.description);
                              
                              //Create cookie
                              NSHTTPCookie *cookie = [self createCookieForUser:[EcomapLoggedUser currentLoggedUser]];
                              if (cookie) {
                                  NSLog(@"Cookies created success!");
                                  //Put cookie to NSHTTPCookieStorage
                                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie]
                                                                                     forURL:[EcomapURLFetcher URLforServer]
                                                                            mainDocumentURL:nil];
                              }
                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(loggedUser, error);
                  }];
}

#pragma mark - Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforLogout]]
         sessionConfiguration:sessionConfiguration
            completionHandler:^(NSData *JSON, NSError *error) {
                BOOL result;
                if (!error) {
                    //Read response Data (it is not JSON actualy, just plain text)
                    NSString *statusResponse =[[NSString alloc]initWithData:JSON encoding:NSUTF8StringEncoding];
                    result = [statusResponse isEqualToString:@"OK"] ? YES : NO;
                    NSLog(@"Logout %@!", statusResponse);
                    
                    //Clear coockies
                    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[EcomapURLFetcher URLforServer]];
                    for (NSHTTPCookie *cookie in cookies) {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                    }
                    
                    //Set userDefaults @"isUserLogged" key to NO to delete EcomapLoggedUser object
                    if (loggedUser) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"NO" forKey:@"isUserLogged"];
                    }
                }
                completionHandler(result, error);
            }];
    
}

#pragma mark - Data tasks
//Data task
+(void)dataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{ [[NetworkActivityIndicator sharedManager]startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSData *JSON = nil;
                                                if (!error) {
                                                    //Set data
                                                    if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                                                        //Log to console
                                                        NSLog(@"Data task performed success from URL: %@", request.URL);
                                                        JSON = data;
                                                    } else {
                                                        //Create error message
                                                        error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                                                    }
                                                }
                                                //Perform completionHandler task on main thread
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completionHandler(JSON, error);
                                                    [[NetworkActivityIndicator sharedManager]endActivity];
                                                   
                                                });
                                                
                                            }];
    
    [task resume];
    
}

//Upload data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{    [[NetworkActivityIndicator sharedManager]startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Set data
            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                //Log to console
                NSLog(@"Upload task performed success to url: %@", request.URL);
                JSON = data;
            } else {
                //Create error message
                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
            }
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
            [[NetworkActivityIndicator sharedManager]endActivity];
        });
    }];
    [task resume];
    
}

#pragma mark - Parse JSON
//Parse JSON data to Array
+ (NSArray *)parseJSONtoArray:(NSData *)JSON
{
    NSArray *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSArray class]]) {
            dataFromJSON = (NSArray *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

//Parse JSON data to Dictionary
+ (NSDictionary *)parseJSONtoDictionary:(NSData *)JSON
{
    NSDictionary *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSDictionary class]]) {
            dataFromJSON = (NSDictionary *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

#pragma mark - Helper methods
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode;
}

//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode) {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
            
        case 401: // added by Gregory Chereda
            error = [[NSError alloc] initWithDomain:@"Unauthorized" code:statusCode userInfo:@{@"error" : @"Request error"}];
            break;
        
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown error" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
}

+ (NSHTTPCookie *)createCookieForUser:(EcomapLoggedUser *)userData
{
    NSHTTPCookie *cookie = nil;
    if (userData) {
        //Form userName value
        NSString *userName = userData.name ? userData.name : @"null";
        NSString *userNameValue = [NSString stringWithFormat:@"userName=%@", userName];
        
        //Form userSurname value
        NSString *userSurname = userData.surname ? userData.surname : @"null";
        NSString *userSurnameValue = [NSString stringWithFormat:@"userSurname=%@", userSurname];
        
        //Form userRole value
        NSString *userRole = userData.role ? userData.role : @"null";
        NSString *userRoleValue = [NSString stringWithFormat:@"userRole=%@", userRole];
        
        //Form token value
        NSString *token = userData.token ? userData.token : @"null";
        NSString *tokenValue = [NSString stringWithFormat:@"token=%@", token];
        
        //Form id value
        NSString *idValue = [NSString stringWithFormat:@"id=%lu", (unsigned long)userData.userID];
        
        //Form userEmail value
        NSString *userEmail = userData.email ? [userData.email stringByReplacingOccurrencesOfString:@"@" withString:@"%"] : @"null";
        NSString *userEmailValue = [NSString stringWithFormat:@"userEmail=%@", userEmail];
        
        //Form cookie value
        NSString *cookieValue = [NSString stringWithFormat:@"%@; %@; %@; %@; %@; %@", userNameValue, userSurnameValue, userRoleValue, tokenValue, idValue, userEmailValue];
        
        //Form cookie properties
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [EcomapURLFetcher serverDomain], NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"ECOMAPCOOKIE", NSHTTPCookieName,
                                    cookieValue, NSHTTPCookieValue,
                                    [[NSDate date] dateByAddingTimeInterval:864000], NSHTTPCookieExpires, //10 days
                                    nil];
        
        //Form cookie
        cookie = [NSHTTPCookie cookieWithProperties:properties];
    }
    
    return cookie;
}


@end
