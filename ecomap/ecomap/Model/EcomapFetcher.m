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
#import "AFNetworking.h"

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
                            NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                            problemsFromJSON = [aJSON[@"data"] isKindOfClass:[NSArray class]] ? aJSON[@"data"] : nil;
                            
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


+(void)loadAllProblemsDescription:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher ProblemDescription]]
              sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                 completionHandler:^(NSData *JSON, NSError *error) {
                     NSMutableArray *problems = nil;
                     NSArray *problemsFromJSON = nil;
                     if (!error) {
                         //Extract received data
                         if (JSON) {
                             DDLogVerbose(@"All problems loaded success from ecomap server");
                             //Parse JSON
                             NSDictionary *aJSON = [JSONParser parseJSONtoDictionary:JSON];
                             problemsFromJSON = [aJSON[@"data"] isKindOfClass:[NSArray class]] ? aJSON[@"data"] : nil;
                             
                             //Fill problems array
                             if (problemsFromJSON) {
                                 problems = [NSMutableArray array];
                                 //Fill array with EcomapProblem
                                 for (NSDictionary *problem in problemsFromJSON) {
                                     EcomapProblemDetails *ecoProblem = [[EcomapProblemDetails alloc] initWithProblem:problem];
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
                              
                              //commentsInfo = [JSONParser parseJSONtoDictionary:JSON];
                              
                              
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
                    
                    NSMutableArray *aliases = [NSMutableArray array];
                    
                    if(!error)
                    {
                        id value = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        if ([value isKindOfClass:[NSArray class]])
                        {
                            NSArray *aliasFromJSON = (NSArray*)value;
                            
                            //Fill array with ECOMAPRESOURCES
                            for (NSDictionary *singleAlias in aliasFromJSON)
                            {
                                EcomapAlias *ecoAl = [[EcomapAlias alloc] initWithAlias:singleAlias];
                                [aliases addObject:ecoAl];
                            }
                        }
                        else if ([value isKindOfClass:[NSDictionary class]])
                        {
                            EcomapAlias *ecoAl = [[EcomapAlias alloc] initWithAlias:value];
                            [aliases addObject:ecoAl];
                        }
                    }
                    else
                    {
                        [InfoActions showAlertOfError:error];
                    }
                    
                    completionHandler(aliases, error);
                    
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


+(BOOL)updateComments:(NSUInteger)problemID controller:(AddCommViewController*)controller
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString* baseUrl = @"http://176.36.11.25:8000/api/problems/";
    NSString* middleUrl = [baseUrl stringByAppendingFormat:@"%lu",(unsigned long)problemID];
    NSString* finalUrl = [middleUrl stringByAppendingString:@"/comments"];
    
    [manager GET:finalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* tmp = [responseObject valueForKey:@"data"];
         NSLog(@"%@", [tmp valueForKey:@"id"]);
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmp options:NSJSONWritingPrettyPrinted error:nil];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
         NSArray *ar = [JSONParser parseJSONtoArray:objectData];
         EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
         [ob setCommentariesArray:ar :problemID];
         ob.problemsID = problemID;
         [controller reload];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
             ob.problemsID = problemID;
             [ob setCommentariesArray:nil :problemID];
               [controller reload];
             NSLog(@"%@",error);
             
         }];
    return YES;
}




+(BOOL)updateComments:(NSUInteger)problemID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString* baseUrl = @"http://176.36.11.25:8000/api/problems/";
    NSString* middleUrl = [baseUrl stringByAppendingFormat:@"%lu",(unsigned long)problemID];
    NSString* finalUrl = [middleUrl stringByAppendingString:@"/comments"];
    [manager GET:finalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSArray* tmp = [responseObject valueForKey:@"data"];
        NSLog(@"%@", [tmp valueForKey:@"id"]);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmp options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *ar = [JSONParser parseJSONtoArray:objectData];
        EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
        [ob setCommentariesArray:ar :problemID];
        ob.problemsID = problemID;
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
        ob.problemsID = problemID;
        [ob setCommentariesArray:nil :problemID];
        NSLog(@"%@",error);
        
    }];
    return YES;
}


#pragma mark - Get Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{

    [self updateComments:problemID];
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
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
                        
                            
                            //[JSONParser parseJSONtoArray:JSON];
                           
                            //problem = [[values objectAtIndex:1] firstObject];
                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:answerFromServer];
                           
                            DDLogVerbose(@"Problem (id = %lu) loaded success from ecomap server", (unsigned long)problemDetails.problemID);
                            
                           // photos = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_PHOTOS];
                            problemPhotos = [NSMutableArray array];
                            for(NSDictionary *photo in photos){
                                id ecoPhoto = [[EcomapPhoto alloc] initWithInfo:photo];
                                if(photo)
                                    [problemPhotos addObject:ecoPhoto];
                            }
                            // DUMYAK CHANGE THERE
                            
                        //    comments = [jsonArray objectAtIndex:ECOMAP_PROBLEM_DETAILS_COMMENTS];
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
    if(![problemDetails canVote:user])               // work
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:NSLocalizedString(@"Будь ласка, увійдіть до системи для голосування", @"Please, login to vote!")
                                                      delegate:nil cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
        return;        
    }
    
    NSDictionary *voteData = nil;
    if(user)
    {
        voteData = @{
                     @"idProblem":@(problemDetails.problemID),
                     @"userId":@(user.userID),
                     @"userName":user.name ? user.name : @"",
                     @"userSurname":user.surname ? user.surname : @""
                     };
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
        [[NetworkActivityIndicator sharedManager] startActivity];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
        NSString *baseUrl = ECOMAP_ADDRESS;
        baseUrl = [baseUrl stringByAppendingString:ECOMAP_API];
        baseUrl = [baseUrl stringByAppendingString:ECOMAP_GET_PROBLEMS_WITH_ID_API];
        //NSString *baseUrl = @"http:176.36.11.25:8000/api/problems/";
        NSString *middle = [baseUrl stringByAppendingFormat:@"%lu/",(unsigned long)[ob problemsID]];
        NSString *final = [middle stringByAppendingString:ECOMAP_POST_VOTE];
        
        [manager POST:final parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"vote is added");            
          
            if (completionHandler)
            {
                completionHandler(nil);
            }
        }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (completionHandler)
            {
                completionHandler(error);
            }
        }];
        
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NetworkActivityIndicator sharedManager]endActivity];
    });
    
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


+(void)deleteComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentaries *obj,NSError *error))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforComments:probId]];
    [request setHTTPMethod:@"DELETE"];
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
                                   
                                  // commentsInfo = [JSONParser parseJSONtoDictionary:JSON];
                                   
                                   
                               }
                               else
                                   difComment = nil;
                               
                           } else [InfoActions showAlertOfError:error];
                           
                           completionHandler(difComment,error);
                           
                           
                           
                       }];

}



@end
