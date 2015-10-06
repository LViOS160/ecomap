//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapLocalPhoto.h"
#import "InfoActions.h"

@implementation EcomapFetcher

#pragma mark - Get all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problems = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON) {
                            DDLogVerbose(@"All problems loaded success from ecomap server");
                            //Parse JSON
                            problemsFromJSON = [JSONParser parseJSONtoArray:JSON];
                            
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
                    } else [InfoActions showAlertOfError:error];
        
                    //set up completionHandler
                    completionHandler(problems, error);
                }];
    
}

#pragma mark - Post comment
+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentaries *obj,NSError *error))completionHandler {
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforComments:probId]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
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
                      EcomapCommentaries * difComment = nil;
                      
                      if(!error)
                          
                      {    difComment = [[EcomapCommentaries alloc]initWithInfo:commentsInfo];
                          if([EcomapLoggedUser currentLoggedUser])
                          {
                              
                              commentsInfo = [JSONParser parseJSONtoDictionary:JSON];
                              
                              
                          }
                          else
                              difComment = nil;
                          
                      } else [InfoActions showAlertOfError:error];
                      
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
                    } else [InfoActions showAlertOfError:error];
                    
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
                    } else [InfoActions showAlertOfError:error];
                    
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
                        if (JSON) {
                            //Check if we have a problem with such problemID.
                            //If there is no one, server give us back Dictionary with "error" key
                            //Parse JSON
                            NSDictionary *answerFromServer = [JSONParser parseJSONtoDictionary:JSON];
                           /* if (answerFromServer) {
                                DDLogError(@"There is no problem (id = %lu) on server", (unsigned long)problemID);
                                //Return error. Form error to be passed to completionHandler
                                NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                                            code:404
                                                                        userInfo:answerFromServer];
                                completionHandler(problemDetails, error);
                                return;
                            }*/
                            
                            //Extract problemDetails from JSON
                            //Parse JSON
                            NSArray *jsonArray = [JSONParser parseJSONtoArray:JSON];
                            problem = [[jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:answerFromServer];
                            DDLogVerbose(@"Problem (id = %lu) loaded success from ecomap server", (unsigned long)problemDetails.problemID);
                            
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
                                id ecoComment = [[EcomapActivity alloc] initWithInfo:comment];
                                if(ecoComment)
                                    [problemComments addObject:ecoComment];
                            }
                            problemDetails.photos = problemPhotos;
                            problemDetails.comments = problemComments;
                        }
                    } else [InfoActions showAlertOfError:error];
                    
                    //Return problemDetails
                    completionHandler(problemDetails, error);
                }];
    
}


#pragma mark - Statistics Fetching


#pragma mark -
+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler
{
    BOOL canVote = YES;
    if(user) {
        for(EcomapActivity *comment in problemDetails.comments) {
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
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
   [DataTasks uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      NSDictionary *voteResponse = nil;
                      if (!error) {
                          voteResponse = [JSONParser parseJSONtoDictionary:JSON];
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
                      } else [InfoActions showAlertOfError:error];
                      
                      completionHandler(error);
                  }];
}

+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler {
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforTokenRegistration]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"token" : token};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           NSDictionary *jsonString = [JSONParser parseJSONtoDictionary:JSON];
                           completionHandler([jsonString valueForKey:@"err"], error);
                       }];
    
}

@end
