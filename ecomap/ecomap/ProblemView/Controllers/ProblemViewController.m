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
#import "EcomapProblemDetails.h"
#import "InfoActions.h"
#import "MapViewController.h"
#import "EcomapRevealViewController.h"

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

@property (weak, nonatomic) id <EcomapProblemViewDelegate> delegate;

// For admin purposes
@property (nonatomic, strong) EcomapLoggedUser *user;
@property (nonatomic, strong) EcomapEditableProblem *editableProblem;

@end

@implementation ProblemViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up gesture recognizers
    UITapGestureRecognizer *tapStatusLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapStatusLabelWithGestureRecognizer:)];
    [self.statusLabel addGestureRecognizer:tapStatusLabelGestureRecognizer];
    
    self.user = [EcomapLoggedUser currentLoggedUser];
    
    [self updateHeader];
    [self loadProblemDetails:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(problemsDetailsChanged)
                                                 name:PROBLEMS_DETAILS_CHANGED
                                               object:nil];
}

- (void)dealloc
{
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
                                        [InfoActions showPopupWithMesssage:NSLocalizedString(@"Голос додано", @"Vote added")];
                                    }];
                                } else {
                                    sender.enabled = YES;
                                    [InfoActions showPopupWithMesssage:NSLocalizedString(@"Ви вже голосували за дану проблему", @"You have already voted for this problem")];
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
            return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"вирішена", @"solved")
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor greenColor]
                                                                    }];
        } else {
            return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"не вирішена", @"not solved")
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor redColor]
                                                                }];
        }
    } else {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Завантаження...", @"loading...")];
    }
}

- (NSString *)likeString
{
    if ([self.problemDetails canVote:[EcomapLoggedUser currentLoggedUser]])
         return [NSString stringWithFormat:@"♡%lu", (unsigned long)self.problemDetails.votes];
    else
        return [NSString stringWithFormat:@"♥︎%lu", (unsigned long)self.problemDetails.votes];
}

- (IBAction)tapLocateButton:(id)sender
{
    // Create new instance of map with only one problem
    // and camera position focused on it.
    UIViewController *customMapVC = [[UIViewController alloc] init];
    
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:self.problemDetails.latitude
                                longitude:self.problemDetails.longitude
                                     zoom:14.0];
    
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.problemDetails.latitude, self.problemDetails.longitude);
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%lu", (unsigned long)self.problemDetails.problemTypesID]];
    marker.map = mapView;
    
    customMapVC.view = mapView;
    
    // Push it to the navigation stack
    [self.navigationController pushViewController:customMapVC animated:YES];
}


@end
