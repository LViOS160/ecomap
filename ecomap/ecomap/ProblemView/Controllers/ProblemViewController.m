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
#import "EcomapEditableProblem.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"
#import "Defines.h"

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

// For admin purposes
@property (nonatomic, strong) EcomapLoggedUser *user;
@property (nonatomic, strong) EcomapEditableProblem *editableProblem;
@property (nonatomic, weak) IBOutlet UIButton *saveChangesButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteProblemButton;

@end

@implementation ProblemViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up gesture recognizers
    UITapGestureRecognizer *tapStatusLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapStatusLabelWithGestureRecognizer:)];
    [self.statusLabel addGestureRecognizer:tapStatusLabelGestureRecognizer];
    
    if(!self.user && ![self.user.role isEqualToString:@"administrator"]) {
        self.saveChangesButton.hidden = YES;
        self.deleteProblemButton.hidden = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get the current user
    self.user = [EcomapLoggedUser currentLoggedUser];
    
    [self updateHeader];
    [self loadProblemDetails:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(problemsDetailsChanged)
                                                 name:PROBLEMS_DETAILS_CHANGED
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self problemsDetailsChanged];
    [[NSNotificationCenter defaultCenter ]removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        self.containerViewController = segue.destinationViewController;
    }
}

#pragma mark - Handling User Interactions

- (void)handleTapStatusLabelWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // Handle gesture only if user is administrator
    if(self.user && [self.user.role isEqualToString:@"administrator"]) {
        self.editableProblem.solved = !self.editableProblem.solved;
        [self updateHeader];
        
    }
}

- (void)loadProblemDetails:(void(^)())onFinish
{
    [EcomapFetcher loadProblemDetailsWithID:self.problemID
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   self.problemDetails = problemDetails;
                                   self.editableProblem = [[EcomapEditableProblem alloc] initWithProblem:problemDetails];
                                   [self.containerViewController setProblemDetails:problemDetails];
                                   [self updateHeader];
                                   if(onFinish)
                                       onFinish();
                               }];
}

-(void)problemsDetailsChanged
{
    [self loadProblemDetails:nil];
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
    self.title = self.editableProblem.title;
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
    if (self.editableProblem) {
        if(self.editableProblem.isSolved) {
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
    return [NSString stringWithFormat:@"♡%lu", (unsigned long)self.problemDetails.votes];
}


@end
