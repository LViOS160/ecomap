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

@import MobileCoreServices;


@implementation EcomapFetcher

#pragma mark - Load all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
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
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
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

#pragma mark - Load Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
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
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"multipart/form-data;charset=UTF-8"}];
    
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
                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                          //Log success login
                          if (loggedUser) {
                              NSLog(@"LogIN to ecomap success! %@", loggedUser.description);
                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(loggedUser, error);
                  }];
}

#pragma mark - Logout
//Code in progress...
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL *result, NSError *error))completionHandler
{
    if (loggedUser) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"NO" forKey:@"isUserLogged"];
    }
}

#pragma mark - Load data task
+(void)loadDataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
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
                                                        NSLog(@"JSON data downloaded success from URL: %@", request.URL);
                                                        JSON = data;
                                                    } else {
                                                        //Create error message
                                                        error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                                                    }
                                                }
                                                //Perform completionHandler task on main thread
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completionHandler(JSON, error);
                                                });
                                            }];
    
    [task resume];
}

#pragma mark - upLoad data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Set data
            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                //Log to console
                NSLog(@"Data uploaded success to url: %@", request.URL);
                JSON = data;
            } else {
                //Create error message
                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
            }
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
        });
    }];
    [task resume];
}

#pragma mark - Parse JSON data to Array
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

#pragma mark - Parse JSON data to Dictionary
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

#pragma mark - Get status code
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode;
}

#pragma mark - Form error for status code
//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode) {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
        
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        case 401: // added by Gregory Chereda
            error = [[NSError alloc] initWithDomain:@"Unauthorized" code:401 userInfo:@{@"error" : @"Request error"}];
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown error" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
}

@end
