//
//  Statistics.m
//  ecomap
//
//  Created by Admin on 09.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "Statistics.h"

@implementation Statistics

+(instancetype)sharedInstanceStatistics
{
    static Statistics* singleton;
    static dispatch_once_t token;
    dispatch_once(&token, ^{singleton = [[Statistics alloc] init];});
    return singleton;
}

-(NSInteger)dataParserVoteCommentsPhotos:(NSString*)text :(NSString *)start :(NSString *)end
{
    NSInteger resultCounting = 0;
    NSScanner *textScanner = [NSScanner scannerWithString: text];
    NSString *tmp;
    while([textScanner isAtEnd]==NO)
    {
        [textScanner setCharactersToBeSkipped:nil];
        [textScanner scanUpToString: start intoString: NULL];
        if([textScanner scanString: start intoString: NULL]){
            if([textScanner scanUpToString:end intoString:&tmp])
            {
                if(![tmp isEqualToString:@"null"])
                {
                resultCounting+=[tmp doubleValue];
                }
            }
        }
    }
   
    return resultCounting;
}

-(void)statisticsForDay
{
    self.forDay = [[NSMutableArray alloc] initWithCapacity:10];
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-1];
    NSDate *new = [gregorian dateByAddingComponents:offsetComponents toDate:now options:0];
    
    for (NSInteger i = 0; i < [self.allProblems count]; i++)
    {
        self.currentProblem =  self.allProblems[i];
        NSComparisonResult result = [new compare: self.currentProblem.dateCreated];

        if(result == NSOrderedAscending)
        {
            switch (self.currentProblem.problemTypesID)
            {
                case 1:
                    arr[0]++;
                    break;
                case 2:
                    arr[1]++;
                    break;
                case 3:
                    arr[2]++;
                    break;
                case 4:
                    arr[3]++;
                    break;
                case 5:
                    arr[4]++;
                    break;
                case 6:
                    arr[5]++;
                    break;
                case 7:
                    arr[6]++;
                    break;
            }
        }
    }
    
    for( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forDay addObject:tmp];
    }
}


-(void)statisticsForWeek
{
    self.forWeek = [[NSMutableArray alloc] initWithCapacity:10];
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeekOfMonth:-1];
    NSDate *new = [gregorian dateByAddingComponents:offsetComponents toDate:now options:0];
    
    for (NSInteger i = 0; i < [self.allProblems count]; i++)
    {
        self.currentProblem =  self.allProblems[i];
        NSComparisonResult result = [new compare: self.currentProblem.dateCreated];
        
        if(result == NSOrderedAscending)
        {
            switch (self.currentProblem.problemTypesID)
            {
                case 1:
                    arr[0]++;
                    break;
                case 2:
                    arr[1]++;
                    break;
                case 3:
                    arr[2]++;
                    break;
                case 4:
                    arr[3]++;
                    break;
                case 5:
                    arr[4]++;
                    break;
                case 6:
                    arr[5]++;
                    break;
                case 7:
                    arr[6]++;
                    break;
            }
        }
    }
    
    for( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forWeek addObject:tmp];
    }
}

-(void)statisticsForMonth
{
    self.forMonth = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSDate * now = [NSDate date];
    NSInteger arr[7] = {0};
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-1];
    NSDate *new = [gregorian dateByAddingComponents:offsetComponents toDate:now options:0];
    
    for (NSInteger i = 0; i < [self.allProblems count]; i++)
    {
        self.currentProblem =  self.allProblems[i];
        NSComparisonResult result = [new compare: self.currentProblem.dateCreated];
        
        if(result == NSOrderedAscending)
        {
            switch (self.currentProblem.problemTypesID)
            {
                case 1:
                    arr[0]++;
                    break;
                case 2:
                    arr[1]++;
                    break;
                case 3:
                    arr[2]++;
                    break;
                case 4:
                    arr[3]++;
                    break;
                case 5:
                    arr[4]++;
                    break;
                case 6:
                    arr[5]++;
                    break;
                case 7:
                    arr[6]++;
                    break;
            }
        }
    }
    for( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.forMonth addObject:tmp];
    }
}

-(NSMutableArray*)countAllProblemsCategory
{
    [self statisticsForDay];
    [self statisticsForMonth];
    [self statisticsForWeek];
    
    self.allProblemsPieChart = [[NSMutableArray alloc] initWithCapacity:10];
    self.countProblems = [self.allProblems count];
    NSURL *url = [NSURL URLWithString:URL_PROBLEMS];
    NSString* dataForParsing = [[NSString alloc]initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    self.countVote = [self dataParserVoteCommentsPhotos:dataForParsing :@"number_of_votes\":": @", \"datetime"];
    self.countComment = [self dataParserVoteCommentsPhotos:dataForParsing :@"number_of_comments\":": @", \"longitude"];
    self.countPhotos = 0;
    
    self.test = [[NSMutableArray alloc] initWithCapacity:4];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.countProblems]];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.self.countVote]];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.countComment]];
    [self.test addObject:[NSString  stringWithFormat:@"%ld",self.self.countPhotos]];
   
    NSInteger arr[7];
 
    for (NSInteger i = 0; i < 7; i++)
    {
        arr[i] = 0;
    }
    for (NSInteger i = 0; i < [self.allProblems count]; i++)
    {
        self.currentProblem =  self.allProblems[i];

       switch (self.currentProblem.problemTypesID)
        {
            case 1:
               arr[0]++;
                break;
           case 2:
             arr[1]++;
               break;
           case 3:
             arr[2]++;
               break;
           case 4:
            arr[3]++;
               break;
           case 5:
            arr[4]++;
               break;
           case 6:
              arr[5]++;
               break;
           case 7:
                arr[6]++;
                break;
       }
    }
    for( NSInteger i = 0; i<7; i++)
    {
        NSNumber *tmp = [NSNumber numberWithInteger:arr[i]];
        [self.allProblemsPieChart addObject:tmp];
    }
    
    return self.allProblemsPieChart;
}

@end
