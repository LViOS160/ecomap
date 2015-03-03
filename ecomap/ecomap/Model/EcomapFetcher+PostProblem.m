//
//  EcomapFetcher+PostProblem.m
//  ecomap
//
//  Created by Anton Kovernik on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher+PostProblem.h"

@implementation EcomapFetcher (PostProblem)

#pragma mark - POST API

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


@end
