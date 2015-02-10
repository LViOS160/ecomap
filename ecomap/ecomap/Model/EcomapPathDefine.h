//
//  Header.h
//  EcomapFetcher
//
//  Created by Vasya on 2/1/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//
#ifndef EcomapFetcher_Header_h
#define EcomapFetcher_Header_h

//API address
//#define ECOMAP_ADDRESS @"http://176.36.11.25/"
//#define ECOMAP_ADDRESS @"http://localhost:8090/"
#define ECOMAP_ADDRESS @"http://ecomap.org/"

#define ECOMAP_API @"api/"
#define ECOMAP_GET_PROBLEMS_API @"problems/"
#define ECOMAP_GET_PROBLEM_TYPES @"problems/"
#define ECOMAP_POST_LOGIN_API @"login/"
#define ECOMAP_POST_REGISTER_API @"register/"
#define ECOMAP_GET_PHOTOS_ADDRESS @"photos/large/"
#define ECOMAP_POST_PROBLEM @"problempost"

//Queries for statistics
#define ECOMAP_GET_TOP_CHARTS_OF_PROBLEMS @"getStats4"
#define ECOMAP_GET_GENERAL_STATS @"getStats3"
#define ECOMAP_GET_STATS_FOR_ALL_THE_TIME @"getStats2/A"
#define ECOMAP_GET_STATS_FOR_LAST_YEAR @"getStats2/Y"
#define ECOMAP_GET_STATS_FOR_LAST_MOTH @"getStats2/M"
#define ECOMAP_GET_STATS_FOR_LAST_WEEK @"getStats2/W"
#define ECOMAP_GET_STATS_FOR_LAST_DAY @"getStats2/D"

//Problems types descripton
#define ECOMAP_PROBLEM_TYPES_ARRAY @[@"проблеми лісів", @"сміттєзвалища", @"незаконна забудова", @"проблеми водойм", @"загрози біорізноманіттю", @"браконьєрство", @"інші проблеми"]

//Paths to Ecomap problem details array
#define ECOMAP_PROBLEM_DETAILS_DESCRIPTION 0
#define ECOMAP_PROBLEM_DETAILS_PHOTOS 1
#define ECOMAP_PROBLEM_DETAILS_COMMENTS 2

// keys (paths) applicable to all types of Ecomap problems dictionaries
#define ECOMAP_PROBLEM_ID @"Id"
#define ECOMAP_PROBLEM_TITLE @"Title"
#define ECOMAP_PROBLEM_LATITUDE @"Latitude"
#define ECOMAP_PROBLEM_LONGITUDE @"Longtitude"
#define ECOMAP_PROBLEM_TYPE_ID @"ProblemTypes_Id"
#define ECOMAP_PROBLEM_STATUS @"Status"

// keys (paths) to values in a PROBLEM dictionary of PROBLEMS array
#define ECOMAP_PROBLEM_DATE @"Date"

// keys (paths) to values in a FIRST dictionary (details about problem) in PROBLEM array
#define ECOMAP_PROBLEM_CONTENT @"Content"
#define ECOMAP_PROBLEM_PROPOSAL @"Proposal"
#define ECOMAP_PROBLEM_SEVERITY @"Severity"
#define ECOMAP_PROBLEM_MODERATION @"Moderation"
#define ECOMAP_PROBLEM_VOTES @"Votes"
#define ECOMAP_PROBLEM_VALUE @"value"

// keys (paths) to values in a SECOND dictionary (photos of a problem) in PROBLEM array
#define ECOMAP_PHOTO_ID @"Id"
#define ECOMAP_PHOTO_LINK @"Link"
#define ECOMAP_PHOTO_STATUS @"Status"
#define ECOMAP_PHOTO_DESCRIPTION @"Description"
#define ECOMAP_PHOTO_PROBLEMS_ID @"Problems_Id"
#define ECOMAP_PHOTO_USERS_ID @"Users_Id"

// keys (paths) to values in a THIRD dictionary (comments to problems) in PROBLEM array
#define ECOMAP_COMMENT_ID @"Id"
#define ECOMAP_COMMENT_CONTENT @"Content"
#define ECOMAP_COMMENT_DATE @"Date"
#define ECOMAP_COMMENT_ACTYVITYTYPES_ID @"ActivityTypes_Id"
#define ECOMAP_COMMENT_USERS_ID @"Users_Id"
#define ECOMAP_COMMENT_PROBLEMS_ID @"Problems_Id"

// keys (paths) to values in a USER dictionary
#define ECOMAP_USER_ID @"Id"
#define ECOMAP_USER_NAME @"name"
#define ECOMAP_USER_SURNAME @"surname"
#define ECOMAP_USER_ROLE @"role"
#define ECOMAP_USER_ITA @"iat"
#define ECOMAP_USER_TOKEN @"token"
#define ECOMAP_USER_EMAIL @"email"

// keys (paths) to values in a STAT dictionary in GENERAL STATS array
#define ECOMAP_GENERAL_STATS_PROBLEMS @"problems"
#define ECOMAP_GENERAL_STATS_VOTES @"votes"
#define ECOMAP_GENERAL_STATS_PHOTOS @"photos"
#define ECOMAP_GENERAL_STATS_COMMENTS @"comments"

#endif
