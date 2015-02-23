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
#import "EMThumbnailImageStore.h"
#import "EcomapCommentsChild.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

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
                    if (error) {
                        NSLog(@"%d", abs(error.code / 100));
                    }
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
                    } else if ((error.code / 100 == 5) || (abs(error.code / 100) == 10)) [self showAlertViewOfError:error]; //Check for 5XX error and -1004 error (problem with internet)
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

#pragma mark - Post comment
+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentsChild *obj,NSError *error))completionHandler {
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforComments:probId]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data for send to server
    NSDictionary *commentData = @{@"data": @{@"urerId":userId,@"userName":name, @"userSurname":surname , @"Content":content} };
    NSData *data = [NSJSONSerialization dataWithJSONObject:commentData options:0 error:nil];
    
    [self uploadDataTaskWithRequest:request fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *commentsInfo;
                      // EcomapLoggedUser * check = [[EcomapLoggedUser alloc]init];
                      EcomapCommentsChild * difComment = nil;
                      
                      if(!error)
                          
                      {    difComment = [[EcomapCommentsChild alloc]initWithInfo:commentsInfo];
                          if([EcomapLoggedUser currentLoggedUser])
                          {
                              
                              commentsInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
                              
                              
                          }
                          else
                              difComment = nil;
                          
                      }
                      
                      completionHandler(difComment,error);
                      
                      
                      
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

#pragma mark -

+ (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
                  photoDescription:(NSArray*)descriptions
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    
    for (NSString *description in descriptions) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\";"] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", description] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"null\";"] dataUsingEncoding:NSUTF8StringEncoding]];
    
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

+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler {
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforTokenRegistration]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"token" : token};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *jsonString = [EcomapFetcher parseJSONtoDictionary:JSON];
                      completionHandler([jsonString valueForKey:@"err"], error);
                  }];

}

+ (void)problemPost:(EcomapProblem*)problem
     problemDetails:(EcomapProblemDetails*)problemDetails
               user:(EcomapLoggedUser*)user
       OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler {
    NSDictionary *params = @{@"title"     : problem.title,
                             @"content"    : problemDetails.content,
                             @"proposal" : problemDetails.proposal,
                             @"latitude" : @(problem.latitude),
                             @"longtitude" : @(problem.longtitude),
                             @"ProblemTypes_Id" : @(problem.problemTypesID),
                             @"userId" : @(user.userID),
                             @"userName" : user.name,
                             @"userSurname" : user.surname
                             };
    
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    NSMutableArray *pathes = [[NSMutableArray alloc] init];
    
    // Determine the path for the image
    
    for (EcomapPhoto *photo in problemDetails.photos) {
        [descriptions addObject:photo.description];
        [pathes addObject:photo.link];
    }

    
    // Create the request
    
    NSString *boundary = [EcomapFetcher generateBoundaryString];
    
    // configure the request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[EcomapURLFetcher URLforProblemPost]];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    
    NSData *httpBody = [EcomapFetcher createBodyWithBoundary:boundary parameters:params paths:pathes fieldName:@"file[0]" photoDescription:descriptions];

    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request
                                                   fromData:httpBody
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"error = %@", error);
                                                        return;
                                                    }
                                                    
                                                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                    NSLog(@"result = %@", result);
                                                    completionHandler(result, error);
                                                }];
    [task resume];
    
}

#pragma mark - Load image
+ (void)loadSmallImagesFromLink:(NSString *)link OnCompletion:(void (^)(UIImage *image, NSError *error))completionHandler
{
    [self downloadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforSmallPhotoWithLink:link]]
                 sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                    completionHandler:^(NSData *data, NSError *error) {
                        UIImage *image = nil;
                        if (!error) {
                            if (data) {
                                image = [UIImage imageWithData:data];
                                //Make thumnail image
                                image = [self makeThumbnailFromImage:image];
                                //Cache image
                                [[EMThumbnailImageStore sharedStore] setImage:image forKey:link];
                            }
                        }
                        //Return image
                        completionHandler(image, error);
                    }];
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
                              DDLogVerbose(@"LogIN to ecomap success! %@", loggedUser.description);
                              
                              //Create cookie
                              NSHTTPCookie *cookie = [self createCookieForUser:[EcomapLoggedUser currentLoggedUser]];
                              if (cookie) {
                                  DDLogVerbose(@"Cookies created success!");
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
                    DDLogVerbose(@"Logout %@!", statusResponse);
                    
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

#pragma mark - Statistics Fetching

+ (void)loadStatsForPeriod:(EcomapStatsTimePeriod)period onCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforStatsForParticularPeriod:period]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *stats = nil;
                if(error) {
                    NSLog(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100) == 10)) {
                    [self showAlertViewOfError:error]; //Check for 5XX error and -1004 error (problem with internet)
                } else {
                    // Extract recieved data
                    if(JSON != nil) {
                        stats = [NSJSONSerialization JSONObjectWithData:JSON
                                                                options:0
                                                                  error:NULL];
                    }
                }
                // Set up completion handler
                completionHandler(stats, error);
            }];
}

+ (void)loadGeneralStatsOnCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforGeneralStats]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *stats = nil;
                if(error) {
                    NSLog(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100) == 10)) {
                    [self showAlertViewOfError:error]; //Check for 5XX error and -1004 error (problem with internet)
                } else {
                    // Extract recieved data
                    if(JSON != nil) {
                        stats = [NSJSONSerialization JSONObjectWithData:JSON
                                                                options:0
                                                                  error:NULL];
                    }
                }
                // Set up completion handler
                completionHandler(stats, error);
            }];
}

