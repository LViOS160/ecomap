//
//  ProblemViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/14/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemViewController.h"
#import "EcomapFetcher.h"
#import "EcomapURLFetcher.h"
#import "EcomapLoggedUser.h"
#import "ContainerViewController.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

typedef enum : NSUInteger {
    DetailedViewType,
    ActivityViewType,
    ComentViewType,
} ViewType;

@interface ProblemViewController()

@property (nonatomic, strong) EcomapProblemDetails *problemDetails;
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) ContainerViewController *containerViewController;

@end

@implementation ProblemViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateHeader];
    [self loadProblemDetails:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        self.containerViewController = segue.destinationViewController;
    }
}

- (void)loadProblemDetails:(void(^)())onFinish
{
    [EcomapFetcher loadProblemDetailsWithID:self.problem.problemID
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   self.problemDetails = problemDetails;
                                   [self.containerViewController setProblemDetails:problemDetails];
                                   [self updateHeader];
                               }];
}

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender
{
    [self.containerViewController showViewAtIndex:sender.selectedSegmentIndex];
    [self.containerViewController setProblemDetails:self.problemDetails];
}

- (IBAction)likeClick:(UIButton*)sender
{
    if(self.problemDetails) {
        sender.enabled = NO;
        [EcomapFetcher addVoteForProblem:self.problemDetails
                                withUser:[EcomapLoggedUser currentLoggedUser]
                            OnCompletion:^(NSError *error) {
                                if (!error) {
                                    [self loadProblemDetails:^{
                                        sender.enabled = YES;
                                    }];
                                } else {
                                    sender.enabled = YES;
                                }
                            }];
    }
}

- (void)updateHeader
{
    self.title = self.problem.title;
    self.severityLabel.text = [self severityString];
    self.statusLabel.attributedText = [self statusString];
    [self.likeButton setTitle:[self likeString] forState:UIControlStateNormal];
}

- (NSString*)severityString
{
    if (self.problemDetails) {
        NSMutableString *severity = [[NSMutableString alloc] init];
        NSString *blackStars = [@"" stringByPaddingToLength:self.problemDetails.severity withString:@"★" startingAtIndex:0];
        NSString *whiteStars = [@"" stringByPaddingToLength:5-self.problemDetails.severity withString:@"☆" startingAtIndex:0];
        [severity appendString:blackStars];
        [severity appendString:whiteStars];
        return severity;
    } else {
        return @"☆☆☆☆☆";
    }
}

- (NSAttributedString *)statusString
{
    if (self.problemDetails) {
        if(self.problem.isSolved) {
            return [[NSAttributedString alloc] initWithString:@"вирішена"
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor greenColor]
                                                                    }];
        } else {
            return [[NSAttributedString alloc] initWithString:@"не вирішена"
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor redColor]
                                                                }];
        }
    } else {
        return [[NSAttributedString alloc] initWithString:@"Завантаження..."];
    }
}

- (NSString *)likeString
{
    return [NSString stringWithFormat:@"♡%lu", self.problemDetails.votes];
}


@end
