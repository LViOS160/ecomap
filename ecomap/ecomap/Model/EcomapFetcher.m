//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "DataTasks.h"
#import "EcomapPathDefine.h"
#import "EcomapURLFetcher.h"
#import "JSONparser.h"
#import "NetworkActivityIndicator.h"

//Value-Object classes
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "EcomapLoggedUser.h"
#import "EcomapPhoto.h"
#import "EcomapComments.h"
#import "EcomapResources.h"
#import "EcomapAlias.h"
#import "EcomapCommentsChild.h"
#import "LocalImageDescription.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@import MobileCoreServices;


@implementation EcomapFetcher

#pragma mark - Get all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problems = nil;
                    NSArray *problemsFromJSON = nil;
                    if (error) {
                        DDLogVerbose(@"%d", abs(error.code / 100i));
                    }
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [JSONparser parseJSONtoArray:JSON];
                            
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
                    } else if ((error.code / 100 == 5) || (abs(error.code / 100i) == 10)) [self showAlertViewOfError:error]; //Check for 5XX error and -1004 error (problem with internet)
                    //set up completionHandler
                    completionHandler(problems, error);
                }];
    
}

#pragma mark - Load All Problem Types
+ (void)loadAllPorblemTypes:(void (^)(NSArray *problemTypes, NSError *error))completionHandler {
   
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problemTypes = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [JSONparser parseJSONtoArray:JSON];
                            
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
    NSLog(@"%@;%@;%@",userId,name,surname);
    //Create JSON data for send to server
    NSDictionary *commentData = @{@"data": @{@"userId":userId,@"userName":name, @"userSurname":surname, @"Content":content} };
    NSLog(@"%@",commentData);
    NSData *data = [NSJSONSerialization dataWithJSONObject:commentData options:0 error:nil];
    [DataTasks uploadDataTaskWithRequest:request fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *commentsInfo;
                      // EcomapLoggedUser * check = [[EcomapLoggedUser alloc]init];
                      EcomapCommentsChild * difComment = nil;
                      
                      if(!error)
                          
                      {    difComment = [[EcomapCommentsChild alloc]initWithInfo:commentsInfo];
                          if([EcomapLoggedUser currentLoggedUser])
                          {
                              
                              commentsInfo = [JSONparser parseJSONtoDictionary:JSON];
                              
                              
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
    
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAlias:str]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    DDLogVerbose(@"%@",str);
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
                            //  DDLogVerbose(@"%@",ecoAl.content);
                            [alias addObject:ecoAl];
                            
                        }
                    }
                    completionHandler(alias,error);
                    
                }];
    
    
}

#pragma mark - Load all Resources

+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforResources]]
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
                            
                            // DDLogVerbose(@"%@",resources);
                            
                        }
                    }
                    completionHandler(resources,error);
                    
                }];
    
    
}

#pragma mark - Get Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
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
                            NSDictionary *answerFromServer = [JSONparser parseJSONtoDictionary:JSON];
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
                            NSArray *jsonArray = [JSONparser parseJSONtoArray:JSON];
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
        DDLogVerbose(@"%@", [NSString stringWithFormat:@"--%@\r\n", boundary]);
        DDLogVerbose(@"%@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename]);
        DDLogVerbose(@"%@", [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype]);
        DDLogVerbose(@"%@", [NSString stringWithFormat:@"--%@--\r\n", boundary]);

        
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
    [DataTasks uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *jsonString = [JSONparser parseJSONtoDictionary:JSON];
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
                                                        DDLogVerbose(@"error = %@", error);
                                                        return;
                                                    }
                                                    
                                                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                    DDLogVerbose(@"result = %@", result);
                                                    completionHandler(result, error);
                                                }];
    [task resume];
    
}

#pragma mark - Statistics Fetching

+ (void)loadStatsForPeriod:(EcomapStatsTimePeriod)period onCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforStatsForParticularPeriod:period]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *stats = nil;
                if(error) {
                    DDLogVerbose(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100i) == 10)) {
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
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforGeneralStats]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *stats = nil;
                if(error) {
                    DDLogVerbose(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100i) == 10)) {
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
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforTopChartsOfProblems]]
         sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
            completionHandler:^(NSData *JSON, NSError *error) {
                NSArray *charts = nil;
                if(error) {
                    DDLogVerbose(@"ERROR! Problems with fetching stats for period");
                } else if((error.code / 100 == 5) || (abs(error.code / 100i) == 10)) {
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
    
   [DataTasks uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *voteResponse = nil;
                      if (!error) {
                          voteResponse = [JSONparser parseJSONtoDictionary:JSON];
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

+ (void)addPhotos:(NSArray*)photos
        toProblem:(NSUInteger)problemId
             user:(EcomapLoggedUser*)user
     OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler
{
    if (!user || photos.count == 0) {
        completionHandler(nil, [NSError errorWithDomain:@"Fetcher"
                                                   code:2
                                               userInfo:@{
                                                          NSLocalizedDescriptionKey: @"Error"
                                                          }]);
        return;
    }
    NSDictionary *params = @{
                             @"userId" : @(user.userID),
                             @"userName" : user.name,
                             @"userSurname" : user.surname,
                             @"solveProblemMark": @"off",
                             };
    
    NSString *boundary = [EcomapFetcher generateBoundaryString];
    
    // configure the request
    NSURL *url = [[EcomapURLFetcher URLforPostPhoto] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(problemId)]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    
    NSData *httpBody = [EcomapFetcher createPhotoBodyWithBoundary:boundary
                                                       parameters:params
                                                           photos:photos];
    
    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request
                                                   fromData:httpBody
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (error) {
                                                  DDLogVerbose(@"error = %@", error);
                                                  completionHandler(nil, error);
                                                  return;
                                              }
                                              
                                              NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                              DDLogVerbose(@"result = %@", result);
                                              completionHandler(result, error);
                                          }];
    [task resume];
}

+ (NSData*)createPhotoBodyWithBoundary:(NSString*)boundary
                            parameters:(NSDictionary*)parameters
                                photos:(NSArray*)photos
{
    NSMutableData *httpBody = [NSMutableData data];
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:boundaryData];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    [photos enumerateObjectsUsingBlock:^(LocalImageDescription *descr, NSUInteger idx, BOOL *stop) {
        [httpBody appendData:boundaryData];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\";\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", descr.imageDescription] dataUsingEncoding:NSUTF8StringEncoding]];

        NSString *filename  = [NSString stringWithFormat:@"%lu.jpg", (unsigned long)idx];
        NSData   *data      = UIImageJPEGRepresentation(descr.image, 0.8);
        NSString *mimetype  = [EcomapFetcher mimeTypeForPath:filename];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file[%lu]\"; filename=\"%@\"\r\n",
                               (unsigned long)idx,
                               filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
    
}

#pragma mark - Alert View
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

@end