+ (void)loadTopChartsOnCompletion:(void (^)(NSArray *charts, NSError *error))completionHandler
{
    [self dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforTopChartsOfProblems]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *charts = nil;
                if(error) {
                    NSLog(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100) == 10)) {
                    [self showAlertViewOfError:error]; //Check for 5XX error and -1004 error (problem with internet)
                } else {
                    // Extract recieved data
                    if(JSON != nil) {
                        charts = [NSJSONSerialization JSONObjectWithData:JSON
                                                                options:0
                                                                  error:NULL];
                    }
                }
                // Set up completion handler
                completionHandler(charts, error);
}];
}

#pragma mark - Data tasks
//Data task
+(void)dataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    [[NetworkActivityIndicator sharedManager] startActivity];
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
                                                        DDLogVerbose(@"Data task performed success from URL: %@", request.URL);
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

//Download data task
+(void)downloadDataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *data, NSError *error))completionHandler
{
    [[NetworkActivityIndicator sharedManager] startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                        NSData *data = nil;
                                                        if (!error) {
                                                            //Set data
                                                            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                                                                //Log to console
                                                                DDLogVerbose(@"Download data task performed success from URL: %@", request.URL);
                                                                data = [NSData dataWithContentsOfURL:location];;
                                                            } else {
                                                                //Create error message
                                                                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                                                            }
                                                        }
                                                        //Perform completionHandler task on main thread
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionHandler(data, error);
                                                            [[NetworkActivityIndicator sharedManager]endActivity];
                                                        });
 
                                                    }];
    
    
    [task resume];
    
}

//Upload data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    [[NetworkActivityIndicator sharedManager] startActivity];
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Set data
            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                //Log to console
                DDLogVerbose(@"Upload task performed success to url: %@", request.URL);
                JSON = data;
            } else {
                //Create error message
                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                JSON = data;
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
        DDLogError(@"Error parsing JSON data: %@", [error localizedDescription]);
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
        DDLogError(@"Error parsing JSON data: %@", [error localizedDescription]);
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
            
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 505:
        case 506:
        case 507:
        case 508:
        case 509:
        case 510:
        case 511:
            error = [[NSError alloc] initWithDomain:@"Server Error" code:statusCode userInfo:@{@"error" : @"Server Error"}];
            break;
            
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
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

+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler
{
    BOOL canVote = YES;
    if(user) {
        for(EcomapComments *comment in problemDetails.comments) {
            if (comment.activityTypes_Id == 3) { // vote activity type
                canVote &= comment.usersID != user.userID;
            }
        }
    } else {
        if([[[NSUserDefaults standardUserDefaults] arrayForKey:@"votedPosts"] containsObject:@(problemDetails.problemID)])
            canVote = NO;
    }
    
    if (!canVote) {
        completionHandler([NSError errorWithDomain:@"EcomapVote" code:1 userInfo:nil]);
        return;
    }
    
    NSDictionary *voteData = nil;
    if(user) {
        voteData = @{
                     @"idProblem":@(problemDetails.problemID),
                     @"userId":@(user.userID),
                     @"userName":user.name? user.name : @"",
                     @"userSurname":user.surname? user.surname : @""
                     };
    } else {
        voteData = @{
                     @"idProblem":@(problemDetails.problemID)
                     };
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:voteData options:0 error:nil];
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforPostVotes]];
    [request setHTTPMethod:@"POST"];
    
   [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *voteResponse = nil;
                      if (!error) {
                          voteResponse = [EcomapFetcher parseJSONtoDictionary:JSON];
                          if (!voteResponse[@"json"]) {
                              error = [NSError errorWithDomain:@"EcomapVote" code:2 userInfo:nil];
                          } else {
                              NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                              NSArray *votedPosts = [userDefaults arrayForKey:@"votedPosts"];
                              if(!votedPosts){
                                  votedPosts = [NSArray arrayWithObject:@(problemDetails.problemID)];
                              } else {
                                  votedPosts = [votedPosts arrayByAddingObject:@(problemDetails.problemID)];
                              }
                              [userDefaults setObject:votedPosts forKey:@"votedPosts"];
                          }
                      }
                      completionHandler(error);
                  }];
}

//Show error to the user in UIAlertView
+ (void)showAlertViewOfError:(NSError *)error
{
    NSString *alertTitle = nil;
    NSString *errorMessage = nil;  //human-readable dwscription of the error
    switch (error.code / 100) {
        case 5:
            alertTitle = @"Ecomap server error!";
            errorMessage = @"Could not connet to ecomap server. \nThere are technical problems on the server. We are working to fix it. Please try again later.";
            break;
            
        default:
            alertTitle = @"Error";
            errorMessage = [error localizedDescription];  //human-readable dwscription of the error
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//Make small image with roundeded rect
//This method will take a full-sized image, create a smaller representation of it in an offscreen graphics context object
+ (UIImage *)makeThumbnailFromImage:(UIImage *)image
{
    UIImage *thumbnail = nil;
    CGSize origImageSize = image.size;
    
    //The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 80, 80);
    
    //Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    //Create a transparent bitmap context with a scaling factor
    //equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //Create a path that is a rounded rectangle
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //Make all subsequent drawing clip to this rounded rectangle
    [path addClip];
    
    //Center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //Draw the image on it
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    thumbnail = smallImage;
    
    //clean up image context resources
    UIGraphicsEndImageContext();
    
    return thumbnail;
}


@end
